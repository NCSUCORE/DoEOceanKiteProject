close all
clear
clc


len = 5;
diam = 0.25;
sideCD = 1;
endCD  = 0.1;

angles = linspace(0,pi/2,20);

dynPress = 1;

for ii = 1:length(angles)
   R = rotation_sequence([0 -angles(ii) pi/2]);
   uAppBdy = R*[1 0 0]';
   sim('fuselage_th')
   grid on
   plot3([0 simout.Data(1,1)],[0 simout.Data(1,2)],[0 simout.Data(1,3)],'LineStyle','-','LineWidth',2)
   hold on
    
end

