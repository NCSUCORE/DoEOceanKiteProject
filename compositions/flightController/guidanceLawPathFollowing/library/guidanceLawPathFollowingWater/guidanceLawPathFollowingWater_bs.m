FLIGHTCONTROLLER = 'guidanceLawPathFollowing';
SPOOLINGCONTROLLER = 'netZeroSpoolingController';

fltCtrl = guidanceLawPathFollow_class;

fltCtrl.pathWidth_deg		= 50;
fltCtrl.pathHeight_deg		= 10;
fltCtrl.pathElevation_deg	= 20;
fltCtrl.normalizedLforward	= 0.03;
fltCtrl.kiteMass			= 2.8570e+03;
fltCtrl.maxTanRoll_deg		= 30;
fltCtrl.initPathParameter	= 0;
fltCtrl.aileron_kp			= 0.5;
fltCtrl.aileron_kd			= 4*fltCtrl.aileron_kp;
fltCtrl.aileron_tau			= 0.001000;
fltCtrl.maxLap              = 20;

%% Save
saveFile = saveBuildFile('fltCtrl',mfilename,'variant','FLIGHTCONTROLLER');
save(saveFile,'SPOOLINGCONTROLLER','-append')