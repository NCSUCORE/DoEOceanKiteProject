%% Test script to test the floating ground station simulation and animation
clear;clc;close all
simParams = SIM.simParams;
simParams.setDuration(800,'s');
dynamicCalc = '';

%% Load components

% Ground station
loadComponent('oneThrThreeAnchGndStn001');
% Winches
loadComponent('oneDOFWnchPTO');
% Tether
loadComponent('pathFollowingTether');
% Vehicle
loadComponent('pathFollowingVhcl');
% Environment
loadComponent('hurricaneSandyWave');
% Sensors
loadComponent('idealSensors')
% Sensor processing
loadComponent('idealSensorProcessing')

% Ground station controller
loadComponent('oneDoFGSCtrlBasic');
plant_bc
%% Environment IC's and dependant properties
env.water.setflowVec([2 0 0],'m/s')



%% Ground Station IC's and dependant properties
gndStn.setInitPosVecGnd([0 0 200],'m')
gndStn.setInitVelVecBdy([0 0 0],'m/s')
gndStn.setInitEulAng([0 0 0],'rad');
gndStn.initAngVelVec.setValue([0 0 0],'rad/s');





%%

sim('groundStation001_th')
tsc = signalcontainer(logsout);


% vhcl.animateSim(tsc,.4,...
%     'PathFunc',fltCtrl.fcnName.Value,...
%     'PlotTracer',true,...
%     'FontSize',24,...
%     'PowerBar',false,...
%     'PlotAxes',false,...
%     'TetherNodeForces',true,...
%     'TracerDuration',10,...
%     'GroundStation',gndStn,...
%     'GifTimeStep',1/30)
figure;
plotAnchThrTen;
figure;
tsc.gndStnPositionVec.plot



