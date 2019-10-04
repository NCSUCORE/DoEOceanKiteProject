classdef CNAPS%PLEASE DONT EDIT OR DELETE UNTIL AFTER PRESENTATION TUESDAY OCTOBER 8
    
    
    %CNAPS Summary of this class goes here
    %   Detailed explanation goes here
    %PLEASE DONT EDIT OR DELETE UNTIL AFTER PRESENTATION TUESDAY OCTOBER 8
    % I KNOW ITS SUPER JANKY AND IM SORRY - JAMES
    properties (SetAccess = private)
        flowVecTSeries
        depths
    end
    %PLEASE DONT EDIT OR DELETE UNTIL AFTER PRESENTATION TUESDAY OCTOBER 8
    % I KNOW ITS SUPER JANKY AND IM SORRY - JAMES
    methods
        function obj = CNAPS(varargin)
            % Input parsing
            p = inputParser;
            
            % Optional arguments to crop date
            addParameter(p,'startTime',0,@isnumeric)
            addParameter(p,'endTime',inf,@isnumeric)
            addParameter(p,'DataFile','',@ischar)
            
            % ---Parse the output---
            parse(p,varargin{:})
            % Look in the folder containing this file for a .mat file
            dataFile = dir(fullfile(fileparts(fullfile(which('OCTProject.prj'))),'classes','+ENV','@CNAPS','*.mat'));
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
            
            % Get time vector first 100 hours, time is given in days,
            % starting at 735600 for some reason unknown to me 
            
           timeVec =(time(1:1000)-735600)*3600*24;
            
            % --Build timeseries for the flow vector--
            % Convert loaded data to m/s and concatenate along 3rd dimension
            data = cnapsMat;
            
            % Permute data to correct dimension for timeseries
            data = permute(data,[3 2 1]);
            % Create timeseries object and crop to specified times WILL BE
            %              USED EVENTUALLY
            
            flowTimeseries = timeseries(data,timeVec);
            % Add start datetime to the time info
%             flowTimeseries.TimeInfo.StartDate = dateTimes(1);
            % Add description
            flowTimeseries.UserData.Description = ...
                'At each time step 2x8 matrix.  Columns correspond to depths, rows correspond to east, and north directions.';
            flowTimeseries.DataInfo.Units = 'm/s';
            % Store into SIM.parameter object
            obj.flowVecTSeries = SIM.parameter('Value',flowTimeseries,'Unit','m/s');
            
            
            
            obj.depths = SIM.parameter('Value',0:25:25*8, 'Unit','m');
        end
        
         function flowTimeseries = crop(obj,startTime,endTime)
            % Set endTime to max possible value
            endTime = min([endTime ...
                obj.flowVecTSeries.Value.Time(end)]);
            % --Crop flow velocity vector timeseries--
            flowTimeseries = getsampleusingtime(obj.flowVecTSeries.Value,startTime,endTime);
            % Set start time 
%             flowTimeseries.TimeInfo.StartDate = ...
%                 obj.flowVecTSeries.Value.TimeInfo.StartDate + ...
%                 seconds(flowTimeseries.Time(1));
            flowTimeseries.DataInfo.Units = obj.flowVecTSeries.Value.DataInfo.Units;
            % Reset time vector to start at 0
            flowTimeseries.Time = flowTimeseries.Time-flowTimeseries.Time(1);
         end
        
        
    end
end

