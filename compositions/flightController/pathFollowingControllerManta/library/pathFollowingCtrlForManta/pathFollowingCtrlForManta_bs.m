FLIGHTCONTROLLER = 'pathFollowingControllerManta';
SPOOLINGCONTROLLER = 'netZeroSpoolingController';

fltCtrl = CTR.pthFlwCtrlM;

fltCtrl.maxBank.upperLimit.setValue(20*pi/180,'');
fltCtrl.maxBank.lowerLimit.setValue(-20*pi/180,'');
fltCtrl.setPerpErrorVal(6*pi/180,'rad');
fltCtrl.setSearchSize(.5,'');
fltCtrl.setMinR(80,'m')
fltCtrl.setMaxR(160,'m')
fltCtrl.setElevatorReelInDef(0,'deg')
fltCtrl.setStartControl(1,'s')
fltCtrl.firstSpoolLap.setValue(1000,'');

% Control surface parameters
fltCtrl.tanRoll.kp.setValue(0.2,'(rad)/(rad)');
fltCtrl.tanRoll.ki.setValue(0,'(rad)/(rad*s)');
fltCtrl.tanRoll.kd.setValue(0,'(rad)/(rad/s)');
fltCtrl.tanRoll.tau.setValue(1e-3,'s');

fltCtrl.rollMoment.kp.setValue(213400,'(N*m)/(rad)')
fltCtrl.rollMoment.ki.setValue(0,'(N*m)/(rad*s)');
fltCtrl.rollMoment.kd.setValue(191000,'(N*m)/(rad/s)');
fltCtrl.rollMoment.tau.setValue(0.001,'s');

fltCtrl.yawMoment.kp.setValue(2.3458e3,'(N*m)/(rad)');

fltCtrl.pitchMoment.kp.setValue(20000,'(N*m)/(rad)')
fltCtrl.pitchMoment.ki.setValue(0,'(N*m)/(rad*s)');
fltCtrl.pitchMoment.kd.setValue(0,'(N*m)/(rad/s)');
fltCtrl.pitchMoment.tau.setValue(0.001,'s');

fltCtrl.controlSigMax.upperLimit.setValue(30,'')
fltCtrl.controlSigMax.lowerLimit.setValue(-30,'')

fltCtrl.startControl.setValue(0,'s');

fltCtrl.AoACtrl.setValue(0,'');                   
fltCtrl.AoASP.setValue(0,'');                   
fltCtrl.AoAConst.setValue(9,'deg');
fltCtrl.AoATime.setValue([0 1000 2000],'s');         
fltCtrl.AoALookup.setValue([9 4 9],'deg');

%% Save
saveFile = saveBuildFile('fltCtrl',mfilename,'variant','FLIGHTCONTROLLER');
save(saveFile,'SPOOLINGCONTROLLER','-append')