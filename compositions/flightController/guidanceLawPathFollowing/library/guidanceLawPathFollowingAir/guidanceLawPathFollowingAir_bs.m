FLIGHTCONTROLLER = 'guidanceLawPathFollowing';
SPOOLINGCONTROLLER = 'netZeroSpoolingController';

fltCtrl = CTR.guideLawPthFlw;

fltCtrl.maxBank.upperLimit.setValue(20*pi/180,'');
fltCtrl.maxBank.lowerLimit.setValue(-20*pi/180,'');
fltCtrl.setPerpErrorVal(6*pi/180,'rad');
fltCtrl.setSearchSize(.5,'');
fltCtrl.setMinR(100,'m')
fltCtrl.setMaxR(200,'m')
fltCtrl.setElevatorReelInDef(0,'deg')
fltCtrl.setStartControl(1,'s')
fltCtrl.firstSpoolLap.setValue(1,'');

% Control surface parameters
tanRollGain = 1;
rollMkp = 3;
rollMkd = 6;

fltCtrl.tanRoll.kp.setValue(tanRollGain,'(deg)/(deg)');
fltCtrl.tanRoll.ki.setValue(0,'(deg)/(deg*s)');
fltCtrl.tanRoll.kd.setValue(0,'(deg)/(deg/s)');
fltCtrl.tanRoll.tau.setValue(1e-3,'s');

fltCtrl.rollMoment.kp.setValue(rollMkp,'(N*m)/(rad)')
fltCtrl.rollMoment.ki.setValue(0,'(N*m)/(rad*s)');
fltCtrl.rollMoment.kd.setValue(rollMkd,'(N*m)/(rad/s)');
fltCtrl.rollMoment.tau.setValue(0.0001,'s');

fltCtrl.yawMoment.kp.setValue(0.1/(10*pi/180),'(N*m)/(rad)');

fltCtrl.controlSigMax.upperLimit.setValue(30,'')
fltCtrl.controlSigMax.lowerLimit.setValue(-30,'')

fltCtrl.startControl.setValue(0,'s');
fltCtrl.rudderGain.setValue(0,'');

fltCtrl.targetForwardLength.setValue(20,'m');

fltCtrl.setFcnName('lemOfBooth','');

pitchKp = (100)/(2*pi/180);

%% Save
saveFile = saveBuildFile('fltCtrl',mfilename,'variant','FLIGHTCONTROLLER');
save(saveFile,'SPOOLINGCONTROLLER','-append')