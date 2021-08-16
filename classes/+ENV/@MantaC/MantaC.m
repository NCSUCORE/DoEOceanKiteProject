classdef MantaC < handle
    % Manta class to hold Manta data
    properties (SetAccess = private)
        density
        startTime
        endTime
        flowVecTimeseries
        xGridPoints
        yGridPoints
        zGridPoints
        tGridPoints
        maxSpeed
        minSpeed
        constSpd
    end
    
    properties (Dependent)
        % Property to hold all flow data, hidden from the user
        allFlowVecTimeseries
    end
    
    methods
        function obj = MantaC(varargin)
            p = inputParser;
            parse(p,varargin{:})
            % Build the vector of timestamps
            obj.density                 = SIM.parameter('Unit','kg/m^3');
            obj.startTime               = SIM.parameter('Value',0,'Unit','s');
            obj.endTime                 = SIM.parameter('Value',4000,'Unit','s');
            obj.flowVecTimeseries       = SIM.parameter('Unit','m/s');
            obj.xGridPoints             = SIM.parameter('Value',(-1000:500:1000)','Unit','m');
            obj.yGridPoints             = SIM.parameter('Value',(-1000:500:1000)','Unit','m');
            obj.zGridPoints             = SIM.parameter('Value',(0:25:500)','Unit','m');
            obj.tGridPoints             = SIM.parameter('Value',[0;4000],'Unit','s');
            obj.constSpd                = SIM.parameter('Value',0.25,'Unit','m/s');
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
            obj.xGridPoints.setValue(val,unit)
        end
        function setYGridPoints(obj,val,unit)
            obj.yGridPoints.setValue(val,unit)
        end
        function setZGridPoints(obj,val,unit)
            obj.zGridPoints.setValue(val,unit);
        end
        function setTGridPoints(obj,val,unit)
            obj.tGridPoints.setValue(val,unit);
        end
        function setConstSpd(obj,val,unit)
            obj.constSpd.setValue(val,unit);
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
        
        function val = get.allFlowVecTimeseries(obj)
            data = zeros(numel(obj.xGridPoints.Value),numel(obj.yGridPoints.Value),...
                numel(obj.zGridPoints.Value),3,numel(obj.tGridPoints.Value));
            data(:,:,:,1,:) = obj.constSpd.Value;
            val = SIM.parameter('Value',timeseries(data,obj.tGridPoints.Value),'Unit','m/s');
        end
        
        function val = get.maxSpeed(obj)
            val = max(sqrt(sum(obj.flowVecTimeseries.Value.Data.^2,4)),[],'all');
            val = SIM.parameter('Value',val,'Unit','m/s');
        end
        
        function val = get.minSpeed(obj)
            val = min(sqrt(sum(obj.flowVecTimeseries.Value.Data.^2,4)),[],'all');
            val = SIM.parameter('Value',val,'Unit','m/s');
        end
            
        %%  Methods to observe/analyze 
        function h = plotXslice(obj,x,t,varargin)
            Y = obj.yGridPoints.Value;
            Z = obj.zGridPoints.Value;
            temp = zeros(numel(Y),numel(Z));
            for i = 1:numel(Y)
                for j = 1:numel(Z)
                    data = squeeze(obj.flowVecTimeseries.Value.Data(:,i,j,1,:));
                    temp(i,j) = interp2(obj.xGridPoints.Value,obj.tGridPoints.Value,data,x,t);
                end
            end
            % Calculate flow speed at every point in the grid
            flowSpeeds = squeeze(sqrt(sum(obj.flowVecTimeseries.Value.Data.^2,4)));
            % Get mean flow velocity along each column
            colAvg = zeros(size(flowSpeeds,1),size(flowSpeeds,2));
            for ii = 1:size(flowSpeeds,1)
                for jj = 1:size(flowSpeeds,2)
                    colAvg(ii,jj) = mean(squeeze(flowSpeeds(ii,jj,:,:)),'all');
                end
            end
            h = figure;
            
        end
    end
end

