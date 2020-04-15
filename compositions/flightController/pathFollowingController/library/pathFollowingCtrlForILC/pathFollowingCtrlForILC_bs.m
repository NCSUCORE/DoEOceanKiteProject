FLIGHTCONTROLLER = 'pathFollowingController';
SPOOLINGCONTROLLER = 'netZeroSpoolingController';

fltCtrl = CTR.pthFlwCtrl;

fltCtrl.maxBank.upperLimit.setValue(20*pi/180,'');
fltCtrl.maxBank.lowerLimit.setValue(-20*pi/180,'');
fltCtrl.setPerpErrorVal(6*pi/180,'rad');
fltCtrl.setSearchSize(.5,'');
fltCtrl.setMinR(100,'m')
fltCtrl.setMaxR(200,'m')
fltCtrl.setElevatorReelInDef(20,'deg')
fltCtrl.setStartControl(1,'s')
fltCtrl.firstSpoolLap.setValue(1,'');

% Control surface parameters
fltCtrl.tanRoll.kp.setValue(0.2,'(rad)/(rad)');
fltCtrl.tanRoll.ki.setValue(0,'(rad)/(rad*s)');
fltCtrl.tanRoll.kd.setValue(0,'(rad)/(rad/s)');
fltCtrl.tanRoll.tau.setValue(1e-3,'s');

fltCtrl.rollMoment.kp.setValue((10e4)/(11*pi/180),'(N*m)/(rad)')
fltCtrl.rollMoment.ki.setValue(0,'(N*m)/(rad*s)');
fltCtrl.rollMoment.kd.setValue((10e4)/(11*pi/180),'(N*m)/(rad/s)');
fltCtrl.rollMoment.tau.setValue(0.001,'s');

fltCtrl.yawMoment.kp.setValue((1e3)/(10*pi/180),'(N*m)/(rad)');

fltCtrl.controlSigMax.upperLimit.setValue(30,'')
fltCtrl.controlSigMax.lowerLimit.setValue(-30,'')

fltCtrl.startControl.setValue(0,'s');

pitchKp = (1e5)/(2*pi/180);

%% Save
saveFile = saveBuildFile('fltCtrl',mfilename,'variant','FLIGHTCONTROLLER');
save(saveFile,'SPOOLINGCONTROLLER','-append')