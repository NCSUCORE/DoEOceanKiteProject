classdef DARPA < handle
    %ADCP Class to hold ADCP data
    %   Documentation on 'ADCP.mat' is located in the documentation folder
    %   under ADCP_data_README.pdf
    
    properties (SetAccess = private)
        startTime
        endTime
        flowVecTimeseries
        xGridPoints
        yGridPoints
        zGridPoints
        density
    end
    
    properties (Hidden = true)
        % Property to hold all flow data, hidden from the user
        allFlowVecTimeseries
    end
    
    
    methods
        function obj = DARPA(varargin) % Constructor
            % Input parsing
            p = inputParser;
            
            % Optional arguments to crop date
            addParameter(p,'StartTime',0,@isnumeric)
            addParameter(p,'EndTime',inf,@isnumeric)
            addParameter(p,'DataFile','',@ischar)
            
            % ---Parse the output---
            parse(p,varargin{:})
            % Look in the folder containing this file for a .mat file
            dataFile = dir(fullfile(fileparts(fullfile(which('OCTProject.prj'))),'classes','+ENV','@DARPA','AprilCurrentStats.mat')); % change to JulyCurrentsStats if you want those
            if ~isempty(p.Results.DataFile) % If the user specifies a file, load it
                load(p.Results.DataFile)
            else % Otherwise look in this directory and try to load whatever's there
                if numel(dataFile)==1
                    % If there's just one file, load it
                    load(fullfile(dataFile.folder,dataFile.name));
                else % Otherwise throw an error
                    error('Error: Found more than one potential data file in %s',dataFile(1).folder)
                end
            end
            
            depths = linspace(0,300,25);
            % 6*24*30 = 4320, every ten minutes, for 24 hours in a 30 day month
            tNum = 4320 ;
            for ii = 1:tNum
                data(:,:,:,1,ii) = randn(size(uvelsd)).*uvelsd + uvelmn;
                data(:,:,:,2,ii) = randn(size(uvelsd)).*vvelsd + vvelmn;
                data(:,:,:,3,ii) = randn(size(uvelsd)).*wvelsd + wvelmn;
                
            end
            
            
            
            %time in seconds
            timeVec =  0:10*60:tNum*10*60-10*60;   % 0 to one month (30 days) in seconds with 10 minute dilineations
            
            
            % Have to filter each 3d gridpoint
            b =  -0.001665;
            a = [-0.9983,1];
            for qq = 1:3 % number of flow components
                for pp = 1:numel(depths)
                    for kk = 1:numel(Y)
                        for jj = 1:numel(X)
                            
                            b =  -0.001665;
                            a = [-0.9983,1];
                            currentFilterInput = squeeze(data(jj,kk,pp,qq,:));
                            data(jj,kk,pp,qq,:) = filter(b,a,currentFilterInput);
                            
                        end
                    end
                end
            end
            
            ts = timeseries(data,timeVec);
            newTimeVec = 0:3600:timeVec(end); 
            ts = ts.resample(newTimeVec);
            obj.allFlowVecTimeseries    = SIM.parameter('Value',ts,'Unit','m/s');
            obj.startTime               = SIM.parameter('Value',p.Results.StartTime,'Unit','s');
            obj.endTime                 = SIM.parameter('Value',p.Results.EndTime,'Unit','s');
            obj.flowVecTimeseries       = SIM.parameter('Unit','m/s');
            obj.xGridPoints             = SIM.parameter('Value',X*1000,'Unit','m');
            obj.yGridPoints             = SIM.parameter('Value',Y*1000,'Unit','m');
            obj.zGridPoints             = SIM.parameter('Value',sort(depths,'ascend'),'Unit','m');
            obj.density                 = SIM.parameter('Unit','kg/m^3');
            obj.crop(obj.startTime.Value,obj.endTime.Value); 
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
        
        function setDensity(obj,val,unit)
            obj.density.setValue(val,unit);
        end
       
        
        function cropGUI(obj)
            % Method to let the user select the time window by clicking on
            % the plot
            h = obj.plotSpeeds('Crop',false) ;
            [times,~] = ginput(2);
            close(h.fig);
            times = sort(times);
            obj.setStartTime(times(1),'s');
            obj.setEndTime(times(2),'s');
            
            obj.crop(obj.startTime.Value,obj.endTime.Value);
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
        
        function h = plotSpeeds(obj,varargin)
            p = inputParser;
            addParameter(p,'Cropped',true,@islogical);
            addParameter(p,'FontSize',get(0,'DefaultAxesFontSize'),@isnumeric);
            addParameter(p,'Title','CNAPS Flow Speed',@ischar);
            addParameter(p,'TimeUnits','s',@ischar);
            parse(p,varargin{:})
            
            h.fig = figure('Name','CNAPS Flow Speed');
            h.ax = axes;
            
            if p.Results.Cropped
                data    = squeeze(obj.flowVecTimeseries.Value.Data);
                timeVec = obj.flowVecTimeseries.Value.Time;
            else
                data    = squeeze(obj.allFlowVecTimeseries.Value.Data);
                timeVec = obj.allFlowVecTimeseries.Value.Time;
            end
            % Calculate magnitude
            data = squeeze(sqrt(sum(data.^2,2)));
            
            % If the user wants minutes, divide the time by 60
            if strcmpi(p.Results.TimeUnits,'m') ||strcmpi(p.Results.TimeUnits,'min')
                timeVec = timeVec./60;
            end
            
            % Plot contour plot of total flow speed
            contourf(timeVec,obj.zGridPoints.Value,data)
            xlabel(sprintf('Time [%s]',p.Results.TimeUnits))
            ylabel('Z Position [m]')
            h.colorBar = colorbar;
            h.colorBar.Label.String = 'Flow Speed [m/s]';
            h.title = title(p.Results.Title);
            set(findall(gcf,'Type','axes'),'FontSize',p.Results.FontSize);
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
            addParameter(p,'Title','DARPA Flow Speed',@ischar);
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
        
        
        
        
        
        
    end
    
    
    
    
end

