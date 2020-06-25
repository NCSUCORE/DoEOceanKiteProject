classdef Manta < handle
    % Manta class to hold Manta data
    properties (SetAccess = private)
        density
        startTime
        endTime
        flowVecTimeseries
        xGridPoints
        yGridPoints
        zGridPoints
        maxSpeed
        minSpeed
        month
    end
    
    properties (Hidden = true)
        % Property to hold all flow data, hidden from the user
        allFlowVecTimeseries
    end
    
    methods
        function obj = Manta(mnthIndx,varargin)
            % Input mnthIndx is a single element of [1 4 7 10] indicating
            % which month of data that you want to use, and then dayIndx
            % is the index of the day within that month that you'd like to
            % use
            p = inputParser;
            addRequired(p,'mnthIndx',@(x) mod(x,1)==0);
            addOptional(p,'ForceRecompile',false,@(x) islogical(x));
            parse(p,mnthIndx,varargin{:})
            % Get base path to where the model is stored on your computer
            basePath = fileparts(which('OCTModel'));
            % Append path to include the location of this classdef
            dataPath = fullfile(basePath,'classes','+ENV','@Manta');
            % Get a list of all files in that location
            folders = dir(dataPath);
            % Filter list to include only directories (no .m files, etc)
            folders = folders([folders.isdir]);
            % Drop the first two, which are just . and ..
            folders = folders(3:end);
            % Build two-character string for the month and day numbers
            mnthString = sprintf('%02d',p.Results.mnthIndx);
            % Get the name of the .mat file that should contain this data
            fName = fullfile(dataPath,['TS_FlowData_2017_',mnthString '.mat']);
            % If it doesn't exist, then attempt to build it
            if ~isfile(fName) || p.Results.ForceRecompile
                % Check if the folder for that data exists
                folder = folders(contains({folders.name},['2017' mnthString '_hourly']));
                if isempty(folder)
                    error('Unknown month')
                elseif numel(folder)>1
                    error('Multiple matching months')
                end
                % Get files in that folder
                files = dir(fullfile(folder.folder,folder.name));
                % Get files that match the specified day
                % Ignore the first 2 items
                files = files(3:end);
                % If the list of files is empty, throw an error
                if isempty(files)
                    error('Unknown day')
                end
                % Build the .mat file
