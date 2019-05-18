% Test script to test initial, coarse modularization of Ayazs model
format compact
% Initialize the highest level model
% OCTModel_init
% Initialize all the parameters that Ayaz's model needs to run
ayazParams_init
% Simulation duration, in seconds

model_obj = get_param(bdroot,'Object');
model_obj.refreshModelBlocks

flow = [1 0 0]';

eulAng = [0 0 0]';

liftBdyAccel    = [0 0 0]';
bdyAngAccel     = [0 0 0]';
bdyAngVel       = [0 0 0]';

platformAng         = 0;
platformAngVel      = 0;
platformAngAccel    = 0;

sim('ayazTethers_th')

% thr1NodePositions = logsout.getElement('thr1NodePositions').Values;
% thr2NodePositions = logsout.getElement('thr2NodePositions').Values;
% thr3NodePositions = logsout.getElement('thr3NodePositions').Values;
% 
% thr1NodeVelocities = logsout.getElement('thr1NodeVelocities').Values;
% thr2NodeVelocities = logsout.getElement('thr2NodeVelocities').Values;
% thr3NodeVelocities = logsout.getElement('thr3NodeVelocities').Values;
% 
% thr1NodePositions = reshape(thr1NodePositions,[3 length(thr1NodePositions)/3]);