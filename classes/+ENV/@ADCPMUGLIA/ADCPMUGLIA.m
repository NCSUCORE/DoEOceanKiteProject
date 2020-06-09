classdef ADCPMUGLIA
    %ADCP Class to hold ADCP data
    %   Documentation on 'ADCP.mat' is located in the documentation folder
    %   under ADCP_data_README.pdf
    
    properties (SetAccess = private)
        flowVecTSeries
        depths
    end
    
    methods
        function obj = ADCPMUGLIA(varargin) % Constructor
            % Input parsing
            p = inputParser;
            
            % Optional arguments to crop date
            addParameter(p,'startTime',0,@isnumeric)
            addParameter(p,'endTime',inf,@isnumeric)
            addParameter(p,'DataFile','',@ischar)
            
            % ---Parse the output---
            parse(p,varargin{:})
            % Look in the folder containing this file for a .mat file
            dataFile = dir(fullfile(fileparts(fullfile(which('OCTProject.prj'))),'classes','+ENV','@ADCPMUGLIA','*.mat'));
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
            
            %time in seconds
            timeVec = (mtime- 736205)*60*60*24;
            
            % --Build timeseries for the flow vector--
            % Convert loaded data to m/s and concatenate along 3rd dimension
            data = cat(3,east_vel,north_vel,vert_vel);
            % Permure data to correct dimension for timeseries
            data = permute(data,[3 1 2]);
            % Create timeseries object and crop to specified times
            flowTimeseries = getsampleusingtime(...
                timeseries(data,timeVec),...
                p.Results.startTime,p.Results.endTime);
            % Add start datetime to the time info
           
            % Add description
            flowTimeseries.UserData.Description = ...
                'At each time step 3x62 matrix.  Columns correspond to depths, rows correspond to east, north and up directions.';
            flowTimeseries.DataInfo.Units = 'm/s';
            % Store into SIM.parameter object
            obj.flowVecTSeries = SIM.parameter('Value',flowTimeseries,'Unit','m/s');
            
            
            
           
            
            % Set vector of depths
            obj.depths = SIM.parameter(...
                'Value',...
                z,...
                'Unit','m');
        end
        
        % Method to animate the flow profile
%         animate(obj,varargin)
%         
%         % Method to animate the flow in 3D
%         animate3D(obj,varargin)
%         
%         % Method to plot flow magnitudes
%         plotMags(obj,varargin)
        
        % Method to crop data
     function [flowTimeseries,depthMat] = crop(obj,startTime,endTime,zMinD,zMaxD)
            % Set endTime to max possible value
            endTime = min([endTime ...
                obj.flowVecTSeries.Value.Time(end)]);
            % --Crop flow velocity vector timeseries--
            flowTimeseries = getsampleusingtime(obj.flowVecTSeries.Value,startTime,endTime);
             flowTimeseries.data = flowTimeseries.data(:,zMinD:zMaxD,:);
            flowTimeseries.DataInfo.Units = obj.flowVecTSeries.Value.DataInfo.Units;
            % Reset time vector to start at 0
            flowTimeseries.Time = flowTimeseries.Time-flowTimeseries.Time(1);
            depthMat = obj.depths.Value(zMinD:zMaxD);
     end
         
     
     
       
    end
end

