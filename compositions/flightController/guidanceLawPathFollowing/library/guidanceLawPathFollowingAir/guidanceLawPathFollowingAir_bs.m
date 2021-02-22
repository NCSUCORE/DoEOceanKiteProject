FLIGHTCONTROLLER = 'guidanceLawPathFollowing';
SPOOLINGCONTROLLER = 'netZeroSpoolingController';

fltCtrl = CTR.guideLawPthFlw;

% guidance law controller parameters
fltCtrl.rollGainMultiplierPercentage.setValue(100,'');
fltCtrl.maxForwardLookupRatio.setValue(1/30,'');
fltCtrl.minForwardLookupRatio.setValue(0,'');
fltCtrl.maxBank.upperLimit.setValue(20*pi/180,'');
fltCtrl.maxBank.lowerLimit.setValue(-20*pi/180,'');
% elevation deflection at reel in
fltCtrl.setElevatorReelInDef(0,'deg')
fltCtrl.setStartControl(1,'s')
fltCtrl.firstSpoolLap.setValue(1,'');
% moment vector calculation gains
fltCtrl.rollMoment.kp.setValue(47.8526*100,'(N*m)/(rad)')
fltCtrl.rollMoment.ki.setValue(0,'(N*m)/(rad*s)');
fltCtrl.rollMoment.kd.setValue(34.6167*100,'(N*m)/(rad/s)');
fltCtrl.rollMoment.tau.setValue(7.2340e-04,'s');

% yaw moment
fltCtrl.yawMoment.kp.setValue(0,'(N*m)/(rad)');
fltCtrl.rudderGain.setValue(0,'');

% max control surface deflections
fltCtrl.controlSigMax.upperLimit.setValue(30,'')
fltCtrl.controlSigMax.lowerLimit.setValue(-30,'')
% path function
fltCtrl.setFcnName('lemOfBooth','');

%% Save
saveFile = saveBuildFile('fltCtrl',mfilename,'variant','FLIGHTCONTROLLER');
save(saveFile,'SPOOLINGCONTROLLER','-append')