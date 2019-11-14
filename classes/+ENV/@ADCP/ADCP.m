classdef ADCP < handle
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
    end
    
    properties (Hidden = true)
        % Property to hold all flow data, hidden from the user
        allFlowVecTimeseries
    end
    
    
    methods
        function obj = ADCP(varargin) % Constructor
            % Input parsing
            p = inputParser;
            
            % Optional arguments to crop date
            addParameter(p,'StartTime',0,@isnumeric)
            addParameter(p,'EndTime',inf,@isnumeric)
            addParameter(p,'DataFile','',@ischar)
            
            % ---Parse the output---
            parse(p,varargin{:})
            % Look in the folder containing this file for a .mat file
            dataFile = dir(fullfile(fileparts(fullfile(which('OCTProject.prj'))),'classes','+ENV','@ADCP','*.mat'));
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
            % Create vector of datetimes, t = datetime(Y,M,D,H,MI,S), see
            % https://www.mathworks.com/help/matlab/ref/datetime.html#d117e274976
            dateTimes = datetime(SerYear+2000,SerMon,SerDay,SerHour,SerMin,SerSec,SerHund*0.1);
            % Get time vector
            timeVec   = seconds(dateTimes-dateTimes(1));
            
            
            % --Build timeseries for the flow vector--
            % Convert loaded data to m/s and concatenate along 3rd dimension
            data = cat(3,SerEmmpersec./1000,SerNmmpersec./1000,SerVmmpersec./1000);
            % Permure data to correct dimension for timeseries
            data = permute(data,[3 2 1]);               % Reorder to (velocityComponentXorY, depths, timestep)
            data = sqrt(sum(data.^2,1));                % Put all flow into x direction (James said Mike Muglia said this was ok)
            sz = size(data);                            % Get the size of the data
            data(2,:,:) = zeros(sz);                    % Append zeros for the y direction velocity component
            data(3,:,:) = zeros(sz);                    % Append zeros for the z direction velocity component
            data = permute(data,[4 5 2 1 3]);           % Change and add dimensions to get (xCoord,yCoord,zCoord,XYZVelocityComponent,TimeStep)
            
            depths =  RDIBin1Mid-RDIBinSize/2:RDIBinSize:RDIBin1Mid+RDIBinSize*(SerBins(end)-1)-RDIBinSize/2;
            
            obj.allFlowVecTimeseries    = SIM.parameter('Value',timeseries(data,timeVec),'Unit','m/s');
            obj.startTime               = SIM.parameter('Value',p.Results.StartTime,'Unit','s');
            obj.endTime                 = SIM.parameter('Value',p.Results.EndTime,'Unit','s');
            obj.flowVecTimeseries       = SIM.parameter('Unit','m/s');
            obj.xGridPoints             = SIM.parameter('Value',0,'Unit','m');
            obj.yGridPoints             = SIM.parameter('Value',0,'Unit','m');
            obj.zGridPoints             = SIM.parameter('Value',sort(depths,'descend'),'Unit','m');
            obj.crop(obj.startTime.Value,obj.endTime.Value); % Sets the 
        end
            
            
            
        function setStartTime(obj,val,unit)
            obj.startTime.setValue(val,unit); 
        end
        function setEndTime(obj,val,unit)
            obj.endTime.setValue(val,unit);
        end
        function setFlowVecTimeseries(obj,val,unit)
            obj.flowVecTimeseries.setValue(val,unit);
        end
        
         function setXGridPoints(obj,val,unit)
            val = val(:);
            obj.xGridPoints.setValue(val,unit);
            nx = numel(val);
            ny = numel(obj.yGridPoints.Value);
            oldTSData = obj.flowVecTimeseries.Value.Data;
            newTSData = repmat(...
                oldTSData(1,1,:,:,:),... %yz plane
                [nx ny 1 1 1]); % replicate in x direction
            newTS = obj.flowVecTimeseries.Value;
            newTS.Data = newTSData;
            obj.setFlowVecTimeseries(newTS,'m/s');
        end
        function setYGridPoints(obj,val,unit)
            val = val(:);
            obj.yGridPoints.setValue(val,unit);
            ny = numel(val);
            nx = numel(obj.xGridPoints.Value);
            oldTSData = obj.flowVecTimeseries.Value.Data;
            newTSData = repmat(...
                oldTSData(1,1,:,:,:),... %yz plane
                [nx ny 1 1 1]); % replicate in x direction
            newTS = obj.flowVecTimeseries.Value;
            newTS.Data = newTSData;
            obj.setFlowVecTimeseries(newTS,'m/s');
        end
        function setZGridPoints(obj,val,unit)
            if numel(val)~= numel(obj.zGridPoints.Value)
                error('Number of z grid points must be %d',numel(obj.zGridPoints.Value));
            end
            obj.zGridPoints.setValue(val,unit);
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
            addParameter(p,'Title','CNAPS Flow Speed',@ischar);
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

