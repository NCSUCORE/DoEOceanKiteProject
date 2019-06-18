createModAyazPlantBus
createModAyazFlowEnvironmentBus
createTestUntilRollCtrlBus

mass = 6182; %kgs
tetherLength = 50; %meters
tetherTen = 1.6e5; % newtons
velMag= 7;
accMag= tetherTen/mass; 

long = -.5;
lat = .3;
path = tetherLength*[cos(long).*cos(lat);
         sin(long).*cos(lat);
         sin(lat);];
init_pos = path;
init_vel_tan=[velMag;0;0];

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
pathvals=tetherLength*path(0:.01:2*pi);
plot3(pathvals(1,:),pathvals(2,:),pathvals(3,:),'lineWidth',.5)
hold on

plot3(a.pos.Data(:,1),a.pos.Data(:,2),a.pos.Data(:,3),'lineWidth',2)
[x,y,z]=sphere;x=tetherLength*x;y=tetherLength*y;z=tetherLength*z;
h=surfl(x,y,z);set(h,'FaceAlpha',0.5);shading(ax,'interp')
if min(a.pos.Data(:,3))>0
    zlim([0 inf])
end
view(100,45)

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
