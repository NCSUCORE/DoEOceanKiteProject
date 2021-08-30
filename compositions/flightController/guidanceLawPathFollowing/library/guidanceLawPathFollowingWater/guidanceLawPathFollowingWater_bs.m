FLIGHTCONTROLLER = 'guidanceLawPathFollowing';
SPOOLINGCONTROLLER = 'netZeroSpoolingController';

fltCtrl = guidanceLawPathFollow_class;

fltCtrl.pathWidth_deg		= 50;
fltCtrl.pathHeight_deg		= 12;
fltCtrl.pathElevation_deg	= 20;

% pathFollowingBasis = [1.5,2.3,-.3,180*pi/180,125];
% fltCtrl.pathWidth_deg		= pathFollowingBasis(1)*2*180/pi;
% fltCtrl.pathHeight_deg		= 20.35;
% fltCtrl.pathElevation_deg	= abs(pathFollowingBasis(3))*180/pi;

fltCtrl.normalizedLforward	= 0.02;
fltCtrl.kiteMass			= 2.8570e+03;
fltCtrl.maxTanRoll_deg		= 40;
fltCtrl.initPathParameter	= 0.05;
fltCtrl.aileron_kp			= 0.9*5;
fltCtrl.aileron_kd			= 5*fltCtrl.aileron_kp;
fltCtrl.aileron_tau			= 0.0001000;
fltCtrl.maxLap              = 20;

% val = pathCoordEqn(fltCtrl.pathWidth_deg,fltCtrl.pathHeight_deg,fltCtrl.pathElevation_deg,1);

%% Save
saveFile = saveBuildFile('fltCtrl',mfilename,'variant','FLIGHTCONTROLLER');
save(saveFile,'SPOOLINGCONTROLLER','-append')