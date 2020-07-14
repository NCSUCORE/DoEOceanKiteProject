FLIGHTCONTROLLER = 'LaRController';
SPOOLINGCONTROLLER = 'universalSpoolingController';

fltCtrl = CTR.SLFAndSpoolCtrl;

fltCtrl.setSearchSize(.5,'');
fltCtrl.setElevatorReelInDef(20,'deg')
fltCtrl.firstSpoolLap.setValue(1,'');

%%  Control surface parameters
fltCtrl.tanRoll.kp.setValue(0.2,'(rad)/(rad)');
fltCtrl.tanRoll.ki.setValue(0,'(rad)/(rad*s)');
fltCtrl.tanRoll.kd.setValue(0,'(rad)/(rad/s)');
fltCtrl.tanRoll.tau.setValue(1e-3,'s');

fltCtrl.rollMoment.kp.setValue((10e4)/(11*pi/180),'(N*m)/(rad)')
fltCtrl.rollMoment.ki.setValue(0,'(N*m)/(rad*s)');
fltCtrl.rollMoment.kd.setValue((10e4)/(11*pi/180),'(N*m)/(rad/s)');
fltCtrl.rollMoment.tau.setValue(0.001,'s');

fltCtrl.yawMoment.kp.setValue((1e3)/(10*pi/180),'(N*m)/(rad)');

fltCtrl.pitchSP.kp.setValue(3,'(deg)/(deg)');
fltCtrl.pitchSP.ki.setValue(.1,'(deg)/(deg*s)');
fltCtrl.pitchSP.kd.setValue(0,'(deg)/(deg/s)');
fltCtrl.pitchSP.tau.setValue(.01,'s');

fltCtrl.elevCmd.kp.setValue(5,'(deg)/(rad)');
fltCtrl.elevCmd.ki.setValue(5,'(deg)/(rad*s)');
fltCtrl.elevCmd.kd.setValue(0,'(deg)/(rad/s)');
fltCtrl.elevCmd.tau.setValue(.01,'s');

fltCtrl.controlSigMax.upperLimit.setValue(30,'')
fltCtrl.controlSigMax.lowerLimit.setValue(-30,'')

fltCtrl.pitchAngleMax.upperLimit.setValue(15,'')
fltCtrl.pitchAngleMax.lowerLimit.setValue(-40,'')

fltCtrl.startControl.setValue(0,'s');

fltCtrl.RelevationSP.setValue(30,'deg');
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

%% Save
saveFile = saveBuildFile('fltCtrl',mfilename,'variant','FLIGHTCONTROLLER');
save(saveFile,'SPOOLINGCONTROLLER','-append')