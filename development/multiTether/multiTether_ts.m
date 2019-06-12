% Script to test the origional model against the modularized model
clear all;clc;

OCTModel_init

modularPlant_init;

duration_s = 200;

PLANT = 'modularPlant';

createThreeTetherThreeSurfaceCtrlBus;
createOrigionalPlantBus;
createConstantUniformFlowEnvironmentBus;

% Calculate setpoints
timeVec = 0:0.1:duration_s;
set_alt = timeseries(set_alti*ones(size(timeVec)),timeVec);
set_pitch = timeseries(set_pitch*ones(size(timeVec))*180/pi,timeVec);
set_roll = timeseries(set_roll*ones(size(timeVec))*180/pi,timeVec);

set_roll.Data = 0*sign(sin(timeVec/(2*pi*200)));
set_roll.Data(timeVec<200) = 0;

% Set controller gains and time constants
% Uncomment this code to disable the controller
sim_param.elevons_param.elevator_control.kp_elev    = 0;
sim_param.elevons_param.elevator_control.ki_elev    = 0;
sim_param.elevons_param.elevator_control.kd_elev    = 0;
sim_param.elevons_param.elevator_control.t_elev     = 1;

sim_param.elevons_param.aileron_control.kp_aileron  = 0;
sim_param.elevons_param.aileron_control.ki_aileron  = 0;
sim_param.elevons_param.aileron_control.kd_aileron  = 0;
sim_param.elevons_param.aileron_control.t_aileron   = 1;

sim_param.controller_param.alti_control.Kp_z    = 0;
sim_param.controller_param.alti_control.Ki_z    = 0;
sim_param.controller_param.alti_control.Kd_z    = 0;
sim_param.controller_param.alti_control.wce_z   = 1;

sim_param.controller_param.pitch_control.Kp_p    = 0;
sim_param.controller_param.pitch_control.Ki_p    = 0;
sim_param.controller_param.pitch_control.Kd_p    = 0;
sim_param.controller_param.pitch_control.wce_p   = 0.1;

sim_param.controller_param.roll_control.Kp_r    = 0;
sim_param.controller_param.roll_control.Ki_r    = 0;
sim_param.controller_param.roll_control.Kd_r    = 0;
sim_param.controller_param.roll_control.wce_r   = 1;


sim('OCTModel')
parseLogsout

%%
timeVec = 0:1:tsc.winchSpeeds.Time(end);
for ii= 1:3
    tsc.thrNodeBus(ii).nodePositions = resample(tsc.thrNodeBus(ii).nodePositions,timeVec);
end


figure('Position',[0    0.0370    1.0000    0.8917])
for ii = 1:3
h.thr(ii) = plot3(squeeze(tsc.thrNodeBus(ii).nodePositions.Data(1:3:end,1,1)),...
    squeeze(tsc.thrNodeBus(ii).nodePositions.Data(2:3:end,:,1)),....
    squeeze(tsc.thrNodeBus(ii).nodePositions.Data(3:3:end,:,1)),...
    'LineWidth',1.5,'LineStyle','--','Color','k','Marker','x');
hold on
end
grid on

pause
for ii = 2:length(timeVec)
    for jj = 1:3
        h.thr(jj).XData = squeeze(tsc.thrNodeBus(jj).nodePositions.Data(1:3:end,1,ii));
        h.thr(jj).YData = squeeze(tsc.thrNodeBus(jj).nodePositions.Data(2:3:end,1,ii));
        h.thr(jj).ZData = squeeze(tsc.thrNodeBus(jj).nodePositions.Data(3:3:end,1,ii));
    end
    drawnow
    pause
end
