% Test script to test modularized modle
close all;clear;clc
format compact

% Initialize the highest level model
OCTModel_init

% Initialize all of ayaz's parameters
ayazPlant_init

% Create the bus objects in the workspace
createModAyazPlantBus
createModAyazFlowEnvironmentBus
createPathFollowingControllerCtrlBus

% Set simulation duration
duration_s = 1000;

% Set active variants
% ENVIRONMENT = 'ayazFlow';
% CONTROLLER  = 'ayazController';
% PLANT       = 'ayazPlant';

%% Overwrite AyazPlant_init Vars
ini_Rcm_o = ini_Rcm_o;
ini_O_Vcm_o = [0;0;0.0];
ini_euler_ang = [0;ini_pitch;0];
%% Assign neccessary vars for Josh's Part
controlmat=[[-.5;0;.5;] [.5;-.5;.5] [0; 0; 0;]];
controlmax=[.4;.4;.4;];
max_bank=45*pi/180;
kp_chi=max_bank/(pi/2); %max bank divided by large error
kd_chi=kp_chi;
tau_chi=.1;
kp_L=.8/max_bank;
kd_L=2*kp_L;
tau_L=.1;
kp_M=.8/max_bank;
kd_M=2*kp_M;
tau_M=.1;
kp_N=.8/max_bank;
kd_N=2*kp_N;
tau_N=.1;
%%

try
    sim_monitor_start('mmcontrollerVerification_th')
    sim('mmcontrollerVerification_th')
    sim_monitor_end('mmcontrollerVerification_th')
catch e
    sim_monitor_end('mmcontrollerVerification_th')
    fprintf(2,'There was an error!')
    fprintf(2,'The identifier was:\n     %s\n',e.identifier);
    fprintf(2,'The message was:\n     %s\n',e.message);
    if ~isempty(e.cause)
        fprintf(2,'The cause was:\n     %s\n',e.cause{1}.message);
    end
end

tscMod = parseLogsout;