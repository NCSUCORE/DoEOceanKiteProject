clear all
close all
 l = 1.6;
 p = .8;
path7 = [ cos(l).*cos(p);
         sin(l).*cos(p);
         sin(p);];

init_pos = [path7(1);path7(2);path7(3);];
init_pos = init_pos/norm(init_pos);
end_time = 100;
aB=1;
bB=1;
phi_curve=.5;

sim('courseFollow_plant_th')
% simWithMonitor('courseFollow_plant_th')

lamda=@(s) aB*sin(s)./(1+(aB/bB)^2*cos(s).^2);
phi=@(s) (aB/bB)^2*sin(s).*cos(s)./(1 + (aB/bB)^2*cos(s).^2);
path = @(s)[cos(lamda(s)).*cos(phi_curve+phi(s));...
            sin(lamda(s)).*cos(phi_curve+phi(s));...
            sin(phi_curve+phi(s));];
a=parseLogsout;

close all
figure
ax=axes;
% [x, y, z] = sphere;
% h = surfl(x, y, z); 
% set(h, 'FaceAlpha', 0.5)
% shading(ax,'interp')
for i=1:length(a.pos.Data(:,1))
plot3(a.pos.Data(1:i,1),a.pos.Data(1:i,2),a.pos.Data(1:i,3))
hold on
pathvals=path(0:.01:2*pi);
plot3(pathvals(1,:),pathvals(2,:),pathvals(3,:),'lineWidth',3)
view(90,30)
scatter3(a.star_pos.Data(1:i,1),a.star_pos.Data(1:i,2),a.star_pos.Data(1:i,3),'k')
hold off
pause(.05)
end
% quiver3(a.pos.Data(:,1),a.pos.Data(:,2),a.pos.Data(:,3),a.machineout.Data(:,1),a.machineout.Data(:,2),a.machineout.Data(:,3))
% % test=a.star_pos.Data-a.vel_des.Data;
% quiver3(a.pos.Data(:,1),a.pos.Data(:,2),a.pos.Data(:,3),a.vel.Data(:,1),a.vel.Data(:,2),a.vel.Data(:,3))
%
figure
plot(a.central_angle)
% 
% figure
% mags=sqrt(a.pos.Data(:,1).^2+a.pos.Data(:,2).^2+a.pos.Data(:,3).^2);
% plot(mags)