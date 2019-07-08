clc
format compact

% run this to load tether tension data %
% clear
% mag = load('mag.mat');
% mag = mag.mag;
% position = load('pos.mat');
% position = position.position;

% run this to set magnitude to zero %
% mag.Data = zeros

% run this to set magnitude to average magnitude %
% mag.Data = mean(mag.Data)*ones(size(mag.Data));

% run this to set average direction %
% for i = 1:3
%     position.Data(:,i) = mean(position.Data(:,i))*ones(size(position.Data(:,i)));
% end

% create buses
createConstantUniformFlowEnvironmentBus
createOneTetherThreeSurfaceCtrlBus
createThrAttachPtKinematicsBus

% simulation time
sim_time = 360;

% geometry of platform
vol = 3.5;
h = vol^(1/3);
% platform properties
buoyF = 1.5;
mass = 1000*vol/buoyF;
m = mass;
inertiaMatrix = ((1/6)*mass*h^2).*eye(3);

% initial conditions
initPos = [0 0 100];
initVel = [1e-3 0 0];
initEulerAngles = (pi/180).*[0 0 0];
initAngVel = [0 0 0];

% environmental properties
env = ENV.env;
env.addFlow({'water'},'FlowDensities',1000);
env.water.velVec.setValue([.05 0 0],'m/s');
grav = env.gravAccel.Value;
rho = env.water.density.Value;

% tether attachment properties
% Pt: attachment point on platform relative to center of mass
% GndPos: attachment point on ground relative to ground frame
dist = 50;
thr1Pt = [0 1 0];
thr1GndPos = [0 dist 0];
thr1GndVel = [0 0 0];
thr2Pt = [cosd(30),-(1/2),0];
thr2GndPos = [dist*cosd(30), -dist*(1/2), 0];
thr2GndVel = [0 0 0];
thr3Pt = [-cosd(30),-(1/2),0];
thr3GndPos = [-dist*cosd(30), -dist*(1/2), 0];
thr3GndVel = [0 0 0];
CB2CMVec = [0 0 0];
% tether properties
tethDiameter = 0.05;
E = 3.8e9;
zeta = 0.05;
rho_tether = 1300;
Cd = 0.5;
tetherLengths = [norm(initPos+thr1Pt-thr1GndPos),norm(initPos+thr2Pt-thr2GndPos),...
    norm(initPos+thr2Pt-thr2GndPos)];

% applied tether tensions instead of calculated tether tensions for
% debugging
% % % % tenMag = -4152.4818783275;
% % % % 
% % % % thr1ten = tenMag*(initPos+thr1Pt-thr1GndPos)/tetherLengths(1);
% % % % thr2ten = tenMag*(initPos+thr2Pt-thr2GndPos)/tetherLengths(2);
% % % % thr3ten = tenMag*(initPos+thr3Pt-thr3GndPos)/tetherLengths(3);
% % % % 
% % % % thr3ten(2) = -(thr1ten(2)+thr2ten(2));
% % % % thr1ten + thr2ten + thr3ten
% % % % 
% % % % rho*grav*vol-mass*grav+thr1ten(3)*3

% number of tethers
N = 2;

thrs = OCT.tethers;
thrs.numTethers.setValue(3,'');
thrs.numNodes.setValue(N,'')
thrs.build;

