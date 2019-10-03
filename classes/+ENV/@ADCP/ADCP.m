classdef ADCP
    %ADCP Class to hold ADCP data
    %   Documentation on 'ADCP.mat' is located in the documentation folder
    %   under ADCP_data_README.pdf
    
    properties (SetAccess = private)
        dateTimes
        timeVec
        flowVecTSeries
        flowDirTSeries
        depths
    end
    
    methods
        function obj = ADCP % Constructor
            load(fullfile(which('ADCPData.mat')));
            % Create vector of datetimes, t = datetime(Y,M,D,H,MI,S), see
            % https://www.mathworks.com/help/matlab/ref/datetime.html#d117e274976
            obj.dateTimes = datetime(SerYear+2000,SerMon,SerDay,SerHour,SerMin,SerSec,SerHund*0.1);
            % Get time steps
            obj.timeVec   = seconds(obj.dateTimes-obj.dateTimes(1));
            data = cat(3,SerEmmpersec./1000,SerNmmpersec./1000,SerVmmpersec./1000);
            data = permute(data,[3 2 1]);
            obj.flowVecTSeries = timeseries(data,obj.timeVec);
            obj.flowVecTSeries.UserData.Description = 'At each time step 3x62 matrix.  Columns correspond to depths, rows correspond to east, north and up directions.';
            obj.flowDirTSeries = timeseries(SerDir10thDeg',obj.timeVec);
            obj.depths = SIM.parameter('Value',RDIBin1Mid-RDIBinSize/2:RDIBinSize:RDIBin1Mid+RDIBinSize*(SerBins(end)-1)-RDIBinSize/2,'Unit','m/s');
        end
        
        animate(obj,varargin)
        
    end
end

