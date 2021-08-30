FLIGHTCONTROLLER = 'guidanceLawPathFollowing';
SPOOLINGCONTROLLER = 'netZeroSpoolingController';

fltCtrl = guidanceLawPathFollow_class;

fltCtrl.pathWidth_deg		= 50;
fltCtrl.pathHeight_deg		= 8;
fltCtrl.pathElevation_deg	= 20;

% pathFollowingBasis = [1.5,2.3,-.3,180*pi/180,125];
% fltCtrl.pathWidth_deg		= pathFollowingBasis(1)*2*180/pi;
% fltCtrl.pathHeight_deg		= 20.35;
% fltCtrl.pathElevation_deg	= abs(pathFollowingBasis(3))*180/pi;

fltCtrl.normalizedLforward	= 0.04;
fltCtrl.kiteMass			= 2.8570e+03;
fltCtrl.maxTanRoll_deg		= 40;
fltCtrl.initPathParameter	= 0.00;
fltCtrl.aileron_kp			= 0.9*2;
fltCtrl.aileron_kd			= 4*fltCtrl.aileron_kp;
fltCtrl.aileron_tau			= 0.01000;
fltCtrl.maxLap              = 20;

val = pathCoordEqn(fltCtrl.pathWidth_deg,fltCtrl.pathHeight_deg,fltCtrl.pathElevation_deg,1);

%% Save
saveFile = saveBuildFile('fltCtrl',mfilename,'variant','FLIGHTCONTROLLER');
save(saveFile,'SPOOLINGCONTROLLER','-append')