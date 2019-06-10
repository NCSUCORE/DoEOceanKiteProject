% Script to test the origional model against the modularized model
clear all;clc;

OCTModel_init

modularPlant_init;

createTetherInputBus
createTetherOutputBus


for ii = 1:3
tether(ii).N          = sim_param.N;
tether(ii).diameter   = sim_param.tether_param.tether_diameter(ii);
tether(ii).youngsMod  = sim_param.tether_param.tether_youngs;
tether(ii).density    = sim_param.tether_param.tether_density+ sim_param.env_param.density;
tether(ii).CD_Cyliner = sim_param.tether_param.CD_cylinder;
tether(ii).damping_ratio = sim_param.tether_param.damping_ratio;
tether(ii).fluidDensity  = sim_param.env_param.density;
tether(ii).gravity       = sim_param.env_param.grav;
tether(ii).vehicleMass   = sim_param.geom_param.mass;
end

tether(1).initAirPos = ini_Rcm_o + rotation_sequence(ini_euler_ang)*R1n_cm;
tether(2).initAirPos = ini_Rcm_o + rotation_sequence(ini_euler_ang)*R2n_cm;
tether(3).initAirPos = ini_Rcm_o + rotation_sequence(ini_euler_ang)*R3n_cm;

tether(1).initGndPos = gnd_station + R11_g;
tether(2).initGndPos = gnd_station + R21_g;
tether(3).initGndPos = gnd_station + R31_g; 


sim('multiTether_th')

simout