%  figure;
%  plot(tsc.anchThrNode1FVec.Time,squeeze(tsc.anchThrNode1FVec.Data(1,1,1,:)));
%  title('Mooring Line 1 X Force')
%  xlabel('Time (Seconds)')
%  ylabel('Force (Newtons)')
%  
%  figure;
%  plot(tsc.anchThrNode1FVec.Time,squeeze(tsc.anchThrNode1FVec.Data(1,1,2,:)));
%  title('Mooring Line 2 X Force')
%  xlabel('Time (Seconds)')
%  ylabel('Force (Newtons)')
%  
%  figure;
%  plot(tsc.anchThrNode1FVec.Time,squeeze(tsc.anchThrNode1FVec.Data(1,1,3,:)));
%  title('Mooring Line 3 X Force')
%  xlabel('Time (Seconds)')
%  ylabel('Force (Newtons)')
%  
%  figure;
%  plot(tsc.anchThrNode1FVec.Time,squeeze(tsc.anchThrNode1FVec.Data(1,1,4,:)));
%  title('Mooring Line 4 X Force')
%  xlabel('Time (Seconds)')
%  ylabel('Force (Newtons)')
%  
%   figure;
%  plot(tsc.anchThrNode1FVec.Time,squeeze(tsc.anchThrNode1FVec.Data(2,1,1,:)));
%  title('Mooring Line 1 Y Force')
%  xlabel('Time (Seconds)')
%  ylabel('Force (Newtons)')
%  
%  figure;
%  plot(tsc.anchThrNode1FVec.Time,squeeze(tsc.anchThrNode1FVec.Data(2,1,2,:)));
%  title('Mooring Line 2 Y Force')
%  xlabel('Time (Seconds)')
%  ylabel('Force (Newtons)')
%  
%  figure;
%  plot(tsc.anchThrNode1FVec.Time,squeeze(tsc.anchThrNode1FVec.Data(2,1,3,:)));
%  title('Mooring Line 3 Y Force')
%  xlabel('Time (Seconds)')
%  ylabel('Force (Newtons)')
%  
%  figure;
%  plot(tsc.anchThrNode1FVec.Time,squeeze(tsc.anchThrNode1FVec.Data(2,1,4,:)));
%  title('Mooring Line 4 Y Force')
%  xlabel('Time (Seconds)')
%  ylabel('Force (Newtons)')
%  
%   figure;
%  plot(tsc.anchThrNode1FVec.Time,squeeze(tsc.anchThrNode1FVec.Data(3,1,1,:)));
%  title('Mooring Line 1 Z Force')
%  xlabel('Time (Seconds)')
%  ylabel('Force (Newtons)')
%  
%  figure;
%  plot(tsc.anchThrNode1FVec.Time,squeeze(tsc.anchThrNode1FVec.Data(3,1,2,:)));
%  title('Mooring Line 2 Z Force')
%  xlabel('Time (Seconds)')
%  ylabel('Force (Newtons)')
%  
%  figure;
%  plot(tsc.anchThrNode1FVec.Time,squeeze(tsc.anchThrNode1FVec.Data(3,1,3,:)));
%  title('Mooring Line 3 Z Force')
%  xlabel('Time (Seconds)')
%  ylabel('Force (Newtons)')
%  
%  figure;
%  plot(tsc.anchThrNode1FVec.Time,squeeze(tsc.anchThrNode1FVec.Data(3,1,4,:)));
%  title('Mooring Line 4 Z Force')
%  xlabel('Time (Seconds)')
%  ylabel('Force (Newtons)')
 
 % mags 
  
 ten1 = sqrt(squeeze(tsc.anchThrNode1FVec.Data(1,1,1,:)).^2  + squeeze(tsc.anchThrNode1FVec.Data(2,1,1,:)).^2 + squeeze(tsc.anchThrNode1FVec.Data(3,1,1,:)).^2);
 ten2 = sqrt(squeeze(tsc.anchThrNode1FVec.Data(1,1,2,:)).^2  + squeeze(tsc.anchThrNode1FVec.Data(2,1,2,:)).^2 + squeeze(tsc.anchThrNode1FVec.Data(3,1,2,:)).^2);
 ten3 = sqrt(squeeze(tsc.anchThrNode1FVec.Data(1,1,3,:)).^2  + squeeze(tsc.anchThrNode1FVec.Data(2,1,3,:)).^2 + squeeze(tsc.anchThrNode1FVec.Data(3,1,3,:)).^2);
 ten4 = sqrt(squeeze(tsc.anchThrNode1FVec.Data(1,1,4,:)).^2  + squeeze(tsc.anchThrNode1FVec.Data(2,1,4,:)).^2 + squeeze(tsc.anchThrNode1FVec.Data(3,1,4,:)).^2);
 ten5 = sqrt(squeeze(tsc.anchThrNode1FVec.Data(1,1,5,:)).^2  + squeeze(tsc.anchThrNode1FVec.Data(2,1,5,:)).^2 + squeeze(tsc.anchThrNode1FVec.Data(3,1,5,:)).^2);
 ten6 = sqrt(squeeze(tsc.anchThrNode1FVec.Data(1,1,6,:)).^2  + squeeze(tsc.anchThrNode1FVec.Data(2,1,6,:)).^2 + squeeze(tsc.anchThrNode1FVec.Data(3,1,6,:)).^2);
 figure;
 plot(tsc.anchThrNode1FVec.Time,ten1)
 title('Mooring Line 1 Force Magnitude')
 xlabel('Time (Seconds)')
 ylabel('Force (Newtons)')
 
 figure;
 plot(tsc.anchThrNode1FVec.Time,ten2)
 title('Mooring Line 2 Force Magnitude')
 xlabel('Time (Seconds)')
 ylabel('Force (Newtons)')
 
 figure;
 plot(tsc.anchThrNode1FVec.Time,ten3)
 title('Mooring Line 3 Force Magnitude')
 xlabel('Time (Seconds)')
 ylabel('Force (Newtons)')
 
 figure;
 plot(tsc.anchThrNode1FVec.Time,ten4)
 title('Mooring Line 4 Force Magnitude')
 xlabel('Time (Seconds)')
 ylabel('Force (Newtons)')
 
  figure;
 plot(tsc.anchThrNode1FVec.Time,ten5)
 title('Mooring Line 5 Force Magnitude')
 xlabel('Time (Seconds)')
 ylabel('Force (Newtons)')
 
 
  figure;
 plot(tsc.anchThrNode1FVec.Time,ten6)
 title('Mooring Line 6 Force Magnitude')
 xlabel('Time (Seconds)')
 ylabel('Force (Newtons)')
 
gndStn.animateGS(tsc,2,...
    'FontSize',24,...
    'GroundStation',gndStn,...
    'GifTimeStep',1/30,...
    'SaveGif',true)