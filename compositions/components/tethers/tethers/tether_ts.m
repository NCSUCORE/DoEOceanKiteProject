clear all;clc;

OCTModel_init

modularPlant_init

rotation_sequence(ini_euler_ang)

thr1AirNodePos = ini_Rcm_o(:) + rotation_sequence(ini_euler_ang)*R1n_cm;
thr2AirNodePos = ini_Rcm_o(:) + rotation_sequence(ini_euler_ang)*R2n_cm;
thr3AirNodePos = ini_Rcm_o(:) + rotation_sequence(ini_euler_ang)*R3n_cm;

thr1AirNodeVel = ini_O_Vcm_o(:);
thr2AirNodeVel = ini_O_Vcm_o(:);
thr3AirNodeVel = ini_O_Vcm_o(:);

thr1GndNodePos = R11_g;
thr2GndNodePos = R21_g;
thr3GndNodePos = R31_g;

thr1GndNodeVel = [0 0 0]';
thr2GndNodeVel = [0 0 0]';
thr3GndNodeVel = [0 0 0]';

createThrAttachPtBus
createThrBus(sim_param.N)

sim('tethers_th')

