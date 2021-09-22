FLIGHTCONTROLLER = 'periodicCtrlExp';
SPOOLINGCONTROLLER = 'netZeroSpoolingController';

fltCtrl = CTR.periodicExp;

% Control surface parameters
fltCtrl.rollCtrl.kp.setValue(1,'(deg)/(deg)');
fltCtrl.rollCtrl.ki.setValue(0,'(deg)/(deg*s)');
fltCtrl.rollCtrl.kd.setValue(0.5,'(deg)/(deg/s)');
fltCtrl.rollCtrl.tau.setValue(0.02,'s');

fltCtrl.yawCtrl.kp.setValue(0,'(deg)/(deg)');
fltCtrl.yawCtrl.ki.setValue(0,'(deg)/(deg*s)');
fltCtrl.yawCtrl.kd.setValue(0,'(deg)/(deg/s)');
fltCtrl.yawCtrl.tau.setValue(0.001,'s');

fltCtrl.controlSigMax.upperLimit.setValue(30,'')
fltCtrl.controlSigMax.lowerLimit.setValue(-30,'')
fltCtrl.elevCtrlMax.upperLimit.setValue(8,'')
fltCtrl.elevCtrlMax.lowerLimit.setValue(-30,'')

fltCtrl.rollAmp.setValue(30,'deg');
fltCtrl.yawAmp.setValue(180,'deg');
fltCtrl.period.setValue(10,'s');
fltCtrl.rollPhase.setValue(pi,'rad');
fltCtrl.yawPhase.setValue(2/10*pi,'rad');

fltCtrl.ccElevator.setValue(0,'deg');
fltCtrl.trimElevator.setValue(0,'deg');
fltCtrl.startCtrl.setValue(3,'s');
%% Save
saveFile = saveBuildFile('fltCtrl',mfilename,'variant','FLIGHTCONTROLLER');
save(saveFile,'SPOOLINGCONTROLLER','-append')