%                 [data,xBreak,yBreak,zBreak] = obj.buildMantaMAT(files);
                [data,xBreak,yBreak,zBreak] = obj.buildMantaMAT2(files);
                save(fName,'data','xBreak','yBreak','zBreak');
            else
                load(fName);
            end
            % Build the vector of timestamps
            timeVec = 0:size(data,5)-1;
            obj.density                 = SIM.parameter('Unit','kg/m^3');
            obj.allFlowVecTimeseries    = SIM.parameter('Value',timeseries(data,3600*timeVec),'Unit','m/s');
            obj.startTime               = SIM.parameter('Value',3600*timeVec(1),'Unit','s');
            obj.endTime                 = SIM.parameter('Value',3600*timeVec(end),'Unit','s');
            obj.flowVecTimeseries       = SIM.parameter('Unit','m/s');
            obj.xGridPoints             = SIM.parameter('Value',xBreak,'Unit','m');
            obj.yGridPoints             = SIM.parameter('Value',yBreak,'Unit','m');
            obj.zGridPoints             = SIM.parameter('Value',zBreak,'Unit','m');
            obj.month                   = SIM.parameter('Value',p.Results.mnthIndx,'Unit','','NoScale',true);
            obj.crop(obj.startTime.Value,obj.endTime.Value); % Sets the 
        end
        function setDensity(obj,val,unit)
            obj.density.setValue(val,unit);
        end
        function setStartTime(obj,val,unit)
            obj.startTime.setValue(val,unit);
            obj.crop(obj.startTime.Value,obj.endTime.Value);
        end
        function setEndTime(obj,val,unit)
            obj.endTime.setValue(val,unit);
            obj.crop(obj.startTime.Value,obj.endTime.Value);
        end
        function setFlowVecTimeseries(obj,val,unit)
            obj.flowVecTimeseries.setValue(val,unit);
        end
        function setXGridPoints(obj,val,unit)
            % Might want to write code here to throw error/warning if it
            % doesn't match preexising dimensions
            obj.xGridPoints.setValue(val,unit)
        end
        function setYGridPoints(obj,val,unit)
            % Might want to write code here to throw error/warning if it
            % doesn't match preexising dimensions
            obj.yGridPoints.setValue(val,unit)
        end
        function setZGridPoints(obj,val,unit)
            % Might want to write code here to throw error/warning if it
            % doesn't match preexising dimensions
            obj.zGridPoints.setValue(val,unit);
        end
        
        function crop(obj,startTime,endTime)
            % Set endTime to max possible value
            endTime = min([endTime ...
                obj.allFlowVecTimeseries.Value.Time(end)]);
            startTime = max([startTime ...
                obj.allFlowVecTimeseries.Value.Time(1)]);
            % --Crop flow velocity vector timeseries--
            ts = getsampleusingtime(obj.allFlowVecTimeseries.Value,startTime,endTime);
            ts.Time = ts.Time-ts.Time(1);
            obj.setFlowVecTimeseries(ts,'m/s');
        end
        
        function val = get.maxSpeed(obj)
            val = max(sqrt(sum(obj.flowVecTimeseries.Value.Data.^2,4)),[],'all');
            val = SIM.parameter('Value',val,'Unit','m/s');
        end
        
        function val = get.minSpeed(obj)
            val = min(sqrt(sum(obj.flowVecTimeseries.Value.Data.^2,4)),[],'all');
            val = SIM.parameter('Value',val,'Unit','m/s');
        end
            
        
        function h = animateVecs(obj,varargin)
            if numel(obj.flowVecTimeseries.Value.Time)<2
                defaultTimeStep = 3600;
            else
                defaultTimeStep = obj.flowVecTimeseries.Value.Time(2)-obj.flowVecTimeseries.Value.Time(1);
            end
            
            p = inputParser;
            addParameter(p,'Cropped',true,@islogical);
            addParameter(p,'FontSize',get(0,'DefaultAxesFontSize'),@isnumeric);
            addParameter(p,'Title','Manta Flow Speed',@ischar);
            addParameter(p,'TimeUnits','s',@ischar);
            addParameter(p,'TimeStep',defaultTimeStep,@isnumeric);
            addParameter(p,'View',[40 40],@isnumeric);
            addOptional(p,'zIdx',obj.zGridPoints.Value,@isnumeric);
            parse(p,varargin{:})
            
            obj.flowVecTimeseries.Value.resample(obj.flowVecTimeseries.Value.Time(1):p.Results.TimeStep:obj.flowVecTimeseries.Value.Time(end));
            
            switch lower(p.Results.TimeUnits)
                case {'min','m'}
                    denom = 60;
                case {'hr','h'}
                    denom = 3600;
                otherwise
                    denom = 1;
            end
            timeVec = obj.flowVecTimeseries.Value.Time./denom;
            % Find water column with greatest avg flow velocity 
            [xIdx,yIdx] = obj.colOpt;
            numTimeSteps = numel(timeVec);
            zIdx = p.Results.zIdx;
            % Plot the initial data
            [x,y,z] = meshgrid(...
                obj.xGridPoints.Value(xIdx),...
                obj.yGridPoints.Value(yIdx),...
                obj.zGridPoints.Value(zIdx));
            x = squeeze(permute(x,[2 1 3]));
            y = squeeze(permute(y,[2 1 3]));
            z = squeeze(permute(z,[2 1 3]));
            figure('units','normalized','outerposition',[0 0 1 1])
            h.vecPlot = quiver3(...
                x,y,z,...
                squeeze(obj.flowVecTimeseries.Value.Data(xIdx,xIdx,zIdx,1,1)),...
                squeeze(obj.flowVecTimeseries.Value.Data(xIdx,xIdx,zIdx,2,1)),...
                squeeze(obj.flowVecTimeseries.Value.Data(xIdx,xIdx,zIdx,3,1)));
            %             daspect([1 1 1])
            xlabel('x [m]')
            ylabel('y [m]')
            ylabel('z [m]')
            xlim([obj.xGridPoints.Value(xIdx)-500 obj.xGridPoints.Value(xIdx)+500])
            ylim([obj.yGridPoints.Value(yIdx)-500 obj.yGridPoints.Value(yIdx)+500])
            zlim([-350 0])
            h.title = title(sprintf('Time: %.0f %s',timeVec(1),p.Results.TimeUnits));
            set(findall(gcf,'Type','axes'),'FontSize',p.Results.FontSize);
            view(p.Results.View) % Set view angle azimuth and elevation
            for ii = 2:numTimeSteps
                h.vecPlot.UData = squeeze(obj.flowVecTimeseries.Value.Data(xIdx,xIdx,zIdx,1,ii));
                h.vecPlot.VData = squeeze(obj.flowVecTimeseries.Value.Data(xIdx,xIdx,zIdx,2,ii));
                h.vecPlot.WData = squeeze(obj.flowVecTimeseries.Value.Data(xIdx,xIdx,zIdx,3,ii));
                h.title.String = sprintf('Time: %.0f %s',timeVec(ii),p.Results.TimeUnits);
                drawnow
                pause(.2)
            end
        end
        
        function h = capFactor(obj,vRated,vCutIn,varargin)
            % Parse optional input arguments
            p = inputParser;
            addParameter(p,'BinSize',0.1,@(x) x>0)
            addParameter(p,'NumOfColorBands',5,@(x) mod(x,1)==0);
            addRequired(p,'vRated',@(x) x>0);
            addRequired(p,'vCutIn',@(x) x>0);
            parse(p,vRated,vCutIn,varargin{:})
            % Define the bin edges for the histogram
            binsEdges = 0:p.Results.BinSize:obj.maxSpeed.Value+p.Results.BinSize;
            % Degine the center point of the bins for the histograms
            binCents = (binsEdges(1:end-1)+binsEdges(2:end))/2;
            % Calculate flow speed at every point in the grid
            flowSpeeds = squeeze(sqrt(sum(obj.flowVecTimeseries.Value.Data.^2,4)));
            % Loop through every grid point
            CF = zeros(size(flowSpeeds,1),size(flowSpeeds,2),size(flowSpeeds,3));
            avg = zeros(size(flowSpeeds,1),size(flowSpeeds,2),size(flowSpeeds,3));
            for ii = 1:size(flowSpeeds,1)
                for jj = 1:size(flowSpeeds,2)
                    for kk = 1:size(flowSpeeds,3)
                        % Get the flow speeds at this grid point
                        vFlows  = squeeze(flowSpeeds(ii,jj,kk,:));
                        vFlows(vFlows<p.Results.vCutIn) = 0;
                        % Calculate the histogram
                        pdf    = histcounts(vFlows,binsEdges,'Normalization','pdf');
                        intArg  = min(binCents.^3,p.Results.vRated.^3).*pdf;
                        CF(ii,jj,kk) = trapz(binCents,intArg)./p.Results.vRated.^3;
                        avg(ii,jj,kk) = mean(vFlows);
                    end
                end
            end
            % Set up meshgrid for plots
            [x,y,z] = meshgrid(...
                obj.xGridPoints.Value,...
                obj.yGridPoints.Value,...
                obj.zGridPoints.Value);
            % Set the colorbands
            colormap([linspace(0,1,p.Results.NumOfColorBands)' zeros(p.Results.NumOfColorBands,1) linspace(1,0,p.Results.NumOfColorBands)'])
            h.scatter3 = scatter3(x(:),y(:),z(:),40,CF(:),'filled');
            h.colorbar = colorbar;
            set(gca,'FontSize',14)
            xlabel('x, [m]')
            ylabel('y, [m]')
            zlabel('z, [m]')
            h.colorbar.Label.String = 'Capacity Factor';
            h.title = title({'Capacity Factor',sprintf('Month %d Day %d',obj.month.Value,obj.day.Value)});
        end
        function h = velFieldAvg(obj,varargin)
            % Parse optional input arguments
            p = inputParser;
            addParameter(p,'BinSize',0.1,@(x) x>0)
            addParameter(p,'NumOfColorBands',20,@(x) mod(x,1)==0);
            parse(p,varargin{:})
            % Calculate flow speed at every point in the grid
            flowSpeeds = squeeze(sqrt(sum(obj.flowVecTimeseries.Value.Data.^2,4)));
            % Loop through every grid point
            vFlows = zeros(size(flowSpeeds,1),size(flowSpeeds,2),size(flowSpeeds,3));
            for ii = 1:size(flowSpeeds,1)
                for jj = 1:size(flowSpeeds,2)
                    for kk = 1:size(flowSpeeds,3)
                        % Get the flow speeds at this grid point
                        vFlows(ii,jj,kk) = mean(squeeze(flowSpeeds(ii,jj,kk,:)));
                    end
                end
            end
            % Set up meshgrid for plots
            [x,y,z] = meshgrid(...
                obj.xGridPoints.Value,...
                obj.yGridPoints.Value,...
                obj.zGridPoints.Value);
            % Set the colorbands
            colormap([linspace(0,1,p.Results.NumOfColorBands)' zeros(p.Results.NumOfColorBands,1) linspace(1,0,p.Results.NumOfColorBands)'])
            h.scatter3 = scatter3(x(:),y(:),z(:),40,vFlows(:),'filled');
            h.colorbar = colorbar;
            set(gca,'FontSize',14)
            xlabel('x [m]')
            ylabel('y [m]')
            zlabel('z [m]')
            h.colorbar.Label.String = 'Flow Speed [m/s]';
            h.title = title(['Average Flow Speeds $-$ ',sprintf('Month %d',obj.month.Value)]);
        end
        function h = velPDF(obj,xIdx,yIdx,varargin)
            % Parse optional input arguments
            p = inputParser;
            addParameter(p,'BinSize',0.1,@(x) x>0)
            addParameter(p,'NumOfColorBands',10,@(x) mod(x,1)==0);
            parse(p,varargin{:})
            % Calculate flow speed at every point in the grid
            flowSpeeds = squeeze(sqrt(sum(obj.flowVecTimeseries.Value.Data.^2,4)));
            % Get mean flow velocity along each column
            colAvg = zeros(size(flowSpeeds,1),size(flowSpeeds,2));
            for ii = 1:size(flowSpeeds,1)
                for jj = 1:size(flowSpeeds,2)
                    colAvg(ii,jj) = mean(squeeze(flowSpeeds(ii,jj,:,:)),'all');
                end
            end
            % Get velocities at the grid points of interest 
            zIdx = [15 20 22 23 24 25];
            colVel = squeeze(flowSpeeds(xIdx,yIdx,zIdx,:));
            % Plot Histograms
            h = figure();
            for ii = 1:6
                subplot(3,2,ii);
                hold on;    grid on 
                b = histogram(colVel(ii,:),20,'Normalization','probability');
                set(b,'FaceColor','b'); set(b,'EdgeColor','b')
                set(gca,'FontSize',12)
                YL = get(gca,'YLim');
                plot([mean(colVel(ii,:)) mean(colVel(ii,:))],[0 50],'r-','linewidth',2)
                set(gca,'YLim',YL)
                if ii >= 5
                    xlabel('Velocity [m/s]');
                end
                title(['Depth = ',num2str(-obj.zGridPoints.Value(zIdx(ii))),' m'])
            end
        end
        function h = velPDFstar(obj,varargin)
            % Parse optional input arguments
            p = inputParser;
            addParameter(p,'BinSize',0.1,@(x) x>0)
            addParameter(p,'NumOfColorBands',10,@(x) mod(x,1)==0);
            parse(p,varargin{:})
            % Calculate flow speed at every point in the grid
            flowSpeeds = squeeze(sqrt(sum(obj.flowVecTimeseries.Value.Data.^2,4)));
            % Find water column with greatest avg flow velocity 
            [xIdx,yIdx] = obj.colOpt;
            % Get velocities at the grid points of interest 
            zIdx = [15 20 22 23 24 25];
            colVels = squeeze(flowSpeeds(xIdx,yIdx,zIdx,:));
            % Plot Histograms
            h = figure();
            for ii = 1:6
                subplot(3,2,ii);
                hold on;    grid on 
                r = histogram(colVels(ii,:),20,'Normalization','probability');
                set(r,'FaceColor','b'); set(r,'EdgeColor','b')
                set(gca,'FontSize',12)
                YL = get(gca,'YLim');
                plot([mean(colVels(ii,:)) mean(colVels(ii,:))],[0 50],'r-','linewidth',2)
                set(gca,'YLim',YL)
                if ii >= 5
                    xlabel('Velocity [m/s]');
                end
                title(['Depth = ',num2str(-obj.zGridPoints.Value(zIdx(ii))),' m'])
            end
        end
        function h = timeScale(obj,varargin)
            % Calculate flow speed at every point in the grid
            flowSpeeds = squeeze(sqrt(sum(obj.flowVecTimeseries.Value.Data.^2,4)));
            % Find water column with greatest avg flow velocity 
            [xIdx,yIdx] = obj.colOpt;
            zIdx = [20 23 25];
            % Get velocities at the grid points of interest 
            Vel = squeeze(flowSpeeds(xIdx,yIdx,zIdx,:));
            Time = linspace(obj.startTime.Value,obj.endTime.Value,length(Vel(1,:)))/3600;
            % Plot FFT results
            h = figure();
            for ii = 1:numel(zIdx)
                subplot(2,3,ii);    hold on;    grid on;
                plot(Time,Vel(ii,:),'b-');     xlabel('Time [hr]');
                ylabel('$v_w$ [m/s]');  title(['Depth = ',num2str(-obj.zGridPoints.Value(zIdx(ii))),' m'])
                %%%% Matlab FFT %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
                N = length(Vel(ii,:));  fs = 1/3600;
                X = fft(Vel(ii,:),N);   df = fs/N;
                sampleIndex = 0:N-1;    f1 = sampleIndex*df;
                subplot(2,3,ii+3);    hold on;    grid on
                plot(1./f1/3600,abs(X),'b-');
                xlabel('$1/\omega$/3600 [hr]');
                ylabel('$|\mathrm{DFT}(v_w)|$');
            end
        end
        function h = velXYZ(obj,varargin)
            % Find water column with greatest avg flow velocity 
            [xIdx,yIdx] = obj.colOpt;
            % Calculate flow speed at every point in the grid
            flowSpeeds = squeeze(sqrt(sum(obj.flowVecTimeseries.Value.Data.^2,4)));
            xFlow = squeeze(obj.flowVecTimeseries.Value.Data(:,:,:,1,:));
            yFlow = squeeze(obj.flowVecTimeseries.Value.Data(:,:,:,2,:));
            zFlow = squeeze(obj.flowVecTimeseries.Value.Data(:,:,:,3,:));
            zIdx = [20 23 25];
            % Get velocities at the grid points of interest 
            Vel = squeeze(flowSpeeds(xIdx,yIdx,zIdx,:));
            xVel = squeeze(xFlow(xIdx,yIdx,zIdx,:));
            yVel = squeeze(yFlow(xIdx,yIdx,zIdx,:));
            zVel = squeeze(zFlow(xIdx,yIdx,zIdx,:));
            Time = linspace(obj.startTime.Value,obj.endTime.Value,length(Vel(1,:)))/3600;
            % Plot FFT results
            h = figure();
            for ii = 1:length(zIdx)
                subplot(3,3,ii);    hold on;    grid on;
                plot(Time,xVel(ii,:),'b-');
                ylabel('$v_x$ [m/s]');
                title(['Depth = ',num2str(-obj.zGridPoints.Value(zIdx(ii))),' m'])
                subplot(3,3,ii+3);    hold on;    grid on;
                plot(Time,yVel(ii,:),'b-');
                ylabel('$v_y$ [m/s]');
                subplot(3,3,ii+6);    hold on;    grid on;
                plot(Time,zVel(ii,:),'b-');
                ylabel('$v_z$ [m/s]');
                xlabel('Time [hr]');
            end
        end
        function [xIdx,yIdx] = colOpt(obj,varargin)
            % Calculate flow speed at every point in the grid
            flowSpeeds = squeeze(sqrt(sum(obj.flowVecTimeseries.Value.Data.^2,4)));
            % Get mean flow velocity along each column
            colAvg = zeros(size(flowSpeeds,1),size(flowSpeeds,2));
            for ii = 1:size(flowSpeeds,1)
                for jj = 1:size(flowSpeeds,2)
                    colAvg(ii,jj) = mean(squeeze(flowSpeeds(ii,jj,:,:)),'all');
                end
            end
            [xIdx,yIdx] = find(max(max(colAvg))==colAvg);
        end
    end
end

