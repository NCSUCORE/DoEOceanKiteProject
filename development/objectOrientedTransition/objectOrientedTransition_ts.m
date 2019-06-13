% Script to test the origional model against the modularized model
clear all;clc;

OCTModel_init
modularPlant_init
simParam = simParamClass;
simParam.setInitialConditions('Position',ini_Rcm_o,'Velocity',ini_O_Vcm_o,...
    'EulerAngles',ini_euler_ang,'AngularVelocity',ini_OwB,'PlatformAngle',0,...
    'PlatformAngularVelocity',0)

%      addOptional(p,'Position',[0 0 0],@isnumeric);
%             addOptional(p,'Velocity',[0 0 0],@isnumeric);
%             addOptional(p,'EulerAngles',[0 0 0],@isnumeric);
%             addOptional(p,'AngularVelocity',[0 0 0],@isnumeric);
%             addOptional(p,'PlatformAngle',0,@isnumeric)
%             addOptional(p,'PlatformAngularVelocity',0,@isnumeric);

ctrl = threeTetherThreeSurfaceCtrlClass;

duration_s = 200;

PLANT = 'modularPlant';

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

% Change structures to implement single tether
% winch = winch(1);
% gndStnMmtArms = gndStnMmtArms(1);
% lftBdyMmtArms = lftBdyMmtArms(1);
% thr = thr(1);
% 
% gndStnMmtArms.arm = [0 0 0];
% lftBdyMmtArms.arm = [0 0 0];
% thr.diameter = thr.diameter*3;
% thr.initVhclAttchPt = ini_Rcm_o + rotation_sequence(ini_euler_ang)*lftBdyMmtArms.arm(:);
% thr.initGndStnAttchPt = rotation_sequence(ini_euler_ang)*gndStnMmtArms.arm(:);

switch numel(thr)
    case 3
        createThreeTetherThreeSurfaceCtrlBus;
        CONTROLLER = 'threeTetherThreeSurfaceCtrl';
        caseDescriptor = '3 Tethers';
        
    case 1
        createOneTetherThreeSurfaceCtrlBus;
        CONTROLLER = 'oneTetherThreeSurfaceCtrl';
        caseDescriptor = '1 Tether';
end

if  sim_param.elevons_param.elevator_control.kp_elev == 0 
    caseDescriptor = [caseDescriptor ' Open Loop'];
else
    caseDescriptor = [caseDescriptor ' Closed Loop'];
end
caseDescriptor = {caseDescriptor,sprintf('%d Nodes ',thr(1).N)};

fileName = [caseDescriptor{1} caseDescriptor{2} '.gif'];
fileName = strrep(fileName,' ','');

sim('OCTModel')

parseLogsout

%%
timeVec = 0:1:tsc.winchSpeedCommands.Time(end);

numTethers = numel(tsc.thrNodeBus);
for ii= 1:numTethers
    tsc.thrNodeBus(ii).nodePositions = resample(tsc.thrNodeBus(ii).nodePositions,timeVec);
end

h.fig = figure('Position',[1          41        1920         963]);
for ii = 1:numTethers
    h.thr(ii) = plot3(...
        squeeze(tsc.thrNodeBus(ii).nodePositions.Data(1,:,1)),...
        squeeze(tsc.thrNodeBus(ii).nodePositions.Data(2,:,1)),....
        squeeze(tsc.thrNodeBus(ii).nodePositions.Data(3,:,1)),...
        'LineWidth',1.5,'LineStyle','--','Color','k','Marker','x');
    hold on
    zlim([0 205])
    xlim([-10 70])
    ylim([-25 25])
end
h.title = title({caseDescriptor{1},[caseDescriptor{2} sprintf('Time = %.0f',0)]});
set(gca,'FontSize',24')
grid on

frame = getframe(h.fig );
im = frame2im(frame);
[imind,cm] = rgb2ind(im,256);

imwrite(imind,cm,fileName,'gif', 'Loopcount',inf);

for ii = 2:length(timeVec)
    h.title.String = {caseDescriptor{1},[caseDescriptor{2} sprintf('Time = %.0f',timeVec(ii))]};
    for jj = 1:numTethers
        h.thr(jj).XData = tsc.thrNodeBus(jj).nodePositions.Data(1,:,ii);
        h.thr(jj).YData = tsc.thrNodeBus(jj).nodePositions.Data(2,:,ii);
        h.thr(jj).ZData = tsc.thrNodeBus(jj).nodePositions.Data(3,:,ii);
    end
    zlim([0 205])
    xlim([-10 70])
    ylim([-25 25])
    drawnow
    frame = getframe(h.fig );
    im = frame2im(frame);
    [imind,cm] = rgb2ind(im,256);
    imwrite(imind,cm,fileName,'gif','WriteMode','append');
end
