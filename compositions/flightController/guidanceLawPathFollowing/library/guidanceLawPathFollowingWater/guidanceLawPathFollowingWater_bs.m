FLIGHTCONTROLLER = 'guidanceLawPathFollowing';
SPOOLINGCONTROLLER = 'netZeroSpoolingController';

fltCtrl = CTR.guideLawPthFlw;

% guidance law controller parameters
fltCtrl.rollGainMultiplierPercentage.setValue(100,'');
fltCtrl.maxForwardLookupRatio.setValue(1/25,'');
fltCtrl.minForwardLookupRatio.setValue(0,'');
fltCtrl.maxBank.upperLimit.setValue(30*pi/180,'');
fltCtrl.maxBank.lowerLimit.setValue(-30*pi/180,'');
% elevation deflection at reel in
fltCtrl.setElevatorReelInDef(0,'deg')
% start control at time
fltCtrl.setStartControl(0,'s')
fltCtrl.firstSpoolLap.setValue(1,'');
% Control surface parameters
fltCtrl.rollMoment.kp.setValue((10e4)/(11*pi/180),'(N*m)/(rad)')
fltCtrl.rollMoment.ki.setValue(0,'(N*m)/(rad*s)');
fltCtrl.rollMoment.kd.setValue((10e4)/(11*pi/180),'(N*m)/(rad/s)');
fltCtrl.rollMoment.tau.setValue(0.001,'s');
% yaw moment
fltCtrl.yawMoment.kp.setValue((1e3)/(10*pi/180),'(N*m)/(rad)');
% max control surface deflections
fltCtrl.controlSigMax.upperLimit.setValue(15,'')
fltCtrl.controlSigMax.lowerLimit.setValue(-15,'')
% rudder gain
fltCtrl.rudderGain.setValue(0,'');
% path function
fltCtrl.setFcnName('lemOfBooth','');
% pitch gain
pitchKp = (1e5)/(2*pi/180);

%% Save
saveFile = saveBuildFile('fltCtrl',mfilename,'variant','FLIGHTCONTROLLER');
save(saveFile,'SPOOLINGCONTROLLER','-append')