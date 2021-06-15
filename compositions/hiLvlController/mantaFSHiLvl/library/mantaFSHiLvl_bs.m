hiLvlCtrl = CTR.controller;
HILVLCONTROLLER = 'mantaFSHiLvl';
PATHGEOMETRY = 'lemOfBooth';

hiLvlCtrl.add('GainNames',...
    {'basisParams'},...
    'GainUnits',...
    {'[rad rad rad rad m]'});

hiLvlCtrl.basisParams.setValue([.73,.6,.36,0,125],'[rad rad rad rad m]');

hiLvlCtrl.add('GainNames',{'maxNumberOfSimulatedLaps'},'GainUnits',{''});
hiLvlCtrl.maxNumberOfSimulatedLaps.setValue(inf,'');

hiLvlCtrl.add('GainNames',{'stateCtrl'},'GainUnits',{''});
hiLvlCtrl.stateCtrl.setValue(1,'');

hiLvlCtrl.add('GainNames',{'stateConst'},'GainUnits',{''});
hiLvlCtrl.stateConst.setValue(1,'');

hiLvlCtrl.add('GainNames',{'preXelevation'},'GainUnits',{'rad'});
hiLvlCtrl.preXelevation.setValue(10*pi/180,'rad');

hiLvlCtrl.add('GainNames',{'initXelevation'},'GainUnits',{'rad'});
hiLvlCtrl.initXelevation.setValue(15*pi/180,'rad');

hiLvlCtrl.add('GainNames',{'maxThrLength'},'GainUnits',{'m'});
hiLvlCtrl.maxThrLength.setValue(600,'m');

hiLvlCtrl.add('GainNames',{'harvestingAltitude'},'GainUnits',{'m'});
hiLvlCtrl.harvestingAltitude.setValue(200,'m');

hiLvlCtrl.add('GainNames',{'harvestingThrLength'},'GainUnits',{'m'});
hiLvlCtrl.harvestingThrLength.setValue(400,'m');

hiLvlCtrl.add('GainNames',{'initialAltitude'},'GainUnits',{'m'});
hiLvlCtrl.initialAltitude.setValue(20,'m');

%% save file in its respective directory
saveFile = saveBuildFile('hiLvlCtrl',mfilename,'variant','HILVLCONTROLLER');
save(saveFile,'PATHGEOMETRY','-append')