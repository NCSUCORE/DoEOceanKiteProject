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
                                warning('Duplicate signal names: ''%s''.  Taking first found signal.',ts{1}.Name)
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
            plot(obj.ctrlSurfDeflCmd.Time,squeeze(obj.ctrlSurfDeflCmd.Data(3,:,:)),'b-');  
            xlabel('Time [s]');  ylabel('Elevator [deg]');
        end
        function [CLsurf,CDtot] = getCLCD(obj,vhcl)
            Aref = vhcl.fluidRefArea.Value;
            Afuse = squeeze(obj.Afuse.Data);
            CDfuse = squeeze(obj.CDfuse.Data).*Afuse/Aref;
            CDsurf = squeeze(obj.portWingCD.Data+obj.stbdWingCD.Data+obj.hStabCD.Data+obj.vStabCD.Data);
            CDtot = CDfuse+CDsurf;
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
            pObj(pIdx) = plot(pathParam(ran),G_vCM(1,ran));
            ylabel(['$v_{\mathrm{cm}}$.',uVec('i','O'),' (m/s)']);
            % plot vy
            spIdx = spIdx + 1; pIdx = pIdx + 1;
            spAxes(spIdx) = subplot(spSz(1),spSz(2),spGrid(spIdx));
            pObj(pIdx) = plot(pathParam(ran),G_vCM(2,ran));
            ylabel(['$v_{\mathrm{cm}}$.',uVec('j','O'),' (m/s)']);
            % plot vz
            spIdx = spIdx + 1; pIdx = pIdx + 1;
            spAxes(spIdx) = subplot(spSz(1),spSz(2),spGrid(spIdx));
            pObj(pIdx) = plot(pathParam(ran),G_vCM(3,ran));
            ylabel(['$v_{\mathrm{cm}}$.',uVec('k','O'),' (m/s)']);
            % plot v_Appx
            B_vApp = squeeze(obj.vhclVapp.Data);
            spIdx = spIdx + 1; pIdx = pIdx + 1;
            spAxes(spIdx) = subplot(spSz(1),spSz(2),spGrid(spIdx));
            pObj(pIdx) = plot(pathParam(ran),B_vApp(1,ran));
            ylabel(['$v_{\mathrm{app}}$.',uVec('i','B'),' (m/s)']);
            % plot v_Appy
            spIdx = spIdx + 1; pIdx = pIdx + 1;
            spAxes(spIdx) = subplot(spSz(1),spSz(2),spGrid(spIdx));
            pObj(pIdx) = plot(pathParam(ran),B_vApp(2,ran));
            ylabel(['$v_{\mathrm{app}}$.',uVec('j','B'),' (m/s)']);
            % plot v_Appz
            spIdx = spIdx + 1; pIdx = pIdx + 1;
            spAxes(spIdx) = subplot(spSz(1),spSz(2),spGrid(spIdx));
            pObj(pIdx) = plot(pathParam(ran),B_vApp(3,ran));
            ylabel(['$v_{\mathrm{app}}$.',uVec('k','B'),' (m/s)']);
            % plot Euler
            euler = squeeze(obj.eulerAngles.Data)*180/pi;
            spIdx = spIdx + 1; pIdx = pIdx + 1;
            spAxes(spIdx) = subplot(spSz(1),spSz(2),spGrid(spIdx));
            pObj(pIdx) = plot(pathParam(ran),euler(1,ran));
            ylabel('$\mathrm{\phi}$ (deg)');
            % plot vy
            spIdx = spIdx + 1; pIdx = pIdx + 1;
            spAxes(spIdx) = subplot(spSz(1),spSz(2),spGrid(spIdx));
            pObj(pIdx) = plot(pathParam(ran),euler(2,ran));
            ylabel('$\mathrm{\theta}$ (deg)');
            % plot vz
            spIdx = spIdx + 1; pIdx = pIdx + 1;
            spAxes(spIdx) = subplot(spSz(1),spSz(2),spGrid(spIdx));
            pObj(pIdx) = plot(pathParam(ran),euler(3,ran));
            ylabel('$\mathrm{\psi}$ (deg)');
            % plot tangent roll
            tanRoll = squeeze(obj.tanRoll.Data)*180/pi;
            spIdx = spIdx + 1; pIdx = pIdx + 1;
            spAxes(spIdx) = subplot(spSz(1),spSz(2),spGrid(spIdx));
            pObj(pIdx) = plot(pathParam(ran),tanRoll(ran));
            ylabel('$\mathrm{\phi_{tan}}$ (deg)');
            % plot tangent pitch
            tanPitch = squeeze(obj.tanPitch.Data)*180/pi;
            spIdx = spIdx + 1; pIdx = pIdx + 1;
            spAxes(spIdx) = subplot(spSz(1),spSz(2),spGrid(spIdx));
            pObj(pIdx) = plot(pathParam(ran),tanPitch(ran));
            ylabel('$\mathrm{\theta_{tan}}$ (deg)');
            % plot speed
           vhclSpeed = squeeze(obj.velocityVec.Data);
            vhclSpeed = vecnorm(vhclSpeed);
             spIdx = spIdx + 1; pIdx = pIdx + 1;
            spAxes(spIdx) = subplot(spSz(1),spSz(2),spGrid(spIdx));
            pObj(pIdx) = plot(pathParam(ran),vhclSpeed(ran));
            ylabel('Speed (m/s)');
            % plot angle of attack
            AoA = squeeze(obj.vhclAngleOfAttack.Data);
            spIdx = spIdx + 1; pIdx = pIdx + 1;
            spAxes(spIdx) = subplot(spSz(1),spSz(2),spGrid(spIdx));
            pObj(pIdx) = plot(pathParam(ran),AoA(ran));
            ylabel('AoA (deg)');
            % plot side slip angle
            SSA = squeeze(obj.vhclSideSlipAngle.Data);
            spIdx = spIdx + 1; pIdx = pIdx + 1;
            spAxes(spIdx) = subplot(spSz(1),spSz(2),spGrid(spIdx));
            pObj(pIdx) = plot(pathParam(ran),SSA(ran));
            ylabel('SSA (deg)');
            % plot elevator deflection
            csDef = squeeze(obj.ctrlSurfDeflCmd.Data);
            spIdx = spIdx + 1; pIdx = pIdx + 1;
            spAxes(spIdx) = subplot(spSz(1),spSz(2),spGrid(spIdx));
            pObj(pIdx) = plot(pathParam(ran),csDef(ran,4));
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
                'XTick',plotLap-1:0.25:plotLap,...
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
        function Pow = rotPowerSummary(obj,vhcl,env)
            [Idx1,Idx2] = obj.getLapIdxs(max(obj.lapNumS.Data)-1);
            ran = Idx1:Idx2-1;
            [CLsurf,CDtot] = getCLCD(obj,vhcl);
            C1 = cosd(squeeze(obj.elevationAngle.Data));  C2 = cosd(squeeze(obj.azimuthAngle.Data));
            PLoyd = 2/27*env.water.density.Value*env.water.speed.Value^3*vhcl.fluidRefArea.Value*CLsurf.^3./CDtot.^2.*(C1.*C2).^3/vhcl.turb1.axialInductionFactor.Value;
            Pow.loyd = mean(PLoyd)*1e-3;
            Pow.avg = mean(obj.turbPow.Data(1,1,ran)+obj.turbPow.Data(1,2,ran))*1e-3;
            Pow.max = max(obj.turbPow.Data(1,1,ran)+obj.turbPow.Data(1,2,ran))*1e-3;
            Pow.min = min(obj.turbPow.Data(1,1,ran)+obj.turbPow.Data(1,2,ran))*1e-3;
            fprintf('Lap power output:\nMin\t\t Max\t\t Avg\t\t Loyd\n%.3f kW\t %.3f kW\t %.3f kW\t %.3f kW\n',Pow.min,Pow.max,Pow.avg,Pow.loyd)
            fprintf('Avg Charge Time: %.1f days\n',270/Pow.avg/24)
        end
    end
end

