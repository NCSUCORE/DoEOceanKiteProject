% Run multinode_wing_tail.m up to sim line first
% clearvars -except sim_param


%%
ctrl = allActuatorCtrlClass;
ctrl.scale(0.1,1)

fprintf('Elevator Controller\n')
% Check elevator controller
[ctrl.elevatorKp.Value  kp_elev]
[ctrl.elevatorKi.Value  ki_elev]
[ctrl.elevatorKd.Value  kd_elev]
[ctrl.elevatorFilterTimeConst.Value  t_elev]

fprintf('Aileron Controller\n')
% Check aileron controller
[ctrl.aileronKp.Value  kp_aileron]
[ctrl.aileronKi.Value  ki_aileron]
[ctrl.aileronKd.Value  kd_aileron]
[ctrl.aileronFilterTimeConst.Value  t_aileron]

fprintf('Ctrl Surf Max Deflection\n')
% Check elevon max deflection
[ctrl.elevonMaxDeflection.Value elevon_max_deflection(1)]

fprintf('Altitude Controller\n')
% Check altitude controller
[ctrl.altitudeKp.Value  Kp_z]
[ctrl.altitudeKi.Value  Ki_z]
[ctrl.altitudeKd.Value  Kd_z]
[ctrl.altitudeFilterTimeConst.Value  1/wce_z]

fprintf('Pitch Controller\n')
% Check pitch controller
[ctrl.pitchKp.Value  Kp_p]
[ctrl.pitchKi.Value  Ki_p]
[ctrl.pitchKd.Value  Kd_p]
[ctrl.pitchFilterTimeConst.Value  1/wce_p]

fprintf('Roll Controller\n')
% Check roll controller
[ctrl.rollKp.Value  Kp_r]
[ctrl.rollKi.Value  Ki_r]
[ctrl.rollKd.Value  Kd_r]
[ctrl.rollFilterTimeConst.Value  1/wce_r]

fprintf('Winch Speed Limits\n')
[ctrl.winchSpeedCmdLim.Value vel_up_lim]