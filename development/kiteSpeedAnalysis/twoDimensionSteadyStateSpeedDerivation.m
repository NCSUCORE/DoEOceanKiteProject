clear; clc; format compact;

%% basic functions
% rotation about z axis
Rz = @(x) [cos(x) sin(x) 0; -sin(x) cos(x) 0; 0 0 1];

% vector norm
vecNorm = @(x) sqrt(sum(x.^2));

%% define symbolics
syms vf vk phi LbyD

%% assign the symbolics to descriptive variables
% flow velocity vector in the O frame
flowVel_O = [vf;0;0];

% kite velocity vector in the T frame
kiteVel_T = [0;vk;0];

% azimuth angle
azimuth = phi;

% lift by drag ratio
liftByDrag = LbyD;

%% calculations
% make rotation matrix
TcO = Rz(azimuth);
OcT = transpose(TcO);

% rotate kite velocity in the O frame
kiteVel_O = OcT*kiteVel_T;

% calculate apparent velocity vector
appVel_O = flowVel_O - kiteVel_O;

% magnitude of apparent velocity 
magAppVel = vecNorm(appVel_O);

% use cosine rule to make write equation relating flow velocity, kite
% velocity, and apparent velocity
eqn = vf^2 == vk^2 + magAppVel^2 - 2*vk*magAppVel*cos(atan(1/liftByDrag));

% solve for vk
solVk = solve(eqn,vk,'ReturnConditions',true);

% make function out of the solution
eqnForVk = matlabFunction(solVk.conditions);





