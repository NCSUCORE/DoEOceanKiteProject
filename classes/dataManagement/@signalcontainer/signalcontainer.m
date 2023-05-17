classdef signalcontainer < dynamicprops
    %SIGNALCONTAINER Custom class used to store and organize timesignal
    %objects.
    
    properties
        
    end
    
    methods
        function obj = signalcontainer(objToParse,varargin)
            % Parse inputs
            p = inputParser;
            %             addOptional(p,'logsout',[],@(x) isa(x,'Simulink.SimulationData.Dataset'))
            addOptional(p,'structBlockPath',[],@(x) isa(x,'Simulink.SimulationData.BlockPath')||isempty(x))
            addParameter(p,'Verbose',true,@islogical);
            parse(p,varargin{:});
            switch class(objToParse)
                case {'Simulink.SimulationData.Dataset','Simulink.sdi.DatasetRef'}
                    % Add metadata to the signal container at highest level
                    obj.addprop('metadata');
                    obj.metadata = metadata(p.Results.Verbose);
                    % get names of signals
                    names = objToParse.getElementNames;
                    % get rid of unnamed signals (empty strings)
                    names = names(cellfun(@(x) ~isempty(x),names));
                    % get rid of duplicate signal names
                    names = unique(names);
                    % add each signal to the signalcontainer
                    for ii = 1:length(names)
                        % Get element from logsout
                        ts = objToParse.getElement(names{ii});
                        % Get the name of the name and make it a valid
                        % property name
                        if ~isempty(ts.Name)
                            propName = genvarname(ts.Name);
                        else
                            propName = genvarname(names{ii});
                        end
                        % Deal with duplicate signal names
                        if isa(ts,'Simulink.SimulationData.Dataset')
                            if p.Results.Verbose
