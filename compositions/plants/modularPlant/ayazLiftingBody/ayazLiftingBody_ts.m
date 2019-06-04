% Test script to test initial, coarse modularization of Ayazs model
format compact
% Initialize the highest level model
% OCTModel_init
% Initialize all the parameters that Ayaz's model needs to run
ayazParams_init
% Simulation duration, in seconds
T = 10;
model_obj = get_param(bdroot,'Object');
model_obj.refreshModelBlocks

flow = [1 0 0];
elevonCmds = [0 0];
ten1Vec = [0 0 -1];
ten2Vec = [0 0 -1];
ten3Vec = [0 0 -1];

sim('ayazLiftingBody_th')