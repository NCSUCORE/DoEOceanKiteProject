clear;clc

load('partDsgn1_lookupTables.mat')

velCMBdy   = [0 0 0];
angVelBdy  = [0 0 0];
% velWindBdy = [1 -0.1 0];

fluidDensity = 1;

ctrlSurfDefl = 0;
alpha = [];
Mz = [];
for yComp = linspace(-10,10,21)
    velWindBdy = [1 yComp 0];
    sim('fluidDynamicSurface_th')
    hold on
    scatter(atand(velWindBdy(2)/velWindBdy(1)),MBdy.Data(3,4))
    hold on
    grid on
end

% FBdy.Data
% MBdy.Data
% FLift.Data
% FDrag.Data
% dynPress.Data
% CL.Data
% CD.Data
% alphaLocal.Data



