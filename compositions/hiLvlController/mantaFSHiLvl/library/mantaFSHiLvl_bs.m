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

%% save file in its respective directory
saveFile = saveBuildFile('hiLvlCtrl',mfilename,'variant','HILVLCONTROLLER');
 save(saveFile,'PATHGEOMETRY','-append')