%                                 warning('Duplicate signal names: ''%s''.  Taking first found signal.',ts{1}.Name)
                            end
                            ts = ts{1};
                        end
                        % Add a new field by this name
                        obj.addprop(propName);
                        % Preallocate with empty structure
                        obj.(propName) = struct.empty(numel(ts.Values),0);
                        % Loop through each signal stored in ts.Values
                        for jj = 1:numel(ts.Values)
                            switch class(ts.Values(jj))
                                case 'timeseries'
                                    obj.(propName) = timesignal(ts.Values(jj),'BlockPath',ts.BlockPath);
                                case 'struct'
                                    obj.(propName) = signalcontainer(ts.Values(jj),'structBlockPath',ts.BlockPath);
                            end
                        end
                    end
                    % Print out power summary for the user
                    if p.Results.Verbose
                        obj.powersummary
                    end
                case 'struct'
                    % Add metadata to the signal container at highest level
                    obj.addprop('metadata');
                    obj.metadata = metadata(p.Results.Verbose);
                    % get names of signals
                    names = fieldnames(objToParse);
                    % get rid of unnamed signals (empty strings)
                    names = names(cellfun(@(x) ~isempty(x),names));
                    % get rid of duplicate signal names
                    names = unique(names);
                    % add each signal to the signalcontainer
                    for ii = 1:length(names)
                        % Get element from logsout
                        ts = objToParse.(names{ii});
                        % Get the name of the name and make it a valid
                        % property name
                        if isa(ts,'struct')
                            propName = genvarname(names{ii});
                        elseif ~isempty(ts.Name)
                            propName = genvarname(ts.Name);
                        else
                            propName = genvarname(names{ii});
                        end
                        % Deal with duplicate signal names
                        if isa(ts,'Simulink.SimulationData.Dataset')
                            if p.Results.Verbose
                                warning('Duplicate signal names: ''%s''.  Taking first found signal.',ts{1}.Name)
                            end
                            ts = ts{1};
                        end
                        % Add a new field by this name
                        obj.addprop(propName);
                        % Loop through each signal stored in ts.Values
                        switch class(ts)
                            case {'timeseries','timesignal'}
                                obj.(propName) = timesignal(ts,'BlockPath',p.Results.structBlockPath);
                            case 'struct'
                                obj.(propName) = signalcontainer(ts,'structBlockPath',p.Results.structBlockPath);
                        end
                    end
                case 'signalcontainer'
                    obj.addprop('metadata');
                    obj.metadata = objToParse.metadata;
                    propNames = properties(objToParse);
                    propNames = propNames(cellfun(@(x) ~strcmp(x,'metadata'),propNames));
                    for ii = 1:numel(propNames)
                        obj.addprop(propNames{ii});
                        switch class(objToParse.(propNames{ii}))
                            case {'timesignal','timeseries'}
                                obj.(propNames{ii}) = timesignal(objToParse.(propNames{ii}));
                            case {'signalcontainer','struct'}
                                obj.(propNames{ii}) = signalcontainer(objToParse.(propNames{ii}));
                        end
                    end
                otherwise
                    error('Unknown data type to parse')
            end
        end
        function plotCLCD(obj,vhcl,varargin)
            p = inputParser;
            addOptional(p,'plot1Lap',false,@islogical);
            addOptional(p,'plotS',false,@islogical);
            addOptional(p,'Lap1',1,@isnumeric);
            parse(p,varargin{:})
            data = squeeze(obj.currentPathVar.Data);
            time = obj.lapNumS.Time;
            lap = p.Results.plot1Lap;
            con = p.Results.plotS;
            L1 = p.Results.Lap1;
            %  Determine Single Lap Indices
            if lap
                lapNum = squeeze(obj.lapNumS.Data);
                Idx1 = find(lapNum > L1,1,'first');
                Idx2 = find(lapNum > L1+1,1,'first');
                if isempty(Idx1) || isempty(Idx2)
                    error('Lap 1 was never started or finished. Simulate longer or reassess the meaning to your life')
                end
                ran = Idx1:Idx2-1;
                lim = [time(Idx1) time(Idx2)];
            else
                lim = [time(1) time(end)];
            end
            %  Compute Plotting Variables
            [CL,CD] = getCLCD(obj,vhcl);
            hold on; grid on
            if lap
                if con
                    plot(data(ran),CL(ran),'b-');  xlabel('Path Position');
                    plot(data(ran),CD(ran),'r-');  xlabel('Path Position');  legend('CL','CD','location','east');
                else
                    plot(time(ran),CL(ran),'b-');  xlabel('Path Position');
                    plot(time(ran),CD(ran),'r-');  xlabel('Path Position');  xlim(lim);  legend('CL','CD','location','east');
                end
            else
                plot(time,CL,'b-');  xlabel('Path Position');
                plot(time,CD,'r-');  xlabel('Path Position');  xlim(lim);  legend('CL','CD','location','east');
            end
        end
        function plotTanAngles(obj,varargin)
            
            p = inputParser;
            addOptional(p,'plot1Lap',false,@islogical);
            addOptional(p,'plotS',false,@islogical);
            addOptional(p,'Lap1',1,@isnumeric);
            parse(p,varargin{:})
            data = squeeze(obj.currentPathVar.Data);
            time = obj.lapNumS.Time;
            lap = p.Results.plot1Lap;
            con = p.Results.plotS;
            L1 = p.Results.Lap1;
            %  Determine Single Lap Indices
            if lap
                lapNum = squeeze(obj.lapNumS.Data);
                Idx1 = find(lapNum > L1,1,'first');
                Idx2 = find(lapNum > L1+1,1,'first');
                if isempty(Idx1) || isempty(Idx2)
                    error('Lap 1 was never started or finished. Simulate longer or reassess the meaning to your life')
                end
                ran = Idx1:Idx2-1;
                lim = [time(Idx1) time(Idx2)];
            else
                lim = [time(1) time(end)];
            end
            %  Compute Plotting Variables
            tanRoll = squeeze(obj.tanRoll.Data)*180/pi;
            tanPitch = squeeze(obj.tanPitch.Data)*180/pi;
            hold on; grid on
            if lap
                if con
                    plot(data(ran),tanRoll(ran),'b-');  xlabel('Path Position');  ylabel('Angle [deg]');
                    plot(data(ran),tanPitch(ran),'r-'); xlabel('Path Position');  legend('$\mathrm{\phi_{tan}}$','$\theta_{tan}$','location','northeast');
                else
                    plot(time(ran),tanRoll(ran),'b-');  xlabel('Path Position');  ylabel('Angle [deg]');
                    plot(time(ran),tanPitch(ran),'r-'); xlabel('Path Position');  legend('$\mathrm{\phi_{tan}}$','$\theta_{tan}$','location','northeast');  xlim(lim);
                end
            else
                plot(time,tanRoll,'b-');  xlabel('Path Position');  ylabel('Angle [deg]');
                plot(time,tanPitch,'r-'); xlabel('Path Position');  legend('$\mathrm{\phi_{tan}}$','$\theta_{tan}$','location','northeast');  xlim(lim);
            end
        end
        function plotPitch(obj)
            figure();
            %  Plot Pitch Angle
            subplot(2,1,1); hold on; grid on;
            plot(obj.pitchSP.Time,squeeze(obj.pitchSP.Data),'r-');
            plot(obj.pitch.Time,squeeze(obj.pitch.Data)*180/pi,'b-');  xlabel('Time [s]');  ylabel('Pitch [deg]');
            legend('Setpoint','AutoUpdate','off','location','northwest')
            %  Plot Elevator Command
            subplot(2,1,2); hold on; grid on;
            plot(obj.ctrlSurfDefl.Time,squeeze(obj.ctrlSurfDefl.Data(3,:,:)),'b-');  
            xlabel('Time [s]');  ylabel('Elevator [deg]');
        end
        function [CLsurf,CDtot,CDnoThr] = getCLCD(obj,vhcl,thr)
            dThr = thr.tether1.diameter.Value;
            LThr = sqrt(sum(vhcl.initPosVecGnd.Value.^2));
            Aref = vhcl.fluidRefArea.Value;
            Afuse = vhcl.fluidRefArea.Value;
            Athr = LThr*dThr/4;
            CDfuse = squeeze(obj.CDfuse.Data).*Afuse/Aref;
            CDthr = thr.tether1.dragCoeff.Value(end).*Athr/Aref;
            CDsurf = squeeze(obj.portWingCD.Data+obj.stbdWingCD.Data+obj.hStabCD.Data+obj.vStabCD.Data);
            CDtot = CDfuse+CDsurf+CDthr;
            CDnoThr = CDfuse+CDsurf;
            CLsurf = squeeze(obj.portWingCL.Data+obj.stbdWingCL.Data+obj.hStabCL.Data);
        end
        function [Lift,Drag,Fuse,Thr] = getLiftDrag(obj)
            FLiftBdyP1 = squeeze(sqrt(sum(obj.portWingLift.Data(:,1,:).^2,1)));
            FLiftBdyP2 = squeeze(sqrt(sum(obj.stbdWingLift.Data(:,1,:).^2,1)));
            FLiftBdyP3 = squeeze(sqrt(sum(obj.hStabLift.Data(:,1,:).^2,1)));
            Lift   = FLiftBdyP1 + FLiftBdyP2 + FLiftBdyP3;
            FDragBdyP1 = squeeze(sqrt(sum(obj.portWingDrag.Data(:,1,:).^2,1)));
            FDragBdyP2 = squeeze(sqrt(sum(obj.stbdWingDrag.Data(:,1,:).^2,1)));
            FDragBdyP3 = squeeze(sqrt(sum(obj.hStabDrag.Data(:,1,:).^2,1)));
            FDragBdyP4 = squeeze(sqrt(sum(obj.vStabDrag.Data(:,1,:).^2,1)));
            Drag = FDragBdyP1 + FDragBdyP2 + FDragBdyP3 + FDragBdyP4;
            Fuse = squeeze(sqrt(sum(obj.FFuseBdy.Data.^2,1)));
            Thr = squeeze(sqrt(sum(obj.thrDragVecs.Data.^2,1)));
        end
        function stats = plotAndComputeLapStats(obj)
            % local functions
            uVec = @(x,y)['$\hat{',x,'}_{\bar{',y,'}}$'];
            pathParam = squeeze(obj.currentPathVar.Data);
            lapsStarted = unique(obj.lapNumS.Data);
            plotLap = max(lapsStarted)-1;
            %  Determine Single Lap Indices
            lapNum = squeeze(obj.lapNumS.Data);
            Idx1 = find(lapNum == plotLap,1,'first');
            Idx2 = find(lapNum == plotLap,1,'last');
            if isempty(Idx1) || isempty(Idx2)
                error('Lap 1 was never started or finished. Simulate longer or reassess the meaning to your life')
            end
            ran = Idx1:Idx2;
            % plot path param
            plotParam = pathParam(ran) - plotLap + 1;
            % make subplot grid
            spSz = [3,5]; % grid size
            spGrid = reshape(1:15,spSz(2),[])';
            pIdx = 1;
            spIdx = 1;
            % assign graphic objects
            spAxes = gobjects;
            pObj   = gobjects;
            % plot vx
            G_vCM = squeeze(obj.velocityVec.Data);
            spAxes(spIdx) = subplot(spSz(1),spSz(2),spGrid(spIdx));
            pObj(pIdx) = plot(plotParam,G_vCM(1,ran));
            ylabel(['$v_{\mathrm{cm}}$.',uVec('i','O'),' (m/s)']);
            % plot vy
            spIdx = spIdx + 1; pIdx = pIdx + 1;
            spAxes(spIdx) = subplot(spSz(1),spSz(2),spGrid(spIdx));
            pObj(pIdx) = plot(plotParam,G_vCM(2,ran));
            ylabel(['$v_{\mathrm{cm}}$.',uVec('j','O'),' (m/s)']);
            % plot vz
            spIdx = spIdx + 1; pIdx = pIdx + 1;
            spAxes(spIdx) = subplot(spSz(1),spSz(2),spGrid(spIdx));
            pObj(pIdx) = plot(plotParam,G_vCM(3,ran));
            ylabel(['$v_{\mathrm{cm}}$.',uVec('k','O'),' (m/s)']);
            % plot v_Appx
            B_vApp = squeeze(obj.vhclVapp.Data);
            spIdx = spIdx + 1; pIdx = pIdx + 1;
            spAxes(spIdx) = subplot(spSz(1),spSz(2),spGrid(spIdx));
            pObj(pIdx) = plot(plotParam,B_vApp(1,ran));
            ylabel(['$v_{\mathrm{app}}$.',uVec('i','B'),' (m/s)']);
            % plot v_Appy
            spIdx = spIdx + 1; pIdx = pIdx + 1;
            spAxes(spIdx) = subplot(spSz(1),spSz(2),spGrid(spIdx));
            pObj(pIdx) = plot(plotParam,B_vApp(2,ran));
            ylabel(['$v_{\mathrm{app}}$.',uVec('j','B'),' (m/s)']);
            % plot v_Appz
            spIdx = spIdx + 1; pIdx = pIdx + 1;
            spAxes(spIdx) = subplot(spSz(1),spSz(2),spGrid(spIdx));
            pObj(pIdx) = plot(plotParam,B_vApp(3,ran));
            ylabel(['$v_{\mathrm{app}}$.',uVec('k','B'),' (m/s)']);
            % plot Euler
            euler = squeeze(obj.eulerAngles.Data)*180/pi;
            spIdx = spIdx + 1; pIdx = pIdx + 1;
            spAxes(spIdx) = subplot(spSz(1),spSz(2),spGrid(spIdx));
            pObj(pIdx) = plot(plotParam,euler(1,ran));
            ylabel('$\mathrm{\phi}$ (deg)');
            % plot vy
            spIdx = spIdx + 1; pIdx = pIdx + 1;
            spAxes(spIdx) = subplot(spSz(1),spSz(2),spGrid(spIdx));
            pObj(pIdx) = plot(plotParam,euler(2,ran));
            ylabel('$\mathrm{\theta}$ (deg)');
            % plot vz
            spIdx = spIdx + 1; pIdx = pIdx + 1;
            spAxes(spIdx) = subplot(spSz(1),spSz(2),spGrid(spIdx));
            pObj(pIdx) = plot(plotParam,euler(3,ran));
            ylabel('$\mathrm{\psi}$ (deg)');
            % plot tangent roll
            tanRoll = squeeze(obj.tanRoll.Data)*180/pi;
            spIdx = spIdx + 1; pIdx = pIdx + 1;
            spAxes(spIdx) = subplot(spSz(1),spSz(2),spGrid(spIdx));
            pObj(pIdx) = plot(plotParam,tanRoll(ran));
            ylabel('$\mathrm{\phi_{tan}}$ (deg)');
            % plot tangent pitch
            tanPitch = squeeze(obj.tanPitch.Data)*180/pi;
            spIdx = spIdx + 1; pIdx = pIdx + 1;
            spAxes(spIdx) = subplot(spSz(1),spSz(2),spGrid(spIdx));
            pObj(pIdx) = plot(plotParam,tanPitch(ran));
            ylabel('$\mathrm{\theta_{tan}}$ (deg)');
            % plot speed
           vhclSpeed = squeeze(obj.velocityVec.Data);
            vhclSpeed = vecnorm(vhclSpeed);
             spIdx = spIdx + 1; pIdx = pIdx + 1;
            spAxes(spIdx) = subplot(spSz(1),spSz(2),spGrid(spIdx));
            pObj(pIdx) = plot(plotParam,vhclSpeed(ran));
            ylabel('Speed (m/s)');
            % plot angle of attack
            AoA = squeeze(obj.vhclAngleOfAttack.Data);
            spIdx = spIdx + 1; pIdx = pIdx + 1;
            spAxes(spIdx) = subplot(spSz(1),spSz(2),spGrid(spIdx));
            pObj(pIdx) = plot(plotParam,AoA(ran));
            ylabel('AoA (deg)');
            % plot side slip angle
            SSA = squeeze(obj.vhclSideSlipAngle.Data);
            spIdx = spIdx + 1; pIdx = pIdx + 1;
            spAxes(spIdx) = subplot(spSz(1),spSz(2),spGrid(spIdx));
            pObj(pIdx) = plot(plotParam,SSA(ran));
            ylabel('SSA (deg)');
            % plot elevator deflection
            csDef = squeeze(obj.ctrlSurfDefl.Data);
            spIdx = spIdx + 1; pIdx = pIdx + 1;
            spAxes(spIdx) = subplot(spSz(1),spSz(2),spGrid(spIdx));
            pObj(pIdx) = plot(plotParam,csDef(ran,4));
            ylabel('$\mathrm{\delta e}$ (deg)');
            
            stats = computeSimLapStats(obj);
           
            % set all axis labels and stuff
            linStyleOrder = {'-','--',':o',};
            colorOrder = [228,26,28
                55,126,184
                77,175,74
                152,78,16]./255;
            
            xlabel(spAxes(1:spIdx),'Path parameter');
            grid(spAxes(1:spIdx),'on');
            hold(spAxes(1:spIdx),'on');
            set(spAxes(1:spIdx),'FontSize',11, ...
                'XTick',0:0.25:1,...
                'ColorOrder', colorOrder,...
                'LineStyleOrder', linStyleOrder);
            
            % set line properties
            set(pObj(1:pIdx),'LineWidth',1);
            
            % link axes
            linkaxes(spAxes(1:spIdx),'x');
            
            % compute some base statics
            % lap time
            lapTime = squeeze(obj.currentPathVar.Time(ran));
            lapTime = lapTime(end)-lapTime(1);
            % average apparent velocity in x direction cubed
            meanVappxCubed = mean(max(0,B_vApp(1,:)).^3);
            % distance traveled
            rCM = squeeze(obj.positionVec.Data);
            rCM = rCM(:,ran);
            disTraveled = sum(vecnorm(rCM(:,2:end) - rCM(:,1:end-1)));
            % avereage speed
            avgSpeed = mean(vhclSpeed);
            % title            
            sgtitle(sprintf(['Lap number = %d',', Lap time = %.2f sec',...
                ', Avg $v_{app,x}^3$ = %.2f',', Distace covered = %.2f m',...
                ', Avg speed = %.2f m/s'],...
                [plotLap,lapTime,meanVappxCubed,disTraveled,avgSpeed]),...
                'FontSize',11);

            
        end
        function Pow = rotPowerSummary(obj,vhcl,env,thr)
            [Idx1,Idx2] = obj.getLapIdxs(floor(max(obj.lapNumS.Data))-1);
            ran = Idx1:Idx2-1;
            [CLsurf,CDtot,CDnoThr] = obj.getCLCD(vhcl,thr);
            try
                C1 = cosd(squeeze(obj.elevationAngle.Data));  C2 = cosd(squeeze(obj.azimuthAngle.Data));
            catch
                try
                    C1 = cosd(squeeze(obj.elevation_slf.Data));  C2 = cosd(squeeze(obj.azimuth_slf.Data));
                catch
                    C1 = cosd(squeeze(obj.elevation_X_lem.Data));  C2 = cosd(squeeze(obj.azimuth_X_lem.Data));
                end
            end
            PLoyd = 2/27*env.water.density.Value*env.water.speed.Value^3*vhcl.fluidRefArea.Value*CLsurf.^3./CDtot.^2.*(C1.*C2).^3;%*.5;
            PLoydKite = 2/27*env.water.density.Value*env.water.speed.Value^3*vhcl.fluidRefArea.Value*CLsurf.^3./CDnoThr.^2.*(C1.*C2).^3;%*.5;
            Pow.loyd = mean(PLoyd)*1e-3;
            Pow.loydNT = mean(PLoydKite)*1e-3;
            Pow.turb = mean(obj.turbPow.Data(ran))*1e-3;
            Pow.elec = mean(obj.elecPow.Data(1,1,ran))*1e-3;
            try
                Pow.winch = mean(obj.winchPower.Data(ran))*1e-3;
                winchPwr = obj.winchPower.Data(ran)*1e-3;
            catch
                Pow.winch = 0;
                winchPwr = zeros(size(ran))';
            end
            Pow.ctrl = mean(obj.ctrlPowLoss.Data(1,1,ran))*1e-3;
            try
                Rthr = thr.tether1.resistance.Value;
                Ithr = obj.elecPow.Data(1,1,ran)/thr.tether1.transVoltage.Value;
            catch
                Rthr = 14;
                Ithr = obj.elecPow.Data(1,1,ran)/1e3;
            end
            Pow.loss = mean(Rthr*Ithr.^2);
            Pnet = (squeeze(obj.elecPow.Data(1,1,ran))-squeeze(Rthr*Ithr.^2)...
                -squeeze(obj.ctrlPowLoss.Data(1,1,ran))+winchPwr)*1e-3;
            Pow.net = mean(Pnet);
            Pow.max = max(Pnet);
            Pow.min = min(Pnet);
            fprintf('Lap power output:\nMech\t\t Elec\t\t Loyd Sys\t Loyd Kite\t Net\n%.3f kW\t %.3f kW\t %.3f kW\t %.3f kW\t %.3f kW\n',Pow.turb,Pow.elec,Pow.loyd,Pow.loydNT,Pow.net)
        end
        function Pow = rotPowerSummaryAir(obj,vhcl,env)
            [Idx1,Idx2] = obj.getLapIdxs(max(obj.lapNumS.Data)-1);
            ran = Idx1:Idx2-1;
            [CLsurf,CDtot] = getCLCD(obj,vhcl);
            C1 = cosd(squeeze(obj.elevationAngle.Data));  C2 = cosd(squeeze(obj.azimuthAngle.Data));
            PLoyd = 2/27*env.water.density.Value*env.water.speed.Value^3*vhcl.fluidRefArea.Value*CLsurf.^3./CDtot.^2.*(C1.*C2).^3/vhcl.turb1.axialInductionFactor.Value;
            Pow.loyd = mean(PLoyd)*1e-3;
            Pow.avg = mean(obj.turbPow.Data(1,1,ran))*1e-3;
            Pow.max = max(obj.turbPow.Data(1,1,ran))*1e-3;
            Pow.min = min(obj.turbPow.Data(1,1,ran))*1e-3;
            Pow.wnch = mean(obj.winchPower.Data(ran))*1e-3;
            fprintf('Lap power output:\nMin\t\t\t Max\t\t Avg\t\t Loyd\n%.3f kW\t %.3f kW\t %.3f kW\t %.3f kW\n',Pow.min,Pow.max,Pow.avg,Pow.loyd)
            fprintf('Avg Charge Time: %.1f days\n',270/Pow.avg/24)
        end
        function plotFSslf(obj,ctrl,varargin)
            p = inputParser;
            addOptional(p,'Steady',false,@islogical);
            parse(p,varargin{:})
            
            R = 3;  C = 1;
