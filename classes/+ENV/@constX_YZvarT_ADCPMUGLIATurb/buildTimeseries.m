function obj = buildTimeseries(obj)
filePath = fullfile(fileparts(which('OCTProject.prj')),...
    'classes','+ENV','@constX_YZvarT_ADCPMUGLIATurb','turbGrid3.mat');
load(filePath)

% timeVec = 0:1:obj.endADCPTime.Value-1-obj.startADCPTime.Value ;
val = obj.flowVecTSeries.Value;
selTime =  permute(val.data, [3,1,2]);
sZ = size(selTime );
magDepth = [];
for ii = 1:sZ(3)
    magDepthT = sqrt( sum(selTime(:,:,ii).^2,2));
    
    %magnitude of xyz at each depth per time
    magDepth = [magDepth,magDepthT];
end
hourInterval = ceil(val.Time(end)/3600);
timeVec = 0:1:hourInterval*3600-1;

interpedDataTimeMat = [];
%%% adding to adcp data
for iii = 1:length(obj.depthArray.Value)
    vq = linspace(1,hourInterval,hourInterval*3600);
    DatForInterp = magDepth(:,iii);
    interpedDataTime = interp1(DatForInterp,vq);
    interpedDataTimeMat =  [interpedDataTimeMat;interpedDataTime] ;
end

flowX = interpedDataTimeMat;



flowXX = [];


for q = 1:length(y)
     flowXX(:,:,q)  = flowX ;
end
flowXX = permute(flowXX,[1,3,2]);

%%%%%%%%Final Flow Grid%%%%%%%
tableForFlowSeriesX = flowXX +  U_f_gridFinished;
tableForFlowSeriesY =  V_f_gridFinished;
tableForFlowSeriesZ = W_f_gridFinished;
obj.flowTSX = timeseries(tableForFlowSeriesX,timeVec);
obj.flowTSY = timeseries(tableForFlowSeriesY,timeVec);
obj.flowTSZ = timeseries(tableForFlowSeriesZ,timeVec);
end