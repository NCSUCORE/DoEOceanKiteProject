init_pos = [2;1;1;]/sqrt(6);
end_time = 30;
aB=1;
bB=1;
phi_curve=.5;

simWithMonitor('courseFollow_plant_th')

lamda=@(s) aB*sin(s)./(1+(aB/bB)^2*cos(s).^2);
phi=@(s) (aB/bB)^2*sin(s).*cos(s)./(1 + (aB/bB)^2*cos(s).^2);
path = @(s)[cos(lamda(s)).*cos(phi_curve+phi(s));...
            sin(lamda(s)).*cos(phi_curve+phi(s));...
            sin(phi_curve+phi(s));];
a=parseLogsout;

close all
figure
ax=axes;
[x, y, z] = sphere;
h = surfl(x, y, z); 
set(h, 'FaceAlpha', 0.5)
shading(ax,'interp')
hold on
plot3(a.pos.Data(:,1),a.pos.Data(:,2),a.pos.Data(:,3))
pathvals=path(0:.01:2*pi);
plot3(pathvals(1,:),pathvals(2,:),pathvals(3,:),'lineWidth',3)
% view(80,30)
scatter3(a.star_pos.Data(:,1),a.star_pos.Data(:,2),a.star_pos.Data(:,3),'k')
% quiver3(a.pos.Data(:,1),a.pos.Data(:,2),a.pos.Data(:,3),a.vel_des.Data(:,1),a.vel_des.Data(:,2),a.vel_des.Data(:,3))
% % test=a.star_pos.Data-a.vel_des.Data;
% quiver3(a.pos.Data(:,1),a.pos.Data(:,2),a.pos.Data(:,3),a.vel.Data(:,1),a.vel.Data(:,2),a.vel.Data(:,3))

figure
plot(a.central_angle)
% 
% figure
% mags=sqrt(a.pos.Data(:,1).^2+a.pos.Data(:,2).^2+a.pos.Data(:,3).^2);
% plot(mags)