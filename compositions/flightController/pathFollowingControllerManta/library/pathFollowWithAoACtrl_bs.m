FLIGHTCONTROLLER = 'pathFollowingControllerManta';
SPOOLINGCONTROLLER = 'netZeroSpoolingController';

fltCtrl = CTR.pthFlwCtrlM;

fltCtrl.maxBank.upperLimit.setValue(20*pi/180,'');
fltCtrl.maxBank.lowerLimit.setValue(-20*pi/180,'');
fltCtrl.setPerpErrorVal(6*pi/180,'rad');
fltCtrl.setSearchSize(.5,'');
fltCtrl.setMinR(80,'m')
fltCtrl.setMaxR(160,'m')
fltCtrl.setElevatorConst(0,'deg')
fltCtrl.setStartControl(1,'s')
fltCtrl.firstSpoolLap.setValue(1000,'');

% Control surface parameters
fltCtrl.tanRoll.kp.setValue(0.2,'(rad)/(rad)');
fltCtrl.tanRoll.ki.setValue(0,'(rad)/(rad*s)');
fltCtrl.tanRoll.kd.setValue(0,'(rad)/(rad/s)');
fltCtrl.tanRoll.tau.setValue(1e-3,'s');

fltCtrl.rollMoment.kp.setValue(3e5,'(N*m)/(rad)')
fltCtrl.rollMoment.ki.setValue(00,'(N*m)/(rad*s)');
fltCtrl.rollMoment.kd.setValue(2.2e5,'(N*m)/(rad/s)');
fltCtrl.rollMoment.tau.setValue(0.001,'s');

fltCtrl.pitchMoment.kp.setValue(2.1e5,'(N*m)/(rad)')
fltCtrl.pitchMoment.ki.setValue(1700,'(N*m)/(rad*s)');
fltCtrl.pitchMoment.kd.setValue(0,'(N*m)/(rad/s)');
fltCtrl.pitchMoment.tau.setValue(0.001,'s');

fltCtrl.yawMoment.kp.setValue(2300,'(N*m)/(rad)');

fltCtrl.elevCtrl.kp.setValue(125,'(deg)/(rad)');
fltCtrl.elevCtrl.ki.setValue(1,'(deg)/(rad*s)');
fltCtrl.elevCtrl.kd.setValue(0,'(deg)/(rad/s)');
fltCtrl.elevCtrl.tau.setValue(0.001,'s');

fltCtrl.rollCtrl.kp.setValue(200,'(deg)/(rad)');
fltCtrl.rollCtrl.ki.setValue(1,'(deg)/(rad*s)');
fltCtrl.rollCtrl.kd.setValue(0,'(deg)/(rad/s)');
fltCtrl.rollCtrl.tau.setValue(0.001,'s');

fltCtrl.alphaCtrl.kp.setValue(.2,'(rad)/(kN)');
% RPM PID gains
fltCtrl.RPMCtrl.kp.setValue(100,'(rad/s)/(kN)');

fltCtrl.yawCtrl.kp.setValue(200,'(deg)/(rad)');
fltCtrl.yawCtrl.ki.setValue(1,'(deg)/(rad*s)');
fltCtrl.yawCtrl.kd.setValue(0,'(deg)/(rad/s)');
fltCtrl.yawCtrl.tau.setValue(0.001,'s');

fltCtrl.controlSigMax.upperLimit.setValue(30,'')
fltCtrl.controlSigMax.lowerLimit.setValue(-30,'')
fltCtrl.elevCtrlMax.upperLimit.setValue(8,'')
fltCtrl.elevCtrlMax.lowerLimit.setValue(-30,'')

fltCtrl.startControl.setValue(0,'s');
fltCtrl.winchSpeedIn.setValue(-0.25,'m/s');

fltCtrl.AoACtrl.setValue(1,'');                   
fltCtrl.AoASP.setValue(0,'');                   
fltCtrl.AoAConst.setValue(14*pi/180,'deg');
fltCtrl.AoAmin.setValue(-5*pi/180,'deg');
% RPM control constant Parameters
fltCtrl.RPMConst.setValue(100,'rad/s');
fltCtrl.RPMmax.setValue(200,'rad/s');

fltCtrl.Tmax.setValue(30,'kN');
fltCtrl.TmaxCtrl.setValue(1,'');
fltCtrl.optAltitude.setValue(200,'m');
%% Save
saveFile = saveBuildFile('fltCtrl',mfilename,'variant','FLIGHTCONTROLLER');
save(saveFile,'SPOOLINGCONTROLLER','-append')