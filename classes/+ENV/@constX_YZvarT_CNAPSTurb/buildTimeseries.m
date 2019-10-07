function obj = buildTimeseries(obj)
filePath = fullfile(fileparts(which('OCTProject.prj')),...
    'classes','+ENV','@constX_YZvarT_CNAPSTurb','turbGrid2.mat');
load(filePath)

% timeVec = 0:1:obj.endADCPTime.Value-1-obj.startADCPTime.Value ;
val = obj.flowVecTSeries.Value;
selTime = permute(val.Data,[3,1,2]);
hourInterval = ceil(val.Time(end)/3600);
timeVec = 0:1:hourInterval*3600-1;
%%% adding to adcp data
for iii = 1:length(obj.depthArray.Value)
    vq = linspace(1,hourInterval,hourInterval*3600);
    xDatForInterp = selTime(:,1,iii);
    yDatForInterp = selTime(:,2,iii);
    interpedDataTimeX = interp1(xDatForInterp,vq);
    interpedDataTimeY = interp1(yDatForInterp,vq);
    interpedDataTime(:,:,iii) = [ interpedDataTimeX;interpedDataTimeY; ];
end
interpedDataTime = permute(interpedDataTime,[1,3,2]);

flowX = interpedDataTime(1,:,:);
flowY = interpedDataTime(2,:,:);


flowXX = [];
flowYY = [];

for q = 1:length(y)
    flowXXTemp = permute(flowX,[2,1,3]);
    flowYYTemp = permute(flowY,[2,1,3]);
    flowXX = [flowXX,flowXXTemp];
    flowYY = [flowYY,flowYYTemp];
    
end
%%%%%%%%Final Flow Grid%%%%%%%
tableForFlowSeriesX = flowXX +  U_f_gridFinished;
tableForFlowSeriesY = flowYY +  V_f_gridFinished;
tableForFlowSeriesZ = W_f_gridFinished;
obj.flowTSX = timeseries(tableForFlowSeriesX,timeVec);
obj.flowTSY = timeseries(tableForFlowSeriesY,timeVec);
obj.flowTSZ = timeseries(tableForFlowSeriesZ,timeVec);
end