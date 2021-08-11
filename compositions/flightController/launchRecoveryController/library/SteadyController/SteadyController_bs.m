FLIGHTCONTROLLER = 'slController';
SPOOLINGCONTROLLER = 'universalSpoolingController';

fltCtrl = CTR.SLFAndSpoolCtrl;

fltCtrl.setSearchSize(.5,'');
fltCtrl.setElevatorReelInDef(20,'deg')
fltCtrl.firstSpoolLap.setValue(1,'');

%%  Control parameters
fltCtrl.rollMoment.kp.setValue(1000,'(N*m)/(rad)');    
fltCtrl.rollMoment.ki.setValue(0,'(N*m)/(rad*s)');
fltCtrl.rollMoment.kd.setValue(6000,'(N*m)/(rad/s)');      
fltCtrl.rollMoment.tau.setValue(3,'s');

fltCtrl.yawMoment.kp.setValue(1000,'(N*m)/(rad)');
fltCtrl.yawMoment.ki.setValue(5,'(N*m)/(rad*s)');
fltCtrl.yawMoment.kd.setValue(1000,'(N*m)/(rad/s)');      
fltCtrl.yawMoment.tau.setValue(0.001,'s');

fltCtrl.pitchMoment.kp.setValue(20000,'(N*m)/(rad)')
fltCtrl.pitchMoment.ki.setValue(100,'(N*m)/(rad*s)');
fltCtrl.pitchMoment.kd.setValue(25000,'(N*m)/(rad/s)');
fltCtrl.pitchMoment.tau.setValue(3,'s');

fltCtrl.pitchSP.kp.setValue(4,'(deg)/(deg)');
fltCtrl.pitchSP.ki.setValue(.05,'(deg)/(deg*s)');
fltCtrl.pitchSP.kd.setValue(8,'(deg)/(deg/s)');
fltCtrl.pitchSP.tau.setValue(.01,'s');

fltCtrl.rollSP.kp.setValue(2,'(deg)/(deg)');
fltCtrl.rollSP.ki.setValue(.05,'(deg)/(deg*s)');
fltCtrl.rollSP.kd.setValue(2,'(deg)/(deg/s)');
fltCtrl.rollSP.tau.setValue(.01,'s');

fltCtrl.controlSigMax.upperLimit.setValue(30,'')
fltCtrl.controlSigMax.lowerLimit.setValue(-30,'')

fltCtrl.pitchAngleMax.upperLimit.setValue(45,'')
fltCtrl.pitchAngleMax.lowerLimit.setValue(-45,'')

fltCtrl.startControl.setValue(0,'s');

fltCtrl.pitchCtrl.setValue(2,'');
fltCtrl.pitchConst.setValue(0,'deg');
fltCtrl.pitchTime.setValue([0 2000],'s');
fltCtrl.pitchLookup.setValue([0 0],'deg');
%% Spooling
fltCtrl.setCtrlVecUpdateFcn('combinedCmd','')
fltCtrl.setTetherLengthSetpointFcn('combinedTLSP','')
fltCtrl.setWinchAndElevCmdFcn('combinedCmd','')
fltCtrl.setInitSpdVec([0 0 0 0 0],'m/s')
fltCtrl.setInitCtrlVec([.25 .14 0 0 0 0 0 0],'');
fltCtrl.setIntraDrift(10,'m');
fltCtrl.setInitTL(80,'m')
fltCtrl.setMaxTL(400,'m')
fltCtrl.setSwitchFilterConstant(.1,'s')
fltCtrl.setSwitchFilterDuration(10,'s')
fltCtrl.setNonXCurrentSpoolInGain(1.5,'')
fltCtrl.setSpoolCtrlTimeConstant(2,'s')
fltCtrl.setNomSpoolSpeed(0,'m/s')
fltCtrl.setShortLeashLength(20,'m')
fltCtrl.LaRelevationSP.setValue(45,'deg');
fltCtrl.LaRelevationSPErr.setValue(2,'deg');
%% Save
saveFile = saveBuildFile('fltCtrl',mfilename,'variant','FLIGHTCONTROLLER');
save(saveFile,'SPOOLINGCONTROLLER','-append')