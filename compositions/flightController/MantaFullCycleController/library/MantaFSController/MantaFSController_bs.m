FLIGHTCONTROLLER = 'MantaFSController';
SPOOLINGCONTROLLER = 'universalSpoolingController';

fltCtrl = CTR.MantaFullCycle;

%%  State Machine parameters 
fltCtrl.nonXCurrentSpoolInGain.setValue(1.5,'');
fltCtrl.maxTL.setValue(400,'m');

%%  Controller parameters
fltCtrl.SplRoll.kp.setValue(6,'(deg)/(rad)');
fltCtrl.SplRoll.ki.setValue(0.003,'(deg)/(rad*s)');
fltCtrl.SplRoll.kd.setValue(2,'(deg)/(rad/s)');
fltCtrl.SplRoll.tau.setValue(1,'s');

fltCtrl.SplYaw.kp.setValue(1e4,'(deg)/(rad)');
fltCtrl.SplYaw.ki.setValue(0,'(deg)/(rad*s)');
fltCtrl.SplYaw.kd.setValue(3,'(deg)/(rad/s)');
fltCtrl.SplYaw.tau.setValue(0.1,'s');

fltCtrl.SplPitch.kp.setValue(200,'(deg)/(rad)');
fltCtrl.SplPitch.ki.setValue(10,'(deg)/(rad*s)');
fltCtrl.SplPitch.kd.setValue(0,'(deg)/(rad/s)');
fltCtrl.SplPitch.tau.setValue(0.01,'s');

fltCtrl.SplPitchSP.kp.setValue(10,'(deg)/(deg)');
fltCtrl.SplPitchSP.ki.setValue(.01,'(deg)/(deg*s)');
fltCtrl.SplPitchSP.kd.setValue(0,'(deg)/(deg/s)');
fltCtrl.SplPitchSP.tau.setValue(.01,'s');
fltCtrl.SplPitchSPkpSlope.setValue(.02368,'');
fltCtrl.SplPitchSPkpInt.setValue(.5263,'');
fltCtrl.SplPitchSPkiSlope.setValue(7.895e-5,'');
fltCtrl.SplPitchSPkiInt.setValue(.008421,'');

fltCtrl.SplRollSP.kp.setValue(1,'(deg)/(deg)');
fltCtrl.SplRollSP.ki.setValue(0.025,'(deg)/(deg*s)');
fltCtrl.SplRollSP.kd.setValue(1,'(deg)/(deg/s)');
fltCtrl.SplRollSP.tau.setValue(1,'s');
fltCtrl.SplRollSPkpSlope.setValue(.02368,'');
fltCtrl.SplRollSPkpInt.setValue(.5263,'');
fltCtrl.SplRollSPkiSlope.setValue(7.895e-5,'');
fltCtrl.SplRollSPkiInt.setValue(.008421,'');

fltCtrl.PthRoll.kp.setValue(3e5,'(N*m)/(rad)');
fltCtrl.PthRoll.ki.setValue(0,'(N*m)/(rad*s)');
fltCtrl.PthRoll.kd.setValue(2.2e5,'(N*m)/(rad/s)');
fltCtrl.PthRoll.tau.setValue(1e-3,'s');

fltCtrl.PthYaw.kp.setValue(0,'(N*m)/(rad)');
fltCtrl.PthYaw.ki.setValue(0,'(N*m)/(rad*s)');
fltCtrl.PthYaw.kd.setValue(0,'(N*m)/(rad/s)');
fltCtrl.PthYaw.tau.setValue(1e-3,'s');

fltCtrl.PthPitch.kp.setValue(00,'(N*m)/(rad)');
fltCtrl.PthPitch.ki.setValue(0,'(N*m)/(rad*s)');
fltCtrl.PthPitch.kd.setValue(0,'(N*m)/(rad/s)');
fltCtrl.PthPitch.tau.setValue(0.001,'s');

fltCtrl.PthTanRoll.kp.setValue(0.8,'(rad)/(rad)');
fltCtrl.PthTanRoll.ki.setValue(0,'(rad)/(rad*s)');
fltCtrl.PthTanRoll.kd.setValue(0,'(rad)/(rad/s)');
fltCtrl.PthTanRoll.tau.setValue(1e-3,'s');

fltCtrl.PthAlpha.kp.setValue(.3,'(kN)/(rad)');
fltCtrl.PthAlpha.ki.setValue(0,'(kN)/(rad*s)');
fltCtrl.PthAlpha.kd.setValue(0,'(kN)/(rad/s)');
fltCtrl.PthAlpha.tau.setValue(1e-3,'s');

%%  Saturations
fltCtrl.maxBank.upperLimit.setValue(20*pi/180,'');
fltCtrl.maxBank.lowerLimit.setValue(-20*pi/180,'');

fltCtrl.controlSigMax.upperLimit.setValue(30,'')
fltCtrl.controlSigMax.lowerLimit.setValue(-30,'')

fltCtrl.SplPitchMax.upperLimit.setValue(45,'')
fltCtrl.SplPitchMax.lowerLimit.setValue(-45,'')

fltCtrl.PitchMomMax.upperLimit.setValue(1e3,'')
fltCtrl.PitchMomMax.lowerLimit.setValue(-1e3,'')

fltCtrl.thrLengthMax.upperLimit.setValue(600,'')
fltCtrl.thrLengthMax.lowerLimit.setValue(0,'')

fltCtrl.Tmax.setValue(30,'kN');

%%  Path Following 
fltCtrl.searchSize.setValue(.5,'');
fltCtrl.perpErrorVal.setValue(6*pi/180,'rad');
fltCtrl.startControl.setValue(0,'s');
fltCtrl.rudderGain.setValue(0,'');

%% Spooling
fltCtrl.winchSpeedIn.setValue(-0.25,'m/s');
fltCtrl.winchSpeedOut.setValue(0.25,'m/s');
fltCtrl.firstSpoolLap.setValue(10,'');
fltCtrl.nomSpoolSpeed.setValue(0.25,'m/s');
fltCtrl.shortLeashLength.setValue(20,'m');
fltCtrl.LaRelevationSP.setValue(45,'deg');
fltCtrl.LaRelevationSPErr.setValue(1,'deg');

%%  Setpoint method ctrl 
fltCtrl.AoACtrl.setValue(1,'');                   
fltCtrl.AoASP.setValue(0,'');                   
fltCtrl.AoAConst.setValue(14*pi/180,'deg');
fltCtrl.pitchCtrl.setValue(2,'');
fltCtrl.pitchConst.setValue(0,'deg');
fltCtrl.yawCtrl.setValue(1,'');
fltCtrl.yawConst.setValue(0,'deg');
fltCtrl.optAltitude.setValue(200,'m');

%% Save
saveFile = saveBuildFile('fltCtrl',mfilename,'variant','FLIGHTCONTROLLER');
save(saveFile,'SPOOLINGCONTROLLER','-append')