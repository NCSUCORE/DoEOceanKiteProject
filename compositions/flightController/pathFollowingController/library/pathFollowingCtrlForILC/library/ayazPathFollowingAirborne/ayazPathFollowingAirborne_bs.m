FLIGHTCONTROLLER = 'pathFollowingController';
SPOOLINGCONTROLLER = 'netZeroSpoolingController';

fltCtrl = CTR.pthFlwCtrl;

fltCtrl.maxBank.upperLimit.setValue(25*pi/180,'');
fltCtrl.maxBank.lowerLimit.setValue(-25*pi/180,'');
fltCtrl.setPerpErrorVal(6*pi/180,'rad');
fltCtrl.setSearchSize(.5,'');
fltCtrl.setMinR(100,'m')
fltCtrl.setMaxR(200,'m')
fltCtrl.setStartControl(1,'s')
fltCtrl.firstSpoolLap.setValue(1,'');

% velocity angle to tangent roll angle parameters
fltCtrl.tanRoll.kp.setValue(1,'(rad)/(rad)');
% these three (ki,kd,tau) are irrelevant cause the path following controller only uses
% the proportional gain
fltCtrl.tanRoll.ki.setValue(0,'(rad)/(rad*s)');
fltCtrl.tanRoll.kd.setValue(0,'(rad)/(rad/s)');
fltCtrl.tanRoll.tau.setValue(0,'s');

% moment vector calculation gains
fltCtrl.rollMoment.kp.setValue(47.8526*100,'(N*m)/(rad)')
fltCtrl.rollMoment.ki.setValue(0,'(N*m)/(rad*s)');
fltCtrl.rollMoment.kd.setValue(34.6167*100,'(N*m)/(rad/s)');
fltCtrl.rollMoment.tau.setValue(7.2340e-04,'s');

% yaw moment and rudder gain
fltCtrl.yawMoment.kp.setValue(0,'(N*m)/(rad)');
fltCtrl.rudderGain.setValue(0,'');

% elevation deflection at reel in
fltCtrl.setElevatorReelInDef(0,'deg')

% max control surface deflections
fltCtrl.controlSigMax.upperLimit.setValue(30,'')
fltCtrl.controlSigMax.lowerLimit.setValue(-30,'')
% path function
fltCtrl.setFcnName('lemOfBooth','');

fltCtrl.startControl.setValue(0,'s');

pitchKp = (1e5)/(2*pi/180);

fltCtrl.scale(1,1);


%% Save
saveFile = saveBuildFile('fltCtrl',mfilename,'variant','FLIGHTCONTROLLER');
save(saveFile,'SPOOLINGCONTROLLER','-append')
