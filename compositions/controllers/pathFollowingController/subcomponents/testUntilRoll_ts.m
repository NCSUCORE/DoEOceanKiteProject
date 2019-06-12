createModAyazPlantBus
createModAyazFlowEnvironmentBus
createTestUntilRollCtrlBus

r_curve_max = .1;
velMag=.05;
accelMag=velMag^2/r_curve_max;
l = .5;
p = .6;
r = 1;
path = r*[cos(l).*cos(p);
         sin(l).*cos(p);
         sin(p);];
init_pos = [path(1);path(2);path(3);];
max_bank=45*pi/180;
kp_chi=max_bank/(pi/2); %max bank divided by large error
ki_chi=kp_chi/100;
kd_chi=kp_chi;
tau_chi=.1;
flow=[1;0;0;];
sim_time=100;


simWithMonitor('testUntilRoll_th')

lamda=@(s) aB*sin(s)./(1+(aB/bB)^2*cos(s).^2);
phi=@(s) (aB/bB)^2*sin(s).*cos(s)./(1 + (aB/bB)^2*cos(s).^2);
path = @(s)[cos(lamda(s)).*cos(phi_curve+phi(s));...
            sin(lamda(s)).*cos(phi_curve+phi(s));...
            sin(phi_curve+phi(s));];
a=parseLogsout;

close all
figure
ax=axes;
for i=1:20:length(a.pos.Data(:,1))
plot3(a.pos.Data(1:i,1),a.pos.Data(1:i,2),a.pos.Data(1:i,3))
hold on
[x,y,z]=sphere;h=surfl(x,y,z);set(h,'FaceAlpha',0.5);shading(ax,'interp')
pathvals=path(0:.01:2*pi);
plot3(pathvals(1,:),pathvals(2,:),pathvals(3,:),'lineWidth',3)
view(90,30)
scatter3(a.star_pos.Data(1:i,1),a.star_pos.Data(1:i,2),a.star_pos.Data(1:i,3),'k')
hold off
pause(.05)
end
