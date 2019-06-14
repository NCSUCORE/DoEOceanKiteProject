clc
format compact
close all

% load('custom_constant_baseline_1106_104556.mat')
% position = tsc.positionGFC;
% mag = tsc.tetherTensionMag;

numTeth = 3;

% for i = 1:numTeth
%     thr(i) = tetherParamClass;
% end

flow = [0 0 0];

rho = 1000;
vol = 3.5;
h = vol^(1/3);
grav = 9.81;

thr1Pt = [0 1 -.5];
thr1GndPos = [0 50 0];
thr1GndVel = [0 0 0];
thr2Pt = [cosd(30),-sind(30),-.5];
thr2GndPos = [50*cosd(30), -50*sind(30), 0];
thr2GndVel = [0 0 0];
thr3Pt = [-cosd(30),-sind(30),-.5];
thr3GndPos = [-50*cosd(30), -50*sind(30), 0];
thr3GndVel = [0 0 0];
CB2CMVec = [0 0 0];

buoyF = 1.05;
mass = rho*vol/buoyF;
m = mass;

inertiaMatrix = eye(3);

initPos = [0 0 100];
initVel = [0 0 0];
initEulerAngles = [0 0 0];
initAngVel = [0 0 0];

sim_time = 360;

N = 2;
sim_param.N = N;

dia_t = 0.05;
% E = 3.8e9;
E = .38e9;
zeta = 0.05;
rho_tether = 1300;
Cd = 0.5;

tetherLengths = (norm(initPos+thr1Pt-thr1GndPos))*ones(3,1);

zOcean = -1000;
zOceanPeriod = 18;
xOcean = 0;
xOceanPeriod = 10;

waveAmp = 3;
wavePeriod = 20;
oceanDepth = 113;
sim('simpSubPlatform_th')

%% Post Process

tsc1 = parseLogsout;

zSub = tsc1.subPos.Data(3,:);
plot(tsc1.subPos.Time,zSub)
hold on
zLand = tsc1.landingPos.Data(3,:);
plot(tsc1.landingPos.Time,zLand)
legend('Submersed Floating Platform','Landing Platform')

figure

xSub = tsc1.subPos.Data(1,:);
plot(tsc1.subPos.Time,xSub)
