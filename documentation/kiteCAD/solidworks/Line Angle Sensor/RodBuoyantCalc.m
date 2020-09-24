clc
clear all
close all

%Script determines required pool float volume to result in no preferred
%orientation for LAS boom arm.

mLAS = 0.533; %Mass of moving portion of LAS [kg]
cgLAS = 0.089; %CG of  moving portion of LAS [m]
mWater = 0.134 %Displaced mass of water due to moving portion of LAS [kg]
cBuoy = 0.147 %Center of volume for moving portion of LAS [m]
g = 9.81 %Acceleration due to gravity [m/s^2]
rhoWater = 1000 %density of water [kg/m^3]

LHS = mLAS*g*cgLAS-mWater*cBuoy*g; %LHS of static analysis
l = 0.1:.01:.35 %potential length along boom arm as measured from 0 = pivot axis

ID = 0.0127; %pool noodle ID
OD = 0.0381; %pool noodle OD
A = pi/4*(OD^2-ID^2); %cross sectional area of pool noodle
lFloat = LHS./l/(A*rhoWater*g); %required length of float to balance
%the net moment due to the couple formed by weight and buoyant forces

figure
plot(l,lFloat)
xlabel('Float centerplane distance from Elevation pivot [m]')
ylabel('Required pool noodle length [m]')
