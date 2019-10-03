function buildTimeseries(obj)
filePath = fullfile(fileparts(which('OCTProject.prj')),...
    'classes','+ENV','@constX_YZvarT_ADCPTurb','turbGrid.mat');
load(filePath)

timeVec = 0:1:obj.endADCPTime.Value-1-obj.startADCPTime.Value ;
val = obj.flowVecTSeries.Value;
selTime = permute(val.Data,[3,1,2]);
tenMinTimeInterval =  ceil((val.Time(end)+600)/600);
%%% adding to adcp data
for iii = 1:length(obj.depthArray)
    vq = linspace(1,tenMinTimeInterval,tenMinTimeInterval*600);
    xDatForInterp = selTime(:,1,iii);
    yDatForInterp = selTime(:,2,iii);
    zDatForInterp = selTime(:,3,iii);
    interpedDataTimeX = interp1(xDatForInterp,vq);
    interpedDataTimeY = interp1(yDatForInterp,vq);
    interpedDataTimeZ = interp1(zDatForInterp,vq);
    interpedDataTime(:,:,iii) = [ interpedDataTimeX;interpedDataTimeY; interpedDataTimeZ];
end
interpedDataTime = permute(interpedDataTime,[1,3,2]);

flowX = interpedDataTime(1,:,:);
flowY = interpedDataTime(2,:,:);
flowZ = interpedDataTime(3,:,:);

flowXX = [];
flowYY = [];
flowZZ = [];
for q = 1:length(y)
    flowXXTemp = permute(flowX,[2,1,3]);
    flowYYTemp = permute(flowY,[2,1,3]);
    flowZZTemp = permute(flowZ,[2,1,3]);
    flowXX = [flowXX,flowXXTemp];
    flowYY = [flowYY,flowYYTemp];
    flowZZ = [flowZZ,flowZZTemp];
end
%%%%%%%%Final Flow Grid%%%%%%%
tableForFlowSeriesX = flowXX +  U_f_gridFinished;
tableForFlowSeriesY = flowYY +  V_f_gridFinished;
tableForFlowSeriesZ = flowZZ +  W_f_gridFinished;
obj.flowTSX = timeseries(tableForFlowSeriesX,timeVec);
obj.flowTSY = timeseries(tableForFlowSeriesY,timeVec);
obj.flowTSZ = timeseries(tableForFlowSeriesZ,timeVec);
end