% Test script to test modularized modle
close all;clear;
format compact

% Initialize the highest level model
OCTModel_init

% Initialize all of ayaz's parameters
ayazPlant_init

% Create the bus objects in the workspace
createAyazPlantBus
createUniformFlowEnvironmentBus
createaAyazCtrlBus

% Set simulation duration
duration_s = 900;

% Set active variants
ENVIRONMENT = 'ayazFlow';
CONTROLLER  = 'ayazController';
PLANT       = 'ayazPlant';
%% Setup setpoint timeseries
time = 0:0.1:duration_s;
set_pitch = 17*(pi/180)*ones(size(time));
% set_roll = 0*ones(size(time));
% set_yaw = 0*ones(size(time));
set_roll = -15*(pi/180)*square(time*2*pi/200);
set_yaw = -20*(pi/180)*square(time*2*pi/200);
set_alt = 200*ones(size(time));

set_pitch = timeseries(set_pitch,time);
set_roll  = timeseries(set_roll, time);
set_alt   = timeseries(set_alt,time);
set_yaw   = timeseries(set_yaw,time);
%% Elevator Elevon Control (off)
kp_elev = 0*1*10;
ki_elev = 0.0*kp_elev;
kd_elev = 0*sqrt(k_scale)*3*kp_elev;
%% Aileron Elevon Control (off)
kp_aileron = 0*1*4;
ki_aileron = 0.0*kp_aileron;
kd_aileron = 0*2*sqrt(k_scale)*kp_aileron;
%% altitude winch control(off)
Kp_z = 0*0.05;
Ki_z = 0;
Kd_z = 0*.25;
%% pitch winch control(on)
Kp_p = 2*sqrt(k_scale);
Ki_p = 0.0;
Kd_p = sqrt(k_scale)*Kp_p*5;
%% roll winch control(on)
Kp_r = 4*(k_scale);
Ki_r = 0.0;
Kd_r = 2*sqrt(k_scale)*Kp_r;
%% yaw-motor control (off)
kd_yaw = 0*12^6;
kp_yaw = 0*10^5;
ki_yaw = 0*10^4;
tau_yaw = 2;

%% Run simulation
try
    sim_monitor_start('OCTModel')
    sim('OCTModel')
    sim_monitor_end('OCTModel')
catch e
    sim_monitor_end('OCTModel')
    fprintf(2,'There was an error!')
    fprintf(2,'The identifier was:\n     %s\n',e.identifier);
    fprintf(2,'The message was:\n     %s\n',e.message);
    if ~isempty(e.cause)
        fprintf(2,'The cause was:\n     %s\n',e.cause{1}.message);
    end
end
%% Parse out the results
tsc = parseLogsout;
tsc.eulerAngles.Data=tsc.eulerAngles.Data*180/pi;
if isfield(tsc,'ayazStates')
    tsc.ayazStates.data(:,7:9)=tsc.ayazStates.data(:,7:9)*180/pi;
end

%% Plot some things
figure;hold on
tsc.posVec.plot('--','lineWidth',2)
ax=gca;ax.ColorOrderIndex=1;
if isfield(tsc,'ayazStates')
    plot(tsc.ayazStates.time, tsc.ayazStates.data(:,1:3))
end
grid
legend(["X","Y","Z","X_{old}","Y_{old}","Z_{old}"],'Location','best')

figure; hold on
tsc.velocityVec.plot('lineWidth',1)
ax=gca;ax.ColorOrderIndex=1;
if isfield(tsc,'ayazStates')
    plot(tsc.ayazStates.time, tsc.ayazStates.data(:,4:6))
end
grid
legend(["X","Y","Z","X_{old}","Y_{old}","Z_{old}"],'Location','best')

figure; hold on
tsc.eulerAngles.plot('--','lineWidth',2)
ax=gca;ax.ColorOrderIndex=1;
if isfield(tsc,'ayazStates')
    plot(tsc.ayazStates.time, tsc.ayazStates.data(:,7:9))
end
grid
legend(["Roll","Pitch","Yaw","Roll_{old}","Pitch_{old}","Yaw_{old}"],'Location','best')
