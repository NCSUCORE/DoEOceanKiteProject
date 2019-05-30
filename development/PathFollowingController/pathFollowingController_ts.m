pos=[1;0;1;];
vel=[-1;0;1;];
chi_des=10*pi/180;
eul_ang=[0;45*pi/180;0;];
flow=[1;0;0;];
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

sim('pathFollowingController_th')

close all

outs=parseLogsout;
plot(outs.roll_des.time,outs.roll_sig.Data)
title("roll sig")

figure
plot(outs.roll_des.time,outs.roll_des.Data*180/pi)
title("roll_des")

figure
plot(outs.roll_des.time,outs.roll.Data*180/pi)
title("roll")

figure
plot(outs.roll_des.time,outs.fixed_chi_error.Data*180/pi)
title("chi error")