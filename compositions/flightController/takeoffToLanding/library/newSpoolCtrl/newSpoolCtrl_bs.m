FLIGHTCONTROLLER = 'takeoffToLanding';
SPOOLINGCONTROLLER = 'universalSpoolingController';

fltCtrl = CTR.fltAndSpoolCtrl;
%% Control surface PID controllers
fltCtrl.tanRoll.kp.setValue(0.2,'(rad)/(rad)');
fltCtrl.tanRoll.ki.setValue(0,'(rad)/(rad*s)');
fltCtrl.tanRoll.kd.setValue(0,'(rad)/(rad/s)');
fltCtrl.tanRoll.tau.setValue(1e-3,'s');

fltCtrl.yawMoment.kp.setValue((1e3)/(10*pi/180),'(N*m)/(rad)');

fltCtrl.rollMoment.kp.setValue((10e4)/(11*pi/180),'(N*m)/(rad)')
fltCtrl.rollMoment.ki.setValue(0,'(N*m)/(rad*s)');
fltCtrl.rollMoment.kd.setValue((10e4)/(11*pi/180),'(N*m)/(rad/s)');
fltCtrl.rollMoment.tau.setValue(0.001,'s');

%% Saturations
fltCtrl.maxBank.upperLimit.setValue(20*pi/180,'');
fltCtrl.maxBank.lowerLimit.setValue(-20*pi/180,'');

%% Lower Level
fltCtrl.setSearchSize(.5,'');
fltCtrl.setPerpErrorVal(6*pi/180,'rad');
fltCtrl.setStartControl(0,'s')
fltCtrl.setElevatorReelInDef(20,'deg')
fltCtrl.firstSpoolLap.setValue(2,'');


%% Spooling
fltCtrl.setCtrlVecUpdateFcn('combinedCmd','')
fltCtrl.setTetherLengthSetpointFcn('combinedTLSP','')
fltCtrl.setWinchAndElevCmdFcn('combinedCmd','')
fltCtrl.setInitSpdVec([0 0 0 0 0],'m/s')
fltCtrl.setInitCtrlVec([.25 .14 0 0 0 0 0 0],'');
fltCtrl.setIntraDrift(10,'m');

%% Multicycle
fltCtrl.setInitTL(80,'m')
fltCtrl.setMaxTL(200,'m')
fltCtrl.nonXCurrentElevator.setKp(1,'(rad)/(rad)')
fltCtrl.nonXCurrentElevator.setKi(12,'(rad)/(rad*s)')
fltCtrl.nonXCurrentElevator.setKd(.005,'(rad)/(rad/s)')
fltCtrl.nonXCurrentElevator.setTau(.01,'s')
fltCtrl.setNonXCurrentElevation(30,'deg')
fltCtrl.setSwitchFilterConstant(.1,'s')
fltCtrl.setSwitchFilterDuration(10,'s')
fltCtrl.setNonXCurrentSpoolInGain(1.5,'')
fltCtrl.setBeginXCurrentFlowGain(1,'')
fltCtrl.setBeginNonXCurrentFlowGain(.5,'')

%% Save
saveFile = saveBuildFile('fltCtrl',mfilename,'variant','FLIGHTCONTROLLER');
save(saveFile,'SPOOLINGCONTROLLER','-append')