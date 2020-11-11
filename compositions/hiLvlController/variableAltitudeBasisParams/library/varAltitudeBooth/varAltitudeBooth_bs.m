hiLvlCtrl = CTR.controller;
HILVLCONTROLLER = 'variableAltitudeBasisParams';
PATHGEOMETRY = 'lemOfBooth';

hiLvlCtrl.add('GainNames',{'basisParams','altitude'},...
              'GainUnits',{'[rad rad rad rad m]','m'});

hiLvlCtrl.basisParams.setValue([0.3491,0.7999,30*pi/180,0,400],'[rad rad rad rad m]');
hiLvlCtrl.altitude.setValue(200,'m');


%% save file in its respective directory
saveFile = saveBuildFile('hiLvlCtrl',mfilename,'variant','HILVLCONTROLLER');
save(saveFile,'PATHGEOMETRY','-append')