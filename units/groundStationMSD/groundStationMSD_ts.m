close all
clear
clc

J = 0.5;
k = 10;
b = 10;

omega_0 = 0;
theta_0 = 1;

torque = 1;

sim('groundStationMSD_th')

subplot(2,1,1)
theta.plot

subplot(2,1,2)
omega.plot