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
    end
    
    properties (Hidden = true)
        % Property to hold all flow data, hidden from the user
        allFlowVecTimeseries
    end
    
    methods
        function obj = Manta(mnthIndx,dayIndx)
            % Input mnthIndx is a single element of [1 4 7 10] indicating
            % which month of data that you want to use, and then dayIndx
            % is the index of the day within that month that you'd like to
            % use
            p = inputParser;
            addRequired(p,'mnthIndx',@(x) mod(x,1)==0);
            addRequired(p,'dayIndx',@(x) mod(x,1)==0);
            parse(p,mnthIndx,dayIndx)
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
            dayString = sprintf('%02d',p.Results.dayIndx);
            % Get the name of the .mat file that should contain this data
            fName = fullfile(dataPath,['2017',mnthString,dayString '.mat']);
            % If it doesn't exist, then attempt to build it
            if ~isfile(fName)
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
                files = files(contains({files.name},[dayString '00_t']));
                % If the list of files is empty, throw an error
                if isempty(files)
                    error('Unknown day')
                end
                % Build the .mat file
                [data,xBreak,yBreak,zBreak] = obj.buildMantaMAT(files);
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
            obj.xGridPoints            = SIM.parameter('Value',xBreak,'Unit','m');
            obj.yGridPoints            = SIM.parameter('Value',yBreak,'Unit','m');
            obj.zGridPoints            = SIM.parameter('Value',zBreak,'Unit','m');
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
            
            numTimeSteps = numel(timeVec);
            % Plot the initial data
            
            [x,y,z] = meshgrid(...
                obj.xGridPoints.Value,...
                obj.yGridPoints.Value,...
                obj.zGridPoints.Value);
            x = squeeze(permute(x,[2 1 3]));
            y = squeeze(permute(y,[2 1 3]));
            z = squeeze(permute(z,[2 1 3]));
            
            h.vecPlot = quiver3(...
                x,y,z,...
                squeeze(obj.flowVecTimeseries.Value.Data(:,:,:,1,1)),...
                squeeze(obj.flowVecTimeseries.Value.Data(:,:,:,2,1)),...
                squeeze(obj.flowVecTimeseries.Value.Data(:,:,:,3,1)));
            %             daspect([1 1 1])
            xlabel('x [m]')
            ylabel('y [m]')
            ylabel('z [m]')
            h.title = title(sprintf('Time: %.0f %s',timeVec(1),p.Results.TimeUnits));
            set(findall(gcf,'Type','axes'),'FontSize',p.Results.FontSize);
            view(p.Results.View) % Set view angle azimuth and elevation
            for ii = 2:numTimeSteps
                h.vecPlot.UData = squeeze(obj.flowVecTimeseries.Value.Data(:,:,:,1,ii));
                h.vecPlot.VData = squeeze(obj.flowVecTimeseries.Value.Data(:,:,:,2,ii));
                h.vecPlot.WData = squeeze(obj.flowVecTimeseries.Value.Data(:,:,:,3,ii));
                h.title.String = sprintf('Time: %.0f %s',timeVec(ii),p.Results.TimeUnits);
                drawnow
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
            set(gca,'FontSize',24)
            xlabel('x, [m]')
            ylabel('y, [m]')
            zlabel('z, [m]')
            h.colorbar.Label.String = 'Capacity Factor';
        end
    end
end

