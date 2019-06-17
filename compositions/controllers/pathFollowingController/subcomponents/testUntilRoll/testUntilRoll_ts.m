createModAyazPlantBus
createModAyazFlowEnvironmentBus
createTestUntilRollCtrlBus

velMag = .05;
accelMag= .5;
long = .8;
lat = .6;
r = 1;
path = r*[cos(long).*cos(lat);
         sin(long).*cos(lat);
         sin(lat);];
init_pos = [path(1);path(2);path(3);];
init_vel_tan=[.05;0;0];

maxBank=45*pi/180;
kp_chi=maxBank/(pi/2); %max bank divided by large error
ki_chi=kp_chi/100;
kd_chi=kp_chi;
tau_chi=.1;
flow=[1;0;0;];
sim_time=50;
%%
simWithMonitor('testUntilRoll_th')
%%
aB=1;bB=1;phi_curve=.5;
lamda=@(s) aB*sin(s)./(1+(aB/bB)^2*cos(s).^2);
phi=@(s) (aB/bB)^2*sin(s).*cos(s)./(1 + (aB/bB)^2*cos(s).^2);
path = @(s)[cos(lamda(s)).*cos(phi_curve+phi(s));...
            sin(lamda(s)).*cos(phi_curve+phi(s));...
            sin(phi_curve+phi(s));]; 
a=parseLogsout;
close all
figure
ax=axes;
pathvals=path(0:.01:2*pi);
plot3(pathvals(1,:),pathvals(2,:),pathvals(3,:),'lineWidth',.5)
hold on

plot3(a.pos.Data(:,1),a.pos.Data(:,2),a.pos.Data(:,3),'lineWidth',2)
[x,y,z]=sphere;x=1*x;y=1*y;z=1*z;
h=surfl(x,y,z);set(h,'FaceAlpha',0.5);shading(ax,'interp')
view(90,30)

%% 
% pause(3)
% close all
% figure
% ax=axes;
% runtime=3;
% waittime=.01;
% pathvals=path(0:.01:2*pi);
% filename="Dummy_Controller_2_lowaccel.gif";
% for i=1:floor(length(a.pos.Data(:,1))/(runtime/waittime)):length(a.pos.Data(:,1))
% plot3(pathvals(1,:),pathvals(2,:),pathvals(3,:),'lineWidth',.5)
% hold on
% plot3(a.pos.Data(1:i,1),a.pos.Data(1:i,2),a.pos.Data(1:i,3),'lineWidth',2)
% title(['T=' num2str(a.pos.Time(i))])
% [x,y,z]=sphere;h=surfl(x,y,z);set(h,'FaceAlpha',0.5);shading(ax,'interp')
% view(90,30)
% % scatter3(a.star_pos.Data(1:i,1),a.star_pos.Data(1:i,2),a.star_pos.Data(1:i,3),'k')
% hold off
% pause(waittime)
%                         % Capture the plot as an image 
%                         frame = getframe(ax); 
%                         im = frame2im(frame); 
%                         [imind,cm] = rgb2ind(im,256); 
%                         % Write to the GIF File 
%                         if i == 1 
%                           imwrite(imind,cm,filename,'gif', 'Loopcount',inf); 
%                         else 
%                           imwrite(imind,cm,filename,'gif','DelayTime',0.05,'WriteMode','append'); 
%                         end 
% end