%             time = obj.MNetBdy.Time;
%             airNode = squeeze(sqrt(sum(obj.airTenVecs.Data.^2,1)))*1e-3;
%             gndNode = squeeze(sqrt(sum(obj.gndNodeTenVecs.Data.^2,1)))*1e-3;
%             coneWidth = ctrl.LaRelevationSPErr.Value;
            figure();
            %%  Plot Elevation Angle
            subplot(R,C,1); hold on; grid on;
            plot(obj.elevationSP_slf.Time,squeeze(obj.elevationSP_slf.Data),'r-');
            plot(obj.elevationAngle.Time,squeeze(obj.elevationAngle.Data),'b-');  xlabel('Time [s]');  ylabel('Elevation [deg]');  %xlim([1900 2100])
            %%  Plot Pitch Angle
            subplot(R,C,2); hold on; grid on;
            plot(obj.pitchSP_slf.Time,squeeze(obj.pitchSP_slf.Data),'r-');
            plot(obj.eulerAngles.Time,squeeze(obj.eulerAngles.Data(2,1,:))*180/pi,'b-');  xlabel('Time [s]');  ylabel('Pitch [deg]');
            legend('Setpoint','AutoUpdate','off','location','northwest')
            %%  Plot Elevator Command
            subplot(R,C,3); hold on; grid on;
            plot(obj.ctrlSurfDefl_slf.Time,squeeze(obj.ctrlSurfDefl_slf.Data(3,1,:)),'b-');  xlabel('Time [s]');  ylabel('Elevator [deg]');
