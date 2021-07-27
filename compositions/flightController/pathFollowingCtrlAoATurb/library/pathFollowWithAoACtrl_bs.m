FLIGHTCONTROLLER = 'pathFollowingCtrlAoATurb';
SPOOLINGCONTROLLER = 'netZeroSpoolingController';

fltCtrl = CTR.pthFlwCtrlM;

%% FPID Controller parameters
fltCtrl.tanRoll.kp.setValue(0.2,'(rad)/(rad)');
fltCtrl.tanRoll.ki.setValue(0,'(rad)/(rad*s)');
fltCtrl.tanRoll.kd.setValue(0,'(rad)/(rad/s)');
fltCtrl.tanRoll.tau.setValue(10,'s');

fltCtrl.rollMoment.kp.setValue(15000,'(N*m)/(rad)')
fltCtrl.rollMoment.ki.setValue(00,'(N*m)/(rad*s)');
fltCtrl.rollMoment.kd.setValue(12000,'(N*m)/(rad/s)');
fltCtrl.rollMoment.tau.setValue(0.001,'s');

fltCtrl.pitchMoment.kp.setValue(2.1e5,'(N*m)/(rad)')
fltCtrl.pitchMoment.ki.setValue(1700,'(N*m)/(rad*s)');
fltCtrl.pitchMoment.kd.setValue(0,'(N*m)/(rad/s)');
fltCtrl.pitchMoment.tau.setValue(0.001,'s');

fltCtrl.yawMoment.kp.setValue(2500,'(N*m)/(rad)');

fltCtrl.elevCtrl.kp.setValue(125,'(deg)/(rad)');
fltCtrl.elevCtrl.ki.setValue(1,'(deg)/(rad*s)');
fltCtrl.elevCtrl.kd.setValue(0,'(deg)/(rad/s)');
fltCtrl.elevCtrl.tau.setValue(0.001,'s');

fltCtrl.rollCtrl.kp.setValue(150,'(deg)/(rad)');
fltCtrl.rollCtrl.ki.setValue(1,'(deg)/(rad*s)');
fltCtrl.rollCtrl.kd.setValue(150,'(deg)/(rad/s)');
fltCtrl.rollCtrl.tau.setValue(0.001,'s');

fltCtrl.alphaCtrl.kp.setValue(.2,'(rad)/(kN)');
fltCtrl.alphaCtrl.ki.setValue(.08,'(rad)/(kN*s)');

fltCtrl.RPMCtrl.kp.setValue(100,'()/(kN)');

fltCtrl.yawCtrl.kp.setValue(200,'(deg)/(rad)');
fltCtrl.yawCtrl.ki.setValue(1,'(deg)/(rad*s)');
fltCtrl.yawCtrl.kd.setValue(0,'(deg)/(rad/s)');
fltCtrl.yawCtrl.tau.setValue(0.001,'s');

%%  Saturations
fltCtrl.maxBank.upperLimit.setValue(20*pi/180,'');
fltCtrl.maxBank.lowerLimit.setValue(-20*pi/180,'');
fltCtrl.controlSigMax.upperLimit.setValue(30,'')
fltCtrl.controlSigMax.lowerLimit.setValue(-30,'')
fltCtrl.elevCtrlMax.upperLimit.setValue(30,'')
fltCtrl.elevCtrlMax.lowerLimit.setValue(-30,'')

%%  Path following parameters
fltCtrl.winchSpeedIn.setValue(0.25,'m/s');
fltCtrl.winchSpeedOut.setValue(0.25,'m/s');
fltCtrl.setSearchSize(.5,'');
fltCtrl.setPerpErrorVal(6*pi/180,'rad');
fltCtrl.setMinR(80,'m')
fltCtrl.setMaxR(160,'m')
fltCtrl.startControl.setValue(0,'s');
fltCtrl.setElevatorConst(-3,'deg')
fltCtrl.setStartControl(1,'s')
fltCtrl.firstSpoolLap.setValue(1000,'');
fltCtrl.rudderGain.setValue(-1,'');

%%  Various control flags and set values
fltCtrl.RCtrl.setValue(0,'');
fltCtrl.AoACtrl.setValue(1,'');                   
fltCtrl.AoASP.setValue(1,'');                   
fltCtrl.AoAConst.setValue(14*pi/180,'deg');
fltCtrl.AoAmin.setValue(-5*pi/180,'deg');
fltCtrl.RPMConst.setValue(4.188,'');
fltCtrl.RPMmax.setValue(6,'');
fltCtrl.Tmax.setValue(30,'kN');
fltCtrl.TmaxCtrl.setValue(1,'');
fltCtrl.optAltitude.setValue(200,'m');
%% Save
saveFile = saveBuildFile('fltCtrl',mfilename,'variant','FLIGHTCONTROLLER');
save(saveFile,'SPOOLINGCONTROLLER','-append')