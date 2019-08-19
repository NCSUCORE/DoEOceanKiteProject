FLIGHTCONTROLLER = 'pathFollowingController';
SPOOLINGCONTROLLER = 'Trad';
fltCtrl = CTR.pthFlwCtrl;
fltCtrl.maxBank.upperLimit.setValue(20*pi/180,'');
fltCtrl.maxBank.lowerLimit.setValue(-20*pi/180,'');

fltCtrl.velAng.tau.setValue(.01,'s');

fltCtrl.rollMoment.kp.setValue(4e5,'(N*m)/(rad)');

fltCtrl.rollMoment.tau.setValue (.01,'s');

fltCtrl.setPerpErrorVal(7*pi/180,'rad');
fltCtrl.setSearchSize(.5,'');
fltCtrl.setMinR(100,'m')
fltCtrl.setMaxR(200,'m')
fltCtrl.setElevatorReelInDef(25,'deg')
fltCtrl.setStartControl(1,'s')
%% Save
saveBuildFile('fltCtrl',mfilename,'variant','FLIGHTCONTROLLER');