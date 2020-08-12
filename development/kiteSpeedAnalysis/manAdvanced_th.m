clear
clc
close all

%% initailize
cIn = maneuverabilityAdvanced;
cIn.aBooth = 0.3491;
cIn.bBooth = 0.6391;
cIn.tetherLength = 50;
cIn.meanElevationInRadians = 30*pi/180;

%% test inertial position calculation
azimuth = 0*pi/180;
elevation = 45*pi/180;
G_rCM = cIn.calcInertialPosition(azimuth,elevation);

%% test apparent velocity calculation
heading = 0*pi/180;
tgtPitch = 30*pi/180;
roll = 0*pi/180;

G_vFlow = [1;0;0];      % flow vel in ground frame
T_vKite = [2;0;0];      % kite vel in tangent (North-East-Down) frame

B_vApp = cIn.calcApparentVelInBodyFrame(G_vFlow,T_vKite,...
    azimuth,elevation,heading,tgtPitch,roll);

%% test angle of attack and side-slip angle calculation
AoA = cIn.calcAngleOfAttackInRadians(B_vApp)*180/pi;
SSA = cIn.calcSideSlipAngleInRadians(B_vApp)*180/pi;

%% test drag and lift direction calculation
uDrag = cIn.calcDragDirection(B_vApp);
uWingLift = cIn.calcHsurfLiftDirection(B_vApp);
uVsLift = cIn.calcVstabLiftDirection(B_vApp);

%% test wing force and moment calculation
cIn.wingChord = 1;
cIn.wingAspectRatio = 10;
cIn.wingAeroCenter = [1;0;0];

% wing loads
wingLoads = cIn.calcWingLoads(B_vApp);

%% test h-stab force and moment calculation
cIn.hstabChord = 0.5;
cIn.hstabAspectRatio = 10;
cIn.hstabAeroCenter = [-5;0;0];
cIn.hstabControlSensitivity = 0.08;
elevatorDeflection = 0;

% h-stab loads
hstabLoads = cIn.calchStabLoads(B_vApp,elevatorDeflection);

%% test v-stab force and moment calculation
cIn.vstabChord = 0.5;
cIn.vstabAspectRatio = 10;
cIn.vstabAeroCenter = [-5;0;-0.5];

% v-stab loads
vstabLoads = cIn.calcvStabLoads(B_vApp);

%% test buoyancy force and moment calculation
cIn.buoyFactor = 1.0;
cIn.centerOfBuoy = [0.5;0;0];
cIn.mass = 3e3;

buoyLoads = cIn.calcBuoyLoads(azimuth,elevation,heading,tgtPitch,roll);

%% test gravity force and moment calculation
B_Fgrav = cIn.calcGravForce(azimuth,elevation,heading,tgtPitch,roll);
netWeight = buoyLoads.force + B_Fgrav;

%% test tether force and moment calculation
cIn.bridleLocation = [0;0;1];
thrLoads = cIn.calcTetherLoads(G_vFlow,T_vKite,azimuth,elevation,...
    heading,tgtPitch,roll,elevatorDeflection);

%% test path tangent calculation
pathParam = linspace(0,2*pi,100);
pathAzimAndElev = cIn.pathAndTangentEqs.AzimAndElev(pathParam);
pathCoords      = cIn.pathAndTangentEqs.PathCoords(pathParam);
pathTangents    = cIn.pathAndTangentEqs.PathTangents(pathParam);

%% test required heading angle calculation


%% test plotting functions
% figure(2);
% set(gcf,'Position',[18 417 560 420]);
% cIn.plotDome;
% hold on;
% grid on;
% view(100,35);
% axis equal;
% 
% pAxes = cIn.plotBodyFrameAxes(azimuth,elevation,...
%     heading,tgtPitch,roll);
% 
% pVels = cIn.plotVelocities(G_vFlow,T_vKite,azimuth,elevation);
% pLem = cIn.plotLemniscate;
% pTanVec = cIn.plotTangentVec(pi/6);
% 
% figure(3);
% cIn.plotRadiusOfCurvature;
% 
% figure(4);
% cIn.plotRequiredHeadingAngle;

%% test animation functions
figure(5);
set(gcf,'Position',[20 60 560*2 420*2]);
cIn.makeFancyAnimation(true,pathParam);

