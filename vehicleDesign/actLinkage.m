clc
clear all
close all


%Aileron Control Actuator Design

deflRange = 30%degrees
primLevArm = .0350/2 %m
bellCrankRatio = 5%unitless
bellCrankOut = 2*primLevArm*sin(deflRange/2*pi/180)
bellCrankIn = bellCrankOut*bellCrankRatio

forceIn = 115*9.81%100*4.4488 %N
forceOut = forceIn*bellCrankRatio %N
torqueOut = forceOut*primLevArm %N-m
torqueOutImp = torqueOut/4.4488/.0254/12