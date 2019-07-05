clc
format compact

% run this to load tether tension data
% clear
% load('custom_constant_baseline_1106_104556.mat')

% actual data %
% position = tsc.positionGFC;
% mag = tsc.tetherTensionMag;

% average mag %
% mag.Data = mean(mag.Data)*ones(size(mag.Data));

% average direction %
% for i = 1:3
%     position.Data(:,i) = mean(position.Data(:,i))*ones(size(position.Data(:,i)));
% end

% createConstantUniformFlowEnvironmentBus
% createOneTetherThreeSurfaceCtrlBus
% createThrAttachPtKinematicsBus

sim_time = 3600;

% number of tethers
N = 2;

rho = 1000;
vol = 3.5;
h = vol^(1/3);
grav = 9.81;

env.water.velVec = SIM.parameter('Value',[0 0 0]);

buoyF = 1.5;
mass = rho*vol/buoyF;
m = mass;

inertiaMatrix = ((1/6)*mass*h^2).*eye(3);

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

dia_t = 0.05;
E = 3.8e9;
zeta = 0.05;
rho_tether = 1300;
Cd = 0.5;

initPos = [0 0 100];
initVel = [1e-3 0 0];
initEulerAngles = (pi/180).*[0 0 0];
initAngVel = [0 0 0];

tetherLengths = [norm(initPos+thr1Pt-thr1GndPos),norm(initPos+thr2Pt-thr2GndPos),...
    norm(initPos+thr2Pt-thr2GndPos)];

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

gndStnMmtArms(1).posVec = thr1GndPos;
gndStnMmtArms(2).posVec = thr2GndPos;
gndStnMmtArms(3).posVec = thr3GndPos;

bodyMmtArms(1).posVec = thr1Pt;
bodyMmtArms(2).posVec = thr2Pt;
bodyMmtArms(3).posVec = thr3Pt;

liftingBodyThrAttch(1).posVec = [0 1/2 1/2];
liftingBodyThrAttch(2).posVec = [1/2*cosd(30), -1/2*(1/2), 1/2];
liftingBodyThrAttch(3).posVec = [-1/2*cosd(30), -1/2*(1/2), 1/2];

thr = OCT.tethers;
thr.numTethers.setValue(3,'');
thr.numNodes.setValue(N,'')
thr.build;

thr.tether1.initGndNodePos.setValue(thr1GndPos,'m');
thr.tether1.initAirNodePos.setValue(initPos + (rotation_sequence(initEulerAngles)*thr1Pt')','m');
thr.tether1.initGndNodeVel.setValue([0 0 0],'m/s');
thr.tether1.initAirNodeVel.setValue(initVel,'m/s');
thr.tether1.diameter.setValue(dia_t,'m');
thr.tether1.youngsMod.setValue(E,'Pa');
thr.tether1.dampingRatio.setValue(zeta,'');
thr.tether1.dragCoeff.setValue(Cd,'');
thr.tether1.density.setValue(rho_tether,'kg/m^3');
thr.tether1.vehicleMass.setValue(mass,'kg');
thr.tether1.setDragEnable(true,'');
thr.tether1.setSpringDamperEnable(true,'');
thr.tether1.setNetBuoyEnable(true,'');

thr.tether2.initGndNodePos.setValue(thr2GndPos,'m');
thr.tether2.initAirNodePos.setValue(initPos + (rotation_sequence(initEulerAngles)*thr2Pt')','m');
thr.tether2.initGndNodeVel.setValue([0 0 0],'m/s');
thr.tether2.initAirNodeVel.setValue(initVel,'m/s');
thr.tether2.diameter.setValue(dia_t,'m');
thr.tether2.youngsMod.setValue(E,'Pa');
thr.tether2.dampingRatio.setValue(zeta,'');
thr.tether2.dragCoeff.setValue(Cd,'');
thr.tether2.density.setValue(rho_tether,'kg/m^3');
thr.tether2.vehicleMass.setValue(mass,'kg');
thr.tether2.setDragEnable(true,'');
thr.tether2.setSpringDamperEnable(true,'');
thr.tether2.setNetBuoyEnable(true,'');

thr.tether3.initGndNodePos.setValue(thr3GndPos,'m');
thr.tether3.initAirNodePos.setValue(initPos + (rotation_sequence(initEulerAngles)*thr3Pt')','m');
thr.tether3.initGndNodeVel.setValue([0 0 0],'m/s');
thr.tether3.initAirNodeVel.setValue(initVel,'m/s');
thr.tether3.diameter.setValue(dia_t,'m');
thr.tether3.youngsMod.setValue(E,'Pa');
thr.tether3.dampingRatio.setValue(zeta,'');
thr.tether3.dragCoeff.setValue(Cd,'');
thr.tether3.density.setValue(rho_tether,'kg/m^3');
thr.tether3.vehicleMass.setValue(mass,'kg');
thr.tether3.setDragEnable(true,'');
thr.tether3.setSpringDamperEnable(true,'');
thr.tether3.setNetBuoyEnable(true,'');

thr = thr.struct('OCT.tether');

airTethDist = [0 0 h/2];

v = 0.6;
vsquared = v^2;
cd = .8;
A = vol^(2/3);
oceanPeriod = 20;

xOn = 1; % 1 = on, 0 = off
zOn = 1;

% full tension
% initPos = [26.4381, 0, 83.0498];
% avg mag
% initPos = [23.77, 0, 85.0695];
    
waveAmp = 0;
wavePeriod = oceanPeriod;
oceanDepth = 105;
sim('groundStation001_th')
figure
depth.plot
title('Depth')
ylabel('Depth (m)')
figure
eulang.plot
legend('roll','pitch','yaw')
ylabel('Euler Angles (rad)')


%%
dep = get(logsout,7);
figure
dep.Values.plot
subpo = get(logsout,4)
meanz = mean(subpo.Values.Data(3,1,:))
meanx = mean(subpo.Values.Data(1,1,:))

initPos = [meanx, 0, meanz];

oceanDepth = meanz;

sim('groundStation001_th')

figure
dep1 = get(logsout, 7);
dep1.Values.plot


for i = 1:6
    figure(i)
    ylim([-25 5])
end