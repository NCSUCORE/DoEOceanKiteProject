FLIGHTCONTROLLER = 'pathFollowingController';
SPOOLINGCONTROLLER = 'intraSpoolingController';

fltCtrl = CTR.pthFlwCtrl;

fltCtrl.maxBank.upperLimit.setValue(20*pi/180,'');
fltCtrl.maxBank.lowerLimit.setValue(-20*pi/180,'');
fltCtrl.setPerpErrorVal(3*pi/180,'rad');
fltCtrl.setSearchSize(.5,'');
fltCtrl.setMinR(100,'m')
fltCtrl.setMaxR(200,'m')
fltCtrl.setElevatorReelInDef(20,'deg')
fltCtrl.setStartControl(1,'s')


% Spooling/tether control parameters
% fltCtrl.outRanges.setValue( [...
%     0           0.1250;
%     0.3450      0.6250;
%     0.8500      1.0000;],'');

% fltCtrl.winchSpeedIn.setValue(-2/3,'m/s')
% fltCtrl.winchSpeedOut.setValue(2/3,'m/s')
% fltCtrl.traditionalBool.setValue(1,'')

% Control surface parameters
fltCtrl.tanRoll.kp.setValue(0.2,'(rad)/(rad)');
fltCtrl.tanRoll.ki.setValue(0,'(rad)/(rad*s)');
fltCtrl.tanRoll.kd.setValue(0,'(rad)/(rad/s)');
fltCtrl.tanRoll.tau.setValue(1e-3,'s');

fltCtrl.rollMoment.kp.setValue((1e4)/(10*pi/180),'(N*m)/(rad)')
fltCtrl.rollMoment.ki.setValue(0,'(N*m)/(rad*s)');
fltCtrl.rollMoment.kd.setValue((1e4)/(10*pi/180),'(N*m)/(rad/s)');
fltCtrl.rollMoment.tau.setValue(0.001,'s');

fltCtrl.yawMoment.kp.setValue((1e3)/(10*pi/180),'(N*m)/(rad)');

fltCtrl.controlSigMax.upperLimit.setValue(30,'')
fltCtrl.controlSigMax.lowerLimit.setValue(-30,'')

fltCtrl.startControl.setValue(0,'s');

fltCtrl.elevatorReelInDef.setValue(23,'deg')

pitchKp = (1e5)/(2*pi/180);

%% Save
saveFile = saveBuildFile('fltCtrl',mfilename,'variant','FLIGHTCONTROLLER');
save(saveFile,'SPOOLINGCONTROLLER','-append')