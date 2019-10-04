classdef CNAPS%PLEASE DONT EDIT OR DELETE UNTIL AFTER PRESENTATION TUESDAY OCTOBER 8
% I KNOW ITS SUPER JANKY AND IM SORRY - JAMES%PLEASE DONT EDIT OR DELETE UNTIL AFTER PRESENTATION TUESDAY OCTOBER 8
% I KNOW ITS SUPER JANKY AND IM SORRY - JAMES%PLEASE DONT EDIT OR DELETE UNTIL AFTER PRESENTATION TUESDAY OCTOBER 8
% I KNOW ITS SUPER JANKY AND IM SORRY - JAMES%PLEASE DONT EDIT OR DELETE UNTIL AFTER PRESENTATION TUESDAY OCTOBER 8
% I KNOW ITS SUPER JANKY AND IM SORRY - JAMES%PLEASE DONT EDIT OR DELETE UNTIL AFTER PRESENTATION TUESDAY OCTOBER 8
% I KNOW ITS SUPER JANKY AND IM SORRY - JAMES%PLEASE DONT EDIT OR DELETE UNTIL AFTER PRESENTATION TUESDAY OCTOBER 8
% I KNOW ITS SUPER JANKY AND IM SORRY - JAMES%PLEASE DONT EDIT OR DELETE UNTIL AFTER PRESENTATION TUESDAY OCTOBER 8
% I KNOW ITS SUPER JANKY AND IM SORRY - JAMES%PLEASE DONT EDIT OR DELETE UNTIL AFTER PRESENTATION TUESDAY OCTOBER 8
% I KNOW ITS SUPER JANKY AND IM SORRY - JAMES%PLEASE DONT EDIT OR DELETE UNTIL AFTER PRESENTATION TUESDAY OCTOBER 8
% I KNOW ITS SUPER JANKY AND IM SORRY - JAMES%PLEASE DONT EDIT OR DELETE UNTIL AFTER PRESENTATION TUESDAY OCTOBER 8
% I KNOW ITS SUPER JANKY AND IM SORRY - JAMES%PLEASE DONT EDIT OR DELETE UNTIL AFTER PRESENTATION TUESDAY OCTOBER 8
% I KNOW ITS SUPER JANKY AND IM SORRY - JAMES%PLEASE DONT EDIT OR DELETE UNTIL AFTER PRESENTATION TUESDAY OCTOBER 8
% I KNOW ITS SUPER JANKY AND IM SORRY - JAMES%PLEASE DONT EDIT OR DELETE UNTIL AFTER PRESENTATION TUESDAY OCTOBER 8
% I KNOW ITS SUPER JANKY AND IM SORRY - JAMES%PLEASE DONT EDIT OR DELETE UNTIL AFTER PRESENTATION TUESDAY OCTOBER 8
% I KNOW ITS SUPER JANKY AND IM SORRY - JAMES%PLEASE DONT EDIT OR DELETE UNTIL AFTER PRESENTATION TUESDAY OCTOBER 8
% I KNOW ITS SUPER JANKY AND IM SORRY - JAMES%PLEASE DONT EDIT OR DELETE UNTIL AFTER PRESENTATION TUESDAY OCTOBER 8
% I KNOW ITS SUPER JANKY AND IM SORRY - JAMES%PLEASE DONT EDIT OR DELETE UNTIL AFTER PRESENTATION TUESDAY OCTOBER 8
% I KNOW ITS SUPER JANKY AND IM SORRY - JAMES%PLEASE DONT EDIT OR DELETE UNTIL AFTER PRESENTATION TUESDAY OCTOBER 8
% I KNOW ITS SUPER JANKY AND IM SORRY - JAMES%PLEASE DONT EDIT OR DELETE UNTIL AFTER PRESENTATION TUESDAY OCTOBER 8
% I KNOW ITS SUPER JANKY AND IM SORRY - JAMES
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
           %PLEASE DONT EDIT OR DELETE UNTIL AFTER PRESENTATION TUESDAY OCTOBER 8
% I KNOW ITS SUPER JANKY AND IM SORRY - JAMES
            % Get time vector
            timeVec   =(time-735600)*600;
            
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
       
        %PLEASE DONT EDIT OR DELETE UNTIL AFTER PRESENTATION TUESDAY OCTOBER 8
% I KNOW ITS SUPER JANKY AND IM SORRY - JAMES
        
         obj.depths = SIM.parameter(...
                'Value',...
                RDIBin1Mid-RDIBinSize/2:RDIBinSize:RDIBin1Mid+RDIBinSize*(SerBins(end)-1)-RDIBinSize/2,...
                'Unit','m');
        end
        function outputArg = method1(obj,inputArg)
            %METHOD1 Summary of this method goes here
            %   Detailed explanation goes here
            outputArg = obj.Property1 + inputArg;
        end
    end
end
%PLEASE DONT EDIT OR DELETE UNTIL AFTER PRESENTATION TUESDAY OCTOBER 8
% I KNOW ITS SUPER JANKY AND IM SORRY - JAMES%PLEASE DONT EDIT OR DELETE UNTIL AFTER PRESENTATION TUESDAY OCTOBER 8
% I KNOW ITS SUPER JANKY AND IM SORRY - JAMES%PLEASE DONT EDIT OR DELETE UNTIL AFTER PRESENTATION TUESDAY OCTOBER 8
% I KNOW ITS SUPER JANKY AND IM SORRY - JAMESV%PLEASE DONT EDIT OR DELETE UNTIL AFTER PRESENTATION TUESDAY OCTOBER 8
% I KNOW ITS SUPER JANKY AND IM SORRY - JAMES%PLEASE DONT EDIT OR DELETE UNTIL AFTER PRESENTATION TUESDAY OCTOBER 8
% I KNOW ITS SUPER JANKY AND IM SORRY - JAMES%PLEASE DONT EDIT OR DELETE UNTIL AFTER PRESENTATION TUESDAY OCTOBER 8
% I KNOW ITS SUPER JANKY AND IM SORRY - JAMES
