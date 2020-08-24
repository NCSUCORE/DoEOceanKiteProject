clear
clc
close all
set(groot,'defaulttextinterpreter','latex');  
set(groot, 'defaultAxesTickLabelInterpreter','latex');  
set(groot, 'defaultLegendInterpreter','latex');

%% define constants
% flow speed
flowSpeed = 1;
% kite speed
kiteSpeedInX = 4;
% center of buoyancy
centerOfBuoyXLoc = -1;
% wing aero center
wingAeroCenterXLoc = 1;
% H-stab aero center
hstabAeroCenterXLoc = 6;
% bridle location
bridleZLoc = -1;
% elevation angle
elevation = 40*(pi/180);
% azimuth angle
azimuth = 0*(pi/180);
% tangent pitch angle
tangentPitch = -50*(pi/180);
% heading angle
heading = 0*(pi/180);
% mass
mass = 3e3;
% gravity
gravAcc = 9.81;
% fluid density
density = 1e3;
% factor of buoyancy (=1 is neutrally buoyant)
buoyFactor = 1;

% wing
wing.span = 10;                 % span
wing.aspectRatio = 10;          % aspect ratio
wing.oswaldEff = 0.8;           % oswald efficient < 1
wing.ZeroAoALift = 0.1;         % zero angle of attack lift
wing.ZeroAoADrag = 0.01;        % zero angle of attack drag

% horizontal stabilizer
hstab.span = 5;                 % span
hstab.aspectRatio = 10;         % aspect ratio
hstab.oswaldEff = 0.8;          % oswald efficient < 1
hstab.ZeroAoALift = 0.0;        % zero angle of attack lift
hstab.ZeroAoADrag = 0.01;       % zero angle of attack drag
hstab.dcLbydElevator = 0.08;    % change in hstab CL per deg deflection of elevator

% elevator deflection in degrees
elevatorDeflection = 10;

% test the function
op = pitchStatibilityAnalysis(flowSpeed,kiteSpeedInX,...
    centerOfBuoyXLoc,wingAeroCenterXLoc,hstabAeroCenterXLoc,...
    bridleZLoc,elevation,azimuth,tangentPitch,heading,...
    mass,gravAcc,density,buoyFactor,wing,hstab,elevatorDeflection);
