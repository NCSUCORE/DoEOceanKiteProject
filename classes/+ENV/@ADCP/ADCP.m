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
            flowTimeseries.DataInfo.Units = 'm/s';
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
            dirTimeseries.DataInfo.Units = 'deg';
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
        
        % Method to animate the flow in 3D
        animate3D(obj,varargin)
        
        % Method to plot flow magnitudes
        plotMags(obj,varargin)
        
        % Method to crop data
        function [flowTimeseries,dirTimeseries] = crop(obj,startTime,endTime)
            % Set endTime to max possible value
            endTime = min([endTime ...
                obj.flowVecTSeries.Value.Time(end)...
                obj.flowDirTSeries.Value.Time(end)]);
            % --Crop flow velocity vector timeseries--
            flowTimeseries = getsampleusingtime(obj.flowVecTSeries.Value,...
                datenum(obj.flowVecTSeries.Value.TimeInfo.StartDate+seconds(startTime)),...
                datenum(obj.flowVecTSeries.Value.TimeInfo.StartDate+seconds(endTime)));
            % Set start time 
            flowTimeseries.TimeInfo.StartDate = ...
                obj.flowVecTSeries.Value.TimeInfo.StartDate + ...
                seconds(flowTimeseries.Time(1));
            flowTimeseries.DataInfo.Units = obj.flowVecTSeries.Value.DataInfo.Units;
            % Reset time vector to start at 0
            flowTimeseries.Time = flowTimeseries.Time-flowTimeseries.Time(1);
            % Store into the parameter
%             obj.flowVecTSeries.setValue(flowTimeseries,'m/s')
            
            % --Crop the flow direction timeseries
            dirTimeseries = getsampleusingtime(obj.flowDirTSeries.Value,...
                datenum(obj.flowDirTSeries.Value.TimeInfo.StartDate+seconds(startTime)),...
                datenum(obj.flowDirTSeries.Value.TimeInfo.StartDate+seconds(endTime)));
            % Set start time
            dirTimeseries.TimeInfo.StartDate = ...
                obj.flowDirTSeries.Value.TimeInfo.StartDate + ...
                seconds(dirTimeseries.Time(1));
            dirTimeseries.DataInfo.Units = obj.flowDirTSeries.Value.DataInfo.Units;
            % Reset time vector to start at 0
            dirTimeseries.Time = dirTimeseries.Time-dirTimeseries.Time(1);
            % Store into the parameter
%             obj.flowDirTSeries.setValue(dirTimeseries,'deg')
            
        end
        
    end
end

