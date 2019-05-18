% Test script to test initial, coarse modularization of Ayazs model
format compact
% Initialize the highest level model
% OCTModel_init
% Initialize all the parameters that Ayaz's model needs to run
ayazParams_init
% Simulation duration, in seconds
duration_s = 10;

createAyazPlantBus
createaAyazCtrlBus
createAyazFlowEnvironmentBus

elevonDeflection = [0 0]';
winchSpeeds      = [0 0 0]';
windSpeed        = 1;
windDir          = 0;

sim('ayazPlant_th')
