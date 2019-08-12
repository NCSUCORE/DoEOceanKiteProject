clear;close all;clc
loadComponent('firstBuildPathFollowing')
sim('pathGeometry_th.slx')
simout.plot
hold on