%             %%  Tether Length
%             subplot(R,C,2); hold on; grid on;
%             plot(obj.tetherLengths.Time,squeeze(obj.tetherLengths.Data),'b-');  xlabel('Time [s]');  ylabel('Length [m]');  %xlim([1900 2100])
%             %%  Plot Spool Command
%             subplot(R,C,4); hold on; grid on;
%             plot(time,squeeze(obj.wnchCmd.Data),'b-');
%             xlabel('Time [s]');  ylabel('Winch [m/s]');  %xlim([1900 2100])
%             %%  Plot Tether Tension
%             subplot(R,C,6); hold on; grid on;
%             plot(time,airNode,'b-');  plot(time,gndNode,'r--');  %ylim([0 .5]);
%             xlabel('Time [s]');  ylabel('Tension [kN]');  legend('Kite','Glider');  %xlim([1900 2100])
        end
        function [Pow,LThr,EL,vFlow] = LoydPowerWThr(obj,vhcl,env,thr)
            Elev = squeeze(obj.elevationAngle.Data);
            LThr = sqrt(sum(vhcl.initPosVecGnd.Value.^2));
            vFlow = env.water.speed.Value;
            rho = env.water.density.Value;
            Aref = vhcl.fluidRefArea.Value;
            [Idx1,Idx2] = obj.getLapIdxs(max(obj.lapNumS.Data)-1);
            ran = Idx1:Idx2-1;
            EL = mean(Elev(ran));
            [CLsurf,CDtot] = getCLCD(obj,vhcl,thr);
            C1 = cosd(squeeze(obj.elevationAngle.Data));  C2 = cosd(squeeze(obj.azimuthAngle.Data));
            PLoyd = 2/27*rho*vFlow^3*Aref*CLsurf.^3./CDtot.^2.*(C1.*C2).^3/vhcl.turb1.axialInductionFactor.Value;
            Pavg = squeeze(obj.turbPow.Data(1,1,ran));
            Pow.loyd = mean(PLoyd(ran))*1e-3;
            Pow.avg = mean(obj.turbPow.Data(1,1,ran))*1e-3;
            Pow.Lfactor = mean(Pavg./PLoyd(ran));
            fprintf('Flow:\t %.2f m/s;\t Lthr: %.1f m;\t EL: %.2f deg\n',vFlow,LThr,EL);
            fprintf('Avg\t\t\t Loyd\t\t Factor\n%.3f kW\t %.3f kW\t %.3f\n\n',Pow.avg,Pow.loyd,Pow.Lfactor)
        end
        function plotFlightResultsEng(obj,vhcl,env,thr,varargin)
            %%  Parse Inputs
            p = inputParser;
            addOptional(p,'plot1Lap',false,@islogical);
            addOptional(p,'lapNum',1,@isnumeric);
            addOptional(p,'plotS',false,@islogical);
            addOptional(p,'cross',false,@islogical);
            addOptional(p,'AoASP',true,@islogical);
            addOptional(p,'maxTension',true,@islogical)
            addOptional(p,'plotBeta',false,@islogical);
            addOptional(p,'LiftDrag',false,@islogical);
            addOptional(p,'dragChar',false,@islogical);
            parse(p,varargin{:})
            
            R = 3;  C = 2;
            data = squeeze(obj.currentPathVar.Data);
            time = obj.lapNumS.Time;
            lap = p.Results.plot1Lap;
            con = p.Results.plotS;
            AoA = p.Results.AoASP;
            turb = isprop(obj,'turbPow');
            %%  Determine Single Lap Indices
            if lap
                [Idx1,Idx2] = getLapIdxs(obj,p.Results.lapNum);
                ran = Idx1:Idx2-1;
                lim = [time(Idx1) time(Idx2)];
            else
                lim = [time(1) time(end)];
            end
            %%  Compute Plotting Variables
            if turb
                N = vhcl.numTurbines.Value;
                if N == 1
                    power = squeeze(obj.turbPow.Data(1,1,:));
                    energy = cumtrapz(time,power)/1000/3600;
                else
                    power = squeeze(obj.turbPow.Data(1,1,:));
                    energy = cumtrapz(time,power)/1000/3600;
                    speed = (squeeze(obj.turbVelP.Data(1,1,:))+squeeze(obj.turbVelS.Data(1,1,:)))/2;
                end
            else
                power = squeeze(obj.winchPower.Data(:,1));
                energy = cumtrapz(time,power)/1000/3600;
            end
            vKite = -squeeze(obj.velCMvec.Data(1,:,:));
            %   Tether tension
            airNode = squeeze(sqrt(sum(obj.airTenVecs.Data.^2,1)))*1e-3;
            gndNode = squeeze(sqrt(sum(obj.gndNodeTenVecs.Data.^2,1)))*1e-3;
            %   Hydrocharacteristics
            [CLsurf,CDtot] = getCLCD(obj,vhcl,thr);
            FLiftBdyP1 = squeeze(sqrt(sum(obj.portWingLift.Data(:,1,:).^2,1)));
            FLiftBdyP2 = squeeze(sqrt(sum(obj.stbdWingLift.Data(:,1,:).^2,1)));
            FLiftBdyP3 = squeeze(sqrt(sum(obj.hStabLift.Data(:,1,:).^2,1)));
            FLiftBdy   = FLiftBdyP1 + FLiftBdyP2 + FLiftBdyP3;
            FDragBdyP1 = squeeze(sqrt(sum(obj.portWingDrag.Data(:,1,:).^2,1)));
            FDragBdyP2 = squeeze(sqrt(sum(obj.stbdWingDrag.Data(:,1,:).^2,1)));
            FDragBdyP3 = squeeze(sqrt(sum(obj.hStabDrag.Data(:,1,:).^2,1)));
            FDragBdyP4 = squeeze(sqrt(sum(obj.vStabDrag.Data(:,1,:).^2,1)));
            FDragBdy = FDragBdyP1 + FDragBdyP2 + FDragBdyP3 + FDragBdyP4;
            FDragFuse = squeeze(sqrt(sum(obj.FFuseBdy.Data.^2,1)));
            FDragThr = squeeze(sqrt(sum(obj.thrDragVecs.Data.^2,1)));
            if turb
                FTurbBdy = squeeze(sqrt(sum(obj.FTurbBdy.Data.^2,1)));
                totDrag = (FDragBdy + FTurbBdy + FDragFuse + FDragThr);
                LiftDrag = FLiftBdy./(FDragBdy + FTurbBdy + FDragFuse );
            else
                totDrag = (FDragBdy + FDragFuse + FDragThr);
                LiftDrag = FLiftBdy./(FDragBdy + FDragFuse);
            end
            C1 = cosd(squeeze(obj.elevationAngle.Data));  C2 = cosd(squeeze(obj.azimuthAngle.Data));
            if turb
                PLoyd = 2/27*env.water.density.Value*env.water.speed.Value^3*vhcl.fluidRefArea.Value*CLsurf.^3./CDtot.^2.*(C1.*C2).^3/vhcl.turb1.axialInductionFactor.Value;
                vLoyd = LiftDrag.*env.water.speed.Value.*(C1.*C2);
            else
                PLoyd = 2/27*env.water.density.Value*env.water.speed.Value^3*vhcl.fluidRefArea.Value*CLsurf.^3./CDtot.^2.*(C1.*C2).^3;
                vLoyd = LiftDrag.*env.water.speed.Value.*(C1.*C2)*2/3;
            end
            figure();
            %%  Plot Power Output
            ax1 = subplot(R,C,1);
            hold on; grid on
            yyaxis left
            if lap
                if con
                    plot(data(ran),power(ran)*1e-3,'b-');  ylabel('Power [kW]');  set(gca,'YColor',[0 0 1])
                    %         plot(data(ran),PLoyd(ran)*1e-3,'b--');  ylabel('Power [kW]');  legend('Kite','Loyd','location','southeast','AutoUpdate','off');  ylim([0 inf]);
                    %         text(0.04,310,sprintf('P = %.3f kW',mean(powAvg)*1e-3))
                else
                    plot(time(ran),power(ran)*1e-3,'b-');  ylabel('Power [kW]');  set(gca,'YColor',[0 0 1]);  xlim(lim);  ylim([0 inf]);
                    %         plot(time(ran),PLoyd(ran)*1e-3,'b--');  ylabel('Power [kW]');  legend('Kite','Loyd','location','southeast','AutoUpdate','off');  ylim([0 inf]);
                end
            else
                plot(time,power*1e-3,'b-');  ylabel('Power [kW]');  set(gca,'YColor',[0 0 1]);  xlim(lim);  ylim([0 inf]);
                %     plot(time,PLoyd*1e-3,'b--');  ylabel('Power [kW]');  legend('Kite','Loyd','location','southeast','AutoUpdate','off');  ylim([0 inf]);
            end
            yyaxis right
            if lap
                if con
                    plot(data(ran),energy(ran)-energy(Idx1),'r-');  ylabel('Energy [kWh]');  set(gca,'YColor',[1 0 0])
                else
                    plot(time(ran),energy(ran)-energy(Idx1),'r-');  ylabel('Energy [kWh]');  set(gca,'YColor',[1 0 0]);  xlim(lim)
                end
            else
                plot(time,energy,'r-');  ylabel('Energy [kWh]');  set(gca,'YColor',[1 0 0]);  xlim(lim)
            end
            %%  Plot Tether Tension
            scT = 0.224809*1000;
            ax2 = subplot(R,C,2); hold on; grid on
            if p.Results.maxTension
                Tmax = (obj.maxTension.Data+0.5)*ones(numel(time),1);
            else
                Tmax = (0*ones(numel(time),1));
            end
            if lap
                if con
                    plot(data(ran),Tmax(ran)*scT,'r--');    plot(data(ran),airNode(ran)*scT,'b-');
                    plot(data(ran),gndNode(ran)*scT,'g-');  ylabel('Thr Tension [lb]');  legend('Limit','Kite','Glider')
                else
                    plot(time(ran),Tmax(ran)*scT,'r--');    plot(time(ran),airNode(ran)*scT,'b-');
                    plot(time(ran),gndNode(ran)*scT,'g-');  ylabel('Thr Tension [lb]');  legend('Limit','Kite','Glider');  xlim(lim)
                end
            else
                plot(time,Tmax*scT,'r--');  plot(time,airNode*scT,'b-');  plot(time,gndNode*scT,'g-');
                ylabel('Thr Tension [lb]');  legend('Limit','Kite','Glider');  xlim(lim)
            end
            %%  Plot Speed
            ax3 = subplot(R,C,3); hold on; grid on
            scV = 1.94384;
            if lap
                if con
                    if ~turb
                        plot(data(ran),speed(ran)*scV,'g-');  ylabel('Speed [kts]');  ylim([0,inf])
                        plot(data(ran),vKite(ran)*scV,'b-');  ylabel('Speed [kts]');  legend('Turb','Kite','location','southeast');
                    else
                        plot(data(ran),vKite(ran)*scV,'b-');  ylabel('Speed [kts]');  ylim([0,inf])
                    end
                else
                    if ~turb
                        plot(time(ran),speed(ran)*scV,'g-');  ylabel('Speed [kts]');  xlim(lim);  ylim([0,inf])
                        plot(time(ran),vKite(ran)*scV,'b-');  ylabel('Speed [kts]');  legend('Turb','Kite','location','southeast');
                    else
                        plot(time(ran),vKite(ran)*scV,'b-');  ylabel('Speed [kts]');  ylim([0,inf])
                    end
                end
            else
                if ~turb
                    plot(time,speed*scV,'g-');  ylabel('Speed [kts]');  xlim(lim)
                    plot(time,vKite*scV,'b-');  ylabel('Speed [kts]');  ylim([0,inf]);  legend('Turb','Kite','location','southeast');
                else
                    plot(time,vKite*scV,'b-');  ylabel('Speed [kts]');
                end
            end
            %%  Plot Angle of attack
            ax4 = subplot(R,C,4); hold on; grid on
            if lap
                if con
                    if p.Results.AoASP
                        plot(data(ran),obj.AoASP.Data(ran)*180/pi,'r-','DisplayName','Setpoint');
                    end
                    plot(data(ran),squeeze(obj.vhclAngleOfAttack.Data(ran)),'b-','DisplayName','AoA');
                    ylabel('Angle [deg]');
                    if p.Results.plotBeta
                        plot(data(ran),squeeze(obj.betaBdy.Data(1,1,ran))*180/pi,'g-','DisplayName','Beta');  ylabel('Angle [deg]');
                    end
                    legend;
                else
                    plot(time(ran),obj.AoASP.Data(ran)*180/pi,'r-','DisplayName','Setpoint');
                    plot(time(ran),squeeze(obj.vhclAngleOfAttack.Data(ran)),'b-','DisplayName','AoA');
                    ylabel('Angle [deg]');  xlim(lim);
                    if p.Results.plotBeta
                        plot(time(ran),squeeze(obj.betaBdy.Data(1,1,ran))*180/pi,'g-','DisplayName','Beta');  ylabel('Angle [deg]');   xlim(lim)
                    end
                    legend;
                end
            else
                plot(time,obj.AoASP.Data*180/pi,'r-');
                plot(time,squeeze(obj.vhclAngleOfAttack.Data),'b-'); ylim([0 20]);
                ylabel('Angle [deg]');  xlim(lim);  legend('Setpoint','AoA');
                if p.Results.plotBeta
                    plot(time,squeeze(obj.betaBdy.Data(1,1,:))*180/pi,'g-');  ylabel('Angle [deg]');  legend('Port AoA','Stbd AoA','Beta');  xlim(lim)
                end
            end
            
            %%  Plot Ctrl Surface Deflection
            ax5 = subplot(R,C,6); hold on; grid on
            if lap
                if con
                    plot(data(ran),squeeze(obj.ctrlSurfDefl.Data(ran,1)),'b-');  xlabel('Path Position');  ylabel('Deflection [deg]');
                    plot(data(ran),squeeze(obj.ctrlSurfDefl.Data(ran,3)),'r-');  xlabel('Path Position');  ylabel('Deflection [deg]');
                    plot(data(ran),squeeze(obj.ctrlSurfDefl.Data(ran,4)),'g-');  xlabel('Path Position');  ylabel('Deflection [deg]');
                else
                    plot(time(ran),squeeze(obj.ctrlSurfDefl.Data(ran,1)),'b-');  xlabel('Time [s]');  ylabel('Deflection [deg]');  xlim(lim)
                    plot(time(ran),squeeze(obj.ctrlSurfDefl.Data(ran,3)),'r-');  xlabel('Time [s]');  ylabel('Deflection [deg]');  xlim(lim)
                    plot(time(ran),squeeze(obj.ctrlSurfDefl.Data(ran,4)),'g-');  xlabel('Time [s]');  ylabel('Deflection [deg]');  xlim(lim)
                end
            else
                plot(time,squeeze(obj.ctrlSurfDefl.Data(:,1)),'b-');  xlabel('Time [s]');  ylabel('Deflection [deg]');  xlim(lim)
                plot(time,squeeze(obj.ctrlSurfDefl.Data(:,3)),'r-');  xlabel('Time [s]');  ylabel('Deflection [deg]');  xlim(lim)
                plot(time,squeeze(obj.ctrlSurfDefl.Data(:,4)),'g-');  xlabel('Time [s]');  ylabel('Deflection [deg]');  xlim(lim)
            end
            legend('P-Aileron','Elevator','Rudder')
            %%  Plot Lift-Drag ratio
            ax6 = subplot(R,C,5); hold on; grid on
            yyaxis left
            if lap
                if con
                    plot(data(ran),totDrag(ran)*1e-3*scT,'r-');    xlabel('Path Position');  ylabel('Force [lb]');  set(gca,'YColor',[0 0 0])
                    plot(data(ran),FLiftBdy(ran)*1e-3*scT,'b-');   xlabel('Path Position');  ylabel('Force [lb]');  legend('Drag','Lift')
                else
                    plot(time(ran),totDrag(ran)*1e-3*scT,'r-');    xlabel('Time [s]');  ylabel('Force [lb]');  set(gca,'YColor',[0 0 0])
                    plot(time(ran),FLiftBdy(ran)*1e-3*scT,'b-');   xlabel('Time [s]');  ylabel('Force [lb]');  legend('Drag','Lift') ;  xlim(lim);
                end
            else
                plot(time,totDrag*1e-3*scT,'r-');    xlabel('Time [s]');  ylabel('Force [lb]');  set(gca,'YColor',[0 0 0])
                plot(time,FLiftBdy*1e-3*scT,'b-');   xlabel('Time [s]');  ylabel('Force [lb]');  legend('Drag','Lift') ;  xlim(lim);
            end
            yyaxis right
            if lap
                if con
                    plot(data(ran),CLsurf(ran),'b--');    xlabel('Path Position');  set(gca,'YColor',[0 0 0])
                    plot(data(ran),CDtot(ran),'r--');   xlabel('Path Position');  ylabel('CD and CL');  legend('Drag','Lift','CL','CD')
                else
                    plot(time(ran),CLsurf(ran),'b--');    xlabel('Time [s]');  set(gca,'YColor',[0 0 0])
                    plot(time(ran),CDtot(ran),'r--');   xlabel('Time [s]');  ylabel('CD and CL');  legend('Drag','Lift','CL','CD') ;  xlim(lim);
                end
            else
                plot(time,CLsurf,'b--');    xlabel('Time [s]');  set(gca,'YColor',[0 0 0])
                plot(time,CDtot,'r--');   xlabel('Time [s]');  ylabel('CD and CL');  legend('Drag','Lift','CL','CD') ;  xlim(lim);
            end
            % figure; hold on; grid on
            % plot(data(ran),CDtot(ran),'r-');  xlabel('Path Position');  ylabel('');
            % plot(data(ran),CLsurf(ran),'b-');  xlabel('Path Position');  ylabel('');
            linkaxes([ax1 ax2 ax3 ax4 ax5 ax6],'x');
            % legend('CD','CL')
            %%  Plot Drag Characteristics
            if turb && p.Results.dragChar && con
                figure(); subplot(2,1,2); hold on; grid on
                plot(time,FTurbBdy./(totDrag-FTurbBdy),'b-');
                plot(time,.5*ones(length(time),1),'r-');
                xlabel('Path Position');  ylabel('$\mathrm{D_t/D_k}$');  ylim([0 1]);
                subplot(2,1,1); hold on; grid on
                plot(time,FDragBdy,'b-');
                plot(time,FDragFuse,'r-');
                plot(time,FDragThr,'g-');
                plot(time,FTurbBdy,'c-');
                plot(time,totDrag,'k-');
                xlabel('Path Position');  ylabel('Drag [N]');  legend('Surf','Fuse','Thr','Turb','Tot');
            end
            %%  Assess cross-current flight performance
            if p.Results.cross
                figure;
                subplot(3,1,1); hold on; grid on
                if lap
                    if con
                        plot(data(ran),squeeze(obj.velAngleError.Data(1,1,ran))*180/pi,'r-');    xlabel('Path Position');  ylabel('Angle Error [deg]');
                        plot(data(ran),squeeze(obj.tanRollError.Data(ran))*180/pi,'b-');   xlabel('Path Position');  ylabel('Angle Error [deg]');  legend('Velocity','Tan Roll');
                    else
                        plot(time(ran),squeeze(obj.velAngleError.Data(1,1,ran))*180/pi,'r-');    xlabel('Time [s]');  ylabel('Angle Error [deg]');
                        plot(time(ran),squeeze(obj.tanRollError.Data(ran))*180/pi,'b-');   xlabel('Time [s]');  ylabel('Angle Error [deg]');  legend('Velocity','Tan Roll');  xlim(lim);
                    end
                else
                    plot(time,squeeze(obj.velAngleError.Data(1,1,:))*180/pi,'r-');    xlabel('Time [s]');  ylabel('Angle Error [deg]');
                    plot(time,squeeze(obj.tanRollError.Data(:))*180/pi,'b-');   xlabel('Time [s]');  ylabel('Angle Error [deg]');  legend('Velocity','Tan Roll');  xlim(lim);
                end
                subplot(3,1,2); hold on; grid on
                if lap
                    if con
                        plot(data(ran),squeeze(obj.ctrlSurfDefl.Data(ran,1)),'r-');    xlabel('Path Position');  ylabel('Angle [deg]');
                        plot(data(ran),squeeze(obj.ctrlSurfDefl.Data(ran,2)),'b-');    xlabel('Path Position');  ylabel('Angle [deg]');  legend('Port','Stbd');
                    else
                        plot(time(ran),squeeze(obj.ctrlSurfDefl.Data(ran,1)),'r-');    xlabel('Time [s]');  ylabel('Angle [deg]');
                        plot(time(ran),squeeze(obj.ctrlSurfDefl.Data(ran,2)),'b-');    xlabel('Time [s]');  ylabel('Angle [deg]');  legend('Port','Stbd');  xlim(lim);
                    end
                else
                    plot(time,squeeze(obj.ctrlSurfDefl.Data(:,1)),'r-');    xlabel('Time [s]');  ylabel('Angle [deg]');
                    plot(time,squeeze(obj.ctrlSurfDefl.Data(:,2)),'b-');    xlabel('Time [s]');  ylabel('Angle [deg]');  legend('Port','Stbd');  xlim(lim);
                end
                subplot(3,1,3); hold on; grid on
                if lap
                    if con
                        plot(data(ran),squeeze(obj.desiredMoment.Data(ran,1)),'r-');    xlabel('Path Position');  ylabel('Roll Moment [N]');
                        plot(data(ran),squeeze(obj.MFluidBdy.Data(1,1,ran)),'b-');   xlabel('Path Position');  ylabel('Roll Moment [N]');  legend('Desired','Actual');
                    else
                        plot(time(ran),squeeze(obj.desiredMoment.Data(ran,1)),'r-');    xlabel('Time [s]');  ylabel('Roll Moment [N]');
                        plot(time(ran),squeeze(obj.MFluidBdy.Data(1,1,ran)),'b-');   xlabel('Time [s]');  ylabel('Roll Moment [N]');  legend('Desired','Actual');  xlim(lim);
                    end
                else
                    plot(time,squeeze(obj.desiredMoment.Data(:,1)),'r-');    xlabel('Time [s]');  ylabel('Roll Moment [N]');
                    plot(time,squeeze(obj.MFluidBdy.Data(1,1,:)),'b-');   xlabel('Time [s]');  ylabel('Roll Moment [N]');  legend('Desired','Actual');  xlim(lim);
                end
            end
        end
      
        function rotMat(obj)
            eul = squeeze(obj.eulerAngles.Data);
            time = obj.eulerAngles.Time;
            
            roll = eul(1,:); 
            cr = cos(roll); 
            sr = sin(roll);
            
            pitch = eul(2,:);
            cp = cos(pitch);
            sp = sin(pitch);
            
            yaw = eul(3,:);
            cy = cos(yaw);
            sy = sin(yaw);
            for i = 1:numel(yaw)
            Rx = [1 0 0; 0 cr(i) sr(i); 0 -sr(i) cr(i)];
            Ry = [cp(i) 0 -sp(i); 0 1 0;sp(i) 0 cp(i)];
            Rz = [cy(i) sy(i) 0; -sy(i) cy(i) 0; 0 0 1];
            rotMat(:,:,i) = (Rx*Ry*Rz)';
            rotMat1(:,:,i) = rotMat(:,:,i)';
            end
            
            try
                obj.addprop('OcK');
            end
            try
                obj.addprop('KcO');
            end
            obj.OcK = timeseries(rotMat,time);
            obj.KcO = timeseries(rotMat1,time);
        end
    end
end

