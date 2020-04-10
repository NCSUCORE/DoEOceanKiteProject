
close all;clear;clc

% Setting sim time to zero runs a single time step
simTime = 0;

ctrlInput = 10;
% Roll, pich and yaw, in degrees
eulAng = [0 0 0]; 
 % Vector from center of mass to the byouancy engine location, in the body frame
momentArm = [0 0 0];

% Run the simulation
out  =sim('buoyEng_th');

tsc = signalcontainer(out.logsout);

% Plot the force vector in the body frame to make sure it makes sense

quiver3(0,0,0,tsc.forceVecBdy.Data(1),tsc.forceVecBdy.Data(2),tsc.forceVecBdy.Data(3))
daspect([1 1 1])
