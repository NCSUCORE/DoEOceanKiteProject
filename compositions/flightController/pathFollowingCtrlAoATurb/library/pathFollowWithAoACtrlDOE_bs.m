FLIGHTCONTROLLER = 'pathFollowingCtrlAoATurb';
SPOOLINGCONTROLLER = 'netZeroSpoolingController';

fltCtrl = CTR.pthFlwCtrlM;

%% FPID Controller parameters
fltCtrl.AoAConst.setValue(18*pi/180,'deg')
%             fltCtrl.tanRoll.kp.setValue(0.8,fltCtrl.tanRoll.kp.Unit)
fltCtrl.rollMoment.kp.setValue((10e4)/(11*pi/180),'(N*m)/(rad)')
fltCtrl.rollMoment.ki.setValue(0,'(N*m)/(rad*s)');
fltCtrl.rollMoment.kd.setValue((10e4)/(11*pi/180),'(N*m)/(rad/s)');
fltCtrl.rollMoment.tau.setValue(0.001,'s');

fltCtrl.tanRoll.kp.setValue(0.4,'(rad)/(rad)');
fltCtrl.tanRoll.ki.setValue(0,'(rad)/(rad*s)');
fltCtrl.tanRoll.kd.setValue(0.2,'(rad)/(rad/s)')
fltCtrl.tanRoll.tau.setValue(1,'s')
fltCtrl.refFiltTau.setValue(3,'s')


fltCtrl.pitchMoment.kp.setValue(20000,fltCtrl.pitchMoment.kp.Unit)
fltCtrl.pitchMoment.ki.setValue(10000,fltCtrl.pitchMoment.ki.Unit)
fltCtrl.pitchMoment.kd.setValue(12000,fltCtrl.pitchMoment.kd.Unit)
fltCtrl.pitchMoment.tau.setValue(1,'s')

fltCtrl.yawMoment.kp.setValue((1e3)/(10*pi/180),'(N*m)/(rad)');

fltCtrl.alphaCtrl.kp.setValue(0.2,fltCtrl.alphaCtrl.kp.Unit)
fltCtrl.alphaCtrl.kd.setValue(0.2,fltCtrl.alphaCtrl.kd.Unit)
fltCtrl.alphaCtrl.ki.setValue(0.18,fltCtrl.alphaCtrl.ki.Unit)
fltCtrl.alphaCtrl.tau.setValue(2,'s');


%%  Saturations
fltCtrl.maxBank.upperLimit.setValue(.8,'');
fltCtrl.maxBank.lowerLimit.setValue(-.8,'');
fltCtrl.controlSigMax.upperLimit.setValue(30,'')
fltCtrl.controlSigMax.lowerLimit.setValue(-30,'')
fltCtrl.elevCtrlMax.upperLimit.setValue(30,'')
fltCtrl.elevCtrlMax.lowerLimit.setValue(-30,'')

%%  Path following parameters
fltCtrl.winchSpeedIn.setValue(0.25,'m/s');
fltCtrl.winchSpeedOut.setValue(0.25,'m/s');
fltCtrl.setSearchSize(.5,'');
fltCtrl.setPerpErrorVal(.1,'rad');
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
fltCtrl.AoAConst.setValue(10*pi/180,'deg');
fltCtrl.AoAmin.setValue(-5*pi/180,'deg');

fltCtrl.TmaxCtrl.setValue(1,'');
fltCtrl.optAltitude.setValue(200,'m');
fltCtrl.Ts.setValue(0.01,'s');
%% Save
saveFile = saveBuildFile('fltCtrl',mfilename,'variant','FLIGHTCONTROLLER');
save(saveFile,'SPOOLINGCONTROLLER','-append')