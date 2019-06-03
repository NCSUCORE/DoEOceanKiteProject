clear;clc;close all

tsim = 30;

createSubmersiblePlatformBus

plat = submersiblePlatformClass;
plat.setInitialConditions('PositionBuoy',[0,0,85],'PositionLanding',[0,0,93.001]);

teth1 = anchorTetherClass;
teth1.setInitialConditions(plat.initial,plat.buoy.mass,'anchorPosition',[0,50,0],'cmDistanceBuoy',[0,0,0]); %[0,1,-1]

teth2 = anchorTetherClass;
teth2.setInitialConditions(plat.initial,plat.buoy.mass,'anchorPosition',[50*cosd(30),-50*sind(30),0],'cmDistanceBuoy',[0,0,0]); %[cosd(30),-sind(30),-1]

teth3 = anchorTetherClass;
teth3.setInitialConditions(plat.initial,plat.buoy.mass,'anchorPosition',[-50*cosd(30),-50*sind(30),0],'cmDistanceBuoy',[0,0,0]); %[-cosd(30),-sind(30),-1]

sim('plat_ts')