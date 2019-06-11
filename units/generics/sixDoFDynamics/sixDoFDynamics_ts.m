clear
clc
format compact

base_mass = 100;

added_mass = [10 0 0;0 20 0; 0 0 25];

mass_mat = eye(3)*base_mass + added_mass;

ini_pos = [0; 0; 100];
ini_vel = [0; 0; 0];

MI = eye(3);

ini_eul = [0; 0; 0];
ini_OwB = [0; 0; 0];

FNetBdy = [0;0;-1000];

MNetBdy = [0;0;0];

sim('sixDoFDynamics_th');