thrs.tether1.initGndNodePos.setValue(thr1GndPos,'m');
thrs.tether1.initAirNodePos.setValue(initPos + (rotation_sequence(initEulerAngles)*thr1Pt')','m');
thrs.tether1.initGndNodeVel.setValue([0 0 0],'m/s');
thrs.tether1.initAirNodeVel.setValue(initVel,'m/s');
thrs.tether1.diameter.setValue(tethDiameter,'m');
thrs.tether1.youngsMod.setValue(E,'Pa');
thrs.tether1.dampingRatio.setValue(zeta,'');
thrs.tether1.dragCoeff.setValue(Cd,'');
thrs.tether1.density.setValue(rho_tether,'kg/m^3');
thrs.tether1.vehicleMass.setValue(mass,'kg');
thrs.tether1.setDragEnable(true,'');
thrs.tether1.setSpringDamperEnable(true,'');
thrs.tether1.setNetBuoyEnable(true,'');

thrs.tether2.initGndNodePos.setValue(thr2GndPos,'m');
thrs.tether2.initAirNodePos.setValue(initPos + (rotation_sequence(initEulerAngles)*thr2Pt')','m');
thrs.tether2.initGndNodeVel.setValue([0 0 0],'m/s');
thrs.tether2.initAirNodeVel.setValue(initVel,'m/s');
thrs.tether2.diameter.setValue(tethDiameter,'m');
thrs.tether2.youngsMod.setValue(E,'Pa');
thrs.tether2.dampingRatio.setValue(zeta,'');
thrs.tether2.dragCoeff.setValue(Cd,'');
thrs.tether2.density.setValue(rho_tether,'kg/m^3');
thrs.tether2.vehicleMass.setValue(mass,'kg');
thrs.tether2.setDragEnable(true,'');
thrs.tether2.setSpringDamperEnable(true,'');
thrs.tether2.setNetBuoyEnable(true,'');

thrs.tether3.initGndNodePos.setValue(thr3GndPos,'m');
thrs.tether3.initAirNodePos.setValue(initPos + (rotation_sequence(initEulerAngles)*thr3Pt')','m');
thrs.tether3.initGndNodeVel.setValue([0 0 0],'m/s');
thrs.tether3.initAirNodeVel.setValue(initVel,'m/s');
thrs.tether3.diameter.setValue(tethDiameter,'m');
thrs.tether3.youngsMod.setValue(E,'Pa');
thrs.tether3.dampingRatio.setValue(zeta,'');
thrs.tether3.dragCoeff.setValue(Cd,'');
thrs.tether3.density.setValue(rho_tether,'kg/m^3');
thrs.tether3.vehicleMass.setValue(mass,'kg');
thrs.tether3.setDragEnable(true,'');
thrs.tether3.setSpringDamperEnable(true,'');
thrs.tether3.setNetBuoyEnable(true,'');

% distance from previously calculated tether tension to center of mass
airTethDist = [0 0 h/2];

% ground station moment arms
gndStnMmtArms(1).posVec = thr1GndPos;
gndStnMmtArms(2).posVec = thr2GndPos;
gndStnMmtArms(3).posVec = thr3GndPos;

% platform moment arms
bodyMmtArms(1).posVec = thr1Pt;
bodyMmtArms(2).posVec = thr2Pt;
bodyMmtArms(3).posVec = thr3Pt;

% (theoretical) tether attachment points for a lifting body on platform
liftingBodyThrAttch(1).posVec = [0 1/2 1/2];
liftingBodyThrAttch(2).posVec = [1/2*cosd(30), -1/2*(1/2), 1/2];
liftingBodyThrAttch(3).posVec = [-1/2*cosd(30), -1/2*(1/2), 1/2];

% circulation data
v = 0.6;
vsquared = v^2;
cd = .8;
A = vol^(2/3);
oceanPeriod = 20;
xOn = 1; % 1 = on, 0 = off
zOn = 1;

% ocean properties
waveAmp = 0;
wavePeriod = oceanPeriod;
oceanDepth = 105;

sim('groundStation001_th')

% plot relevent data
figure
depth.plot
title('Depth')
ylabel('Depth (m)')
figure
eulang.plot
legend('roll','pitch','yaw')
ylabel('Euler Angles (rad)')


%% partially submersed data (don't need to run!)
dep = get(logsout,7);
figure
dep.Values.plot
subpo = get(logsout,7)
meanz = mean(subpo.Values.Data(3,1,:))
meanx = mean(subpo.Values.Data(1,1,:))

initPos = [meanx, 0, meanz];

oceanDepth = meanz;

sim('groundStation001_th')

figure
dep1 = get(logsout, 7);
dep1.Values.plot