function [flowTSX,flowTSY,flowTSZ] = createADCPTimeSeriesTurb2(obj)

startTime = obj.startADCPTime.Value;
timeVec = 0:1:obj.endADCPTime.Value-1;
obj.depth.setValue((4*61+6.31),'m')
obj.depthArray.setValue([6.31:4:4*61+6.31],'m');
load('ADCPData')
tenMinTimeInterval = ceil(obj.endADCPTime.Value/600);

fprintf('timeStart is year 20%d, month %d, day %d ,hour %d min %d\n',[SerYear(startTime),SerMon(startTime),SerDay(startTime),SerHour(startTime),SerMin(startTime)])
fprintf('timeEnd is closest to year 20%d, month %d, day %d ,hour %d min %d\n',[SerYear(startTime+tenMinTimeInterval),SerMon(startTime+tenMinTimeInterval),...
    SerDay(startTime+tenMinTimeInterval),SerHour(startTime+tenMinTimeInterval),SerMin(startTime+tenMinTimeInterval)])

for i = 1:62
    flowIn(:,:,i)  = [SerEmmpersec(:,i),SerNmmpersec(:,i),SerNmmpersec(:,i)];
end
%matrix of the data between the times you have selected
selTime =  flowIn(startTime:startTime+tenMinTimeInterval,:,:);




%%% adding to adcp data
for iii = 1:length(obj.depthArray.Value)
    vq = linspace(1,tenMinTimeInterval+1,tenMinTimeInterval*600);
    xDatForInterp = selTime(:,1,iii);
    yDatForInterp = selTime(:,2,iii);
    zDatForInterp = selTime(:,3,iii);
    interpedDataTimeX = interp1(xDatForInterp,vq);
    interpedDataTimeY = interp1(yDatForInterp,vq);
    interpedDataTimeZ = interp1(zDatForInterp,vq);
    interpedDataTime(:,:,iii) = [ .001*interpedDataTimeX; .001*interpedDataTimeY; .001*interpedDataTimeZ];
    
end


load('turbGrid.mat')
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
flowTSX = timeseries(tableForFlowSeriesX,timeVec);
flowTSY = timeseries(tableForFlowSeriesY,timeVec);
flowTSZ = timeseries(tableForFlowSeriesZ,timeVec);
end

