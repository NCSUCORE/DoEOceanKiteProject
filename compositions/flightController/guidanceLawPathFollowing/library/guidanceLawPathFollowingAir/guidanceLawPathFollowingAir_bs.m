FLIGHTCONTROLLER = 'guidanceLawPathFollowing';
SPOOLINGCONTROLLER = 'netZeroSpoolingController';

fltCtrl = CTR.guideLawPthFlw;

fltCtrl.maxBank.upperLimit.setValue(50*pi/180,'');
fltCtrl.maxBank.lowerLimit.setValue(-50*pi/180,'');
fltCtrl.setPerpErrorVal(6*pi/180,'rad');
fltCtrl.setSearchSize(.5,'');
fltCtrl.setMinR(100,'m')
fltCtrl.setMaxR(200,'m')
fltCtrl.setElevatorReelInDef(0,'deg')
fltCtrl.setStartControl(1,'s')
fltCtrl.firstSpoolLap.setValue(1,'');

% Control surface parameters
fltCtrl.rollMoment.kp.setValue(47.8526*100,'(N*m)/(rad)')
fltCtrl.rollMoment.ki.setValue(0,'(N*m)/(rad*s)');
fltCtrl.rollMoment.kd.setValue(34.6167*100,'(N*m)/(rad/s)');
fltCtrl.rollMoment.tau.setValue(7.2340e-04,'s');

fltCtrl.yawMoment.kp.setValue(0,'(N*m)/(rad)');

fltCtrl.controlSigMax.upperLimit.setValue(30,'')
fltCtrl.controlSigMax.lowerLimit.setValue(-30,'')

fltCtrl.startControl.setValue(0,'s');
fltCtrl.rudderGain.setValue(0,'');

fltCtrl.targetForwardLength.setValue(35,'m');

fltCtrl.setFcnName('lemOfBooth','');

%% Save
saveFile = saveBuildFile('fltCtrl',mfilename,'variant','FLIGHTCONTROLLER');
save(saveFile,'SPOOLINGCONTROLLER','-append')