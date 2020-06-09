clear;close all;clc
PATHGEOMETRY = 'racetrack';
loadComponent('firstBuildPathFollowing')
sim('pathGeometry_th.slx')
simout.plot
hold on
