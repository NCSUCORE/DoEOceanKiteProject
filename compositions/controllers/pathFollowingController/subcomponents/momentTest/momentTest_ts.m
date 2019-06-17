createModAyazPlantBus
createModAyazFlowEnvironmentBus
createTestUntilRollCtrlBus
%%%%%%%%% Env and Sim Params %%%%%%%%
flow=[1;0;0;];
sim_time=80;
%%%%%%%%% Plant Attributes %%%%%%%%%%
mass = 6182; %kgs
tetherLength = 1;%50; %meters
tetherTen = 30000; % newtons
velMag= .05;%6*sqrt((tetherTen/mass) * tetherLength); %Fcentripital = m*v^2/r about origin
% accMag=velMag^2/r_curve_max;
accMag=.5;%10*tetherTen/mass; %assumes you can take the entire tension in the tether,
                       %set it to 0, and put that entire force towards
                       %accellerating in a circle
MOI_X=5e5;

long = -.5;
lat = .7;
path_init = tetherLength*[cos(long).*cos(lat);
         sin(long).*cos(lat);
         sin(lat);];
init_pos = [path_init(1);path_init(2);path_init(3);];
init_vel_tan = velMag*[1;0;0]; %North
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
pathvals=path(0:.01:2*pi);
plot3(pathvals(1,:),pathvals(2,:),pathvals(3,:),'lineWidth',.5)
hold on

plot3(a.posG.Data(:,1),a.posG.Data(:,2),a.posG.Data(:,3),'lineWidth',2)
% [x,y,z]=sphere;x=1*x;y=1*y;z=1*z;
% h=surfl(x,y,z);set(h,'FaceAlpha',0.5);shading(ax,'interp')
view(90,30)
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
% [x,y,z]=sphere;x=x;y=y;z=z;
% h=surfl(x,y,z);set(h,'FaceAlpha',0.5);shading(ax,'interp')
% view(90,30)
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
% %                           imwrite(imind,cm,filename,'gif','DelayTime',0.05,'WriteMode','append'); 
% %                         end 
% end
