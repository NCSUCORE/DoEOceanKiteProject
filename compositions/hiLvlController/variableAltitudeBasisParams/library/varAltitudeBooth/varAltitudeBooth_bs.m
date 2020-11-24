hiLvlCtrl = CTR.controller;
HILVLCONTROLLER = 'variableAltitudeBasisParams';
PATHGEOMETRY = 'lemOfBooth';

hiLvlCtrl.add('GainNames',{'basisParams','altitude','elevationLookup','altRef','velRef','ELctrl','ThrCtrl','ELslew'},...
              'GainUnits',{'[rad rad rad rad m]','m','deg','m','m/s','','','deg/s'});

hiLvlCtrl.basisParams.setValue([0.3491,0.7999,30*pi/180,0,400],'[rad rad rad rad m]');
hiLvlCtrl.altitude.setValue(200,'m');
hiLvlCtrl.altRef.setValue(50:50:300,'m');
hiLvlCtrl.velRef.setValue(0.1:0.05:0.5,'m/s');
hiLvlCtrl.ELctrl.setValue(0,'');
hiLvlCtrl.ThrCtrl.setValue(1,'');
hiLvlCtrl.ELslew.setValue(0.01,'deg/s');


%% save file in its respective directory
saveFile = saveBuildFile('hiLvlCtrl',mfilename,'variant','HILVLCONTROLLER');
save(saveFile,'PATHGEOMETRY','-append')