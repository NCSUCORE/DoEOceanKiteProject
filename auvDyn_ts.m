%%  Params

rho  = 1000;
cD   = .08;
aRef = 10 ;
AUVmass = 8000;
posSP  = 1.12*10^3;
motorForce = 7.457*10^3; %watts , 10 hp
posOffset = 50;% meters

load('auvDataMat.mat')

fsDisc = [0:.1:2];
pBL = [1:100];


% fsLUTObj = Simulink.LookupTable;
% fsLUTObj.Table.Value =totIndMat;
% fsLUTObj.Breakpoints(1).Value = fsDisc;
% fsLUTObj.Breakpoints(2).Value = pBL;
% fsLUTObj.Breakpoints(3).Value = msrNewDist ;
% fsLUTObj.StructTypeInfo.Name = 'fsLUTObj';

% tsc.timeR.Data(end)
% tsc.energy.Data(end)

initBat = 100;
timeStart = 3600;
allTL = 400;
Bme =  6.3488e+04*4;
startKiteCost = 300;
energyInOnePercent = Bme/100;
x1 =  [0,.1,.5,1,1.5,2];
x2 =  [0,7,1268,9390,30400,63000];
flowForPower = 0:.1:2;
interpolatedPower = interp1(x1,x2,flowForPower,'cubic');
timeToChargePF =  energyInOnePercent./interpolatedPower;

stageMap = [1: numSt ]; %,numSt-1:-1:1,2: numSt,numSt-1:-1:1];
%% simulate
bat  = initBat;
time = timeStart;
for i = 1:4% stageMap
    
    % match time into the time varying flow matrix
    time4flow = ceil(time/3600);
    
    fsMax     = maxFData(time4flow,i);
    
    fsInd     = find([1:length(fsDisc)].*(fsDisc > (fsMax - .01) & fsDisc < (fsMax + .01)),1);
    try
    nextMove  = totIndMat(fsInd,bat,i);
    catch
        b = 1;
    end
    
    if (bat-nextMove < 0)
        time  = time  + timeToChargePF(fsMax)*amount2Charge + startKiteCost;
        bat   = nextMove;
    end
    
    
    
    floorFlow = data{i}(time4flow,end);
    % move forward
    sim('auvDyn')
    parseLogsout
    bat      =  bat - ceil(100*(tsc.energy.Data(end)/Bme));
    time     =  time +  tsc.timeR.Data(end);
    
    batTracker(i) = bat;
end




