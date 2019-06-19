createModAyazPlantBus
createModAyazFlowEnvironmentBus
createTestUntilRollCtrlBus
%%%%%%%%% Env and Sim Params %%%%%%%%
flow=[1.5;0;0;];
sim_time=50;
%%%%%%%%% Plant Attributes %%%%%%%%%%
mass = 6182; %kgs
tetherLength = 50; %meters
tetherTen = 1.6e5;%30000; % newtons from sim used for proposal (33seconds)
velMag= 7;%m/s from sim used for proposal
accMag= tetherTen/mass; %assumes lift = tether tension
MOI_X=1e5; %kg*m^2 from sim used for proposal

long = -.5;
lat = .3;
path_init = tetherLength*[cos(long).*cos(lat);
         sin(long).*cos(lat);
         sin(lat);];
init_pos = [path_init(1);path_init(2);path_init(3);];
init_vel_ang = 0;%degrees
init_vel_tan= velMag*[cosd(init_vel_ang);sind(init_vel_ang);0];
%%%%%%%%%Controller Params%%%%%%
%2 deg/s^2 for an error of 1 radian
kp_L =2*MOI_X;
kd_L = 5*MOI_X;
tau_L = .01; 

maxBank=45*pi/180;
kp_chi=maxBank/(pi/2); %max bank divided by large error
ki_chi=kp_chi/100;
kd_chi=kp_chi;
tau_chi=.01;

controlMomentMatrix = [1 0 0 ; 0 1 0 ; 0 0 1];
controlMomentMax = 5*10^7;

%%
simWithMonitor('momentTest_th')

%%
aB=1;bB=1;phi_curve=.5;
lamda=@(s) aB*sin(s)./(1+(aB/bB)^2*cos(s).^2);
phi=@(s) (aB/bB)^2*sin(s).*cos(s)./(1 + (aB/bB)^2*cos(s).^2);
path = @(s)[cos(lamda(s)).*cos(phi_curve+phi(s));...
            sin(lamda(s)).*cos(phi_curve+phi(s));...
            sin(phi_curve+phi(s));];
a=parseLogsout;
% close all
figure
ax=axes;
pathvals=tetherLength*path(0:.01:2*pi);
plot3(pathvals(1,:),pathvals(2,:),pathvals(3,:),'lineWidth',.5)
hold on

plot3(a.posVec.Data(:,1),a.posVec.Data(:,2),a.posVec.Data(:,3),'lineWidth',2)
[x,y,z]=sphere;x=tetherLength*x;y=tetherLength*y;z=tetherLength*z;
h=surfl(x,y,z);set(h,'FaceAlpha',0.5);shading(ax,'interp')
if min(a.posVec.Data(:,3))>0
    zlim([0 inf])
end
view(100,45)
%%
% pause(3)
% %%
% figure
% ax=axes;
% runtime=10;
% waittime=.05;
% pathvals=path(0:.01:2*pi);
% % filename="Dummy_Controller_2_lowaccel.gif";
% for i=1:floor(length(a.posG.Data(:,1))/(runtime/waittime)):length(a.posG.Data(:,1))
% plot3(pathvals(1,:),pathvals(2,:),pathvals(3,:),'lineWidth',.5)
% hold on
% plot3(a.posG.Data(1:i,1),a.posG.Data(1:i,2),a.posG.Data(1:i,3),'lineWidth',2)
% title(['T=' num2str(a.posG.Time(i))])
% [x,y,z]=sphere;x=tetherLength*x;y=tetherLength*y;z=tetherLength*z;
% h=surfl(x,y,z);set(h,'FaceAlpha',0.5);shading(ax,'interp')
% if min(a.posG.Data(:,3))>0
%     zlim([0 inf])
% end
% view(100,45)
% %scatter3(a.star_pos.Data(1:i,1),a.star_pos.Data(1:i,2),a.star_pos.Data(1:i,3),'k')
% hold off
% pause(waittime)
% %                         % Capture the plot as an image 
% %                         frame = getframe(ax); 
% %                         im = frame2im(frame); 
% %                         [imind,cm] = rgb2ind(im,256); 
% %                         % Write to the GIF File 
% %                         if i == 1 
% %                           imwrite(imind,cm,filename,'gif', 'Loopcount',inf); 
% %                         else 
% %                           imwrite(imind,cm,filename,'gif','DelayTime',waittime,'WriteMode','append'); 
% %                         end 
% end
