classdef ADCP
    %ADCP Class to hold ADCP data
    %   Documentation on 'ADCP.mat' is located in the documentation folder
    %   under ADCP_data_README.pdf
    
    properties (SetAccess = private)
        flowVecTSeries
        flowDirTSeries
        depths
    end
    
    methods
        function obj = ADCP(varargin) % Constructor
            % Input parsing
            p = inputParser;
            
            % Optional arguments to crop date
            addParameter(p,'startTime',0,@isnumeric)
            addParameter(p,'endTime',inf,@isnumeric)
            
            % ---Parse the output---
            parse(p,varargin{:})

            load(fullfile(which('ADCPData.mat')));
            % Create vector of datetimes, t = datetime(Y,M,D,H,MI,S), see
            % https://www.mathworks.com/help/matlab/ref/datetime.html#d117e274976
            dateTimes = datetime(SerYear+2000,SerMon,SerDay,SerHour,SerMin,SerSec,SerHund*0.1);
            % Get time vector
            timeVec   = seconds(dateTimes-dateTimes(1));
            
            % --Build timeseries for the flow vector--
            % Convert loaded data to m/s and concatenate along 3rd dimension
            data = cat(3,SerEmmpersec./1000,SerNmmpersec./1000,SerVmmpersec./1000);
            % Permure data to correct dimension for timeseries
            data = permute(data,[3 2 1]);
            % Create timeseries object and crop to specified times
            flowTimeseries = getsampleusingtime(...
                timeseries(data,timeVec),...
                p.Results.startTime,p.Results.endTime);
            % Add start datetime to the time info
            flowTimeseries.TimeInfo.StartDate = dateTimes(1);
            % Add description
            flowTimeseries.UserData.Description = ...
                'At each time step 3x62 matrix.  Columns correspond to depths, rows correspond to east, north and up directions.';
            % Store into SIM.parameter object
            obj.flowVecTSeries = SIM.parameter('Value',flowTimeseries,'Unit','m/s');
            
            % -- Build timeseries for the flow direction--
            % Create timeseries object and crop it
            dirTimeseries = getsampleusingtime(...
                timeseries(0.1*SerDir10thDeg',timeVec),...
                p.Results.startTime,p.Results.endTime);
            % Add start datetime to the time info
            dirTimeseries.TimeInfo.StartDate = dateTimes(1);
            % Add description
            dirTimeseries.UserData.Description = ...
                'Flow direction in degrees at each depth.';
            % Store into SIM.parameter object
            obj.flowDirTSeries = SIM.parameter('Value',dirTimeseries,'Unit','deg');
            
            % Set vector of depths
            obj.depths = SIM.parameter(...
                'Value',...
                RDIBin1Mid-RDIBinSize/2:RDIBinSize:RDIBin1Mid+RDIBinSize*(SerBins(end)-1)-RDIBinSize/2,...
                'Unit','m');
        end
        
        % Method to animate the flow profile
        animate(obj,varargin)
        
        % Method to crop data
        function crop(obj,startTime,endTime)
            % --Crop flow velocity vector timeseries--
            flowTimeseries = getsampleusingtime(obj.flowVecTSeries.Value,...
                datenum(obj.flowVecTSeries.Value.TimeInfo.StartDate+seconds(startTime)),...
                datenum(obj.flowVecTSeries.Value.TimeInfo.StartDate+seconds(endTime)));
            % Set start time 
            flowTimeseries.TimeInfo.StartDate = ...
                obj.flowVecTSeries.Value.TimeInfo.StartDate + ...
                seconds(flowTimeseries.Time(1));
            % Reset time vector to start at 0
            flowTimeseries.Time = flowTimeseries.Time-flowTimeseries.Time(1);
            % Store into the parameter
            obj.flowVecTSeries.setValue(flowTimeseries,'m/s')
            
            % --Crop the flow direction timeseries
            dirTimeseries = getsampleusingtime(obj.flowDirTSeries.Value,...
                datenum(obj.flowDirTSeries.Value.TimeInfo.StartDate+seconds(startTime)),...
                datenum(obj.flowDirTSeries.Value.TimeInfo.StartDate+seconds(endTime)));
            % Set start time
            dirTimeseries.TimeInfo.StartDate = ...
                obj.flowDirTSeries.Value.TimeInfo.StartDate + ...
                seconds(dirTimeseries.Time(1));
            % Reset time vector to start at 0
            dirTimeseries.Time = dirTimeseries.Time-dirTimeseries.Time(1);
            % Store into the parameter
            obj.flowDirTSeries.setValue(dirTimeseries,'deg')
            
        end
        
    end
end

