clc
clear all
close all

loadComponent('Manta2RotXFoil_AR8_b8');             %   AR = 8; 8m span
vhcl.buoyFactor.Value

buoy = 0.95:.01:1.1
x = ((.3)*buoy-.3)*1000/25.4

figure; hold on; grid on;
plot(buoy*100,x)
plot(103.91,11.7/25.4,'x')
legend('Trend','Current Configuration')
xlabel('Percent Buoyancy')
ylabel('CG distance aft of center of buoyancy [in]')
