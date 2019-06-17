createModAyazPlantBus
createModAyazFlowEnvironmentBus
createTestUntilRollCtrlBus

%%%%%%%%% Plant Attributes %%%%%%%%%%
mass = 6182; %kgs
tetherLength = 50; %meters
tetherTen = 30000; % newtons
velMag= .05;%6*sqrt((tetherTen/mass) * tetherLength); %Fcentripital = m*v^2/r about origin
% r_curve_max = 10; %where does this come from?
% accMag=velMag^2/r_curve_max;
accMag=.5;%10*tetherTen/mass; %assumes you can take the entire tension in the tether,
                       %set it to 0, and put that entire force towards
                       %accellerating in a circle
MOI_X=5e5;
%%%%%%%%% Moment Controller %%%%%%
%3 deg/s^2 for an error of 45 degrees
kp_L =3/45; %
kd_L = kp_L;
tau_L = .05; 

l = -.5;
p = .7;
r = 1;
path_init = r*[cos(l).*cos(p);
         sin(l).*cos(p);
         sin(p);];
init_pos = [path_init(1);path_init(2);path_init(3);];
syms u v w
init_vel=solve(dot(path_init,[u v w])==0,sqrt(u^2+v^2+w^2)==1,u==.5);
init_vel=[init_vel.u(1);init_vel.v(1);init_vel.w(1)];
init_vel=double(init_vel)*.05;

maxBank=45*pi/180;
kp_chi=maxBank/(pi/2); %max bank divided by large error
ki_chi=kp_chi/100;
kd_chi=kp_chi;
tau_chi=.1;

flow=[1;0;0;];
sim_time=50;

simWithMonitor('momentTest_th')

aB=1;bB=1;phi_curve=.5;
lamda=@(s) aB*sin(s)./(1+(aB/bB)^2*cos(s).^2);
phi=@(s) (aB/bB)^2*sin(s).*cos(s)./(1 + (aB/bB)^2*cos(s).^2);
path = @(s)[cos(lamda(s)).*cos(phi_curve+phi(s));...
            sin(lamda(s)).*cos(phi_curve+phi(s));...
            sin(phi_curve+phi(s));];
        %%
a=parseLogsout;
% close all
figure
ax=axes;
pathvals=path(0:.01:2*pi);
plot3(pathvals(1,:),pathvals(2,:),pathvals(3,:),'lineWidth',.5)
hold on

plot3(a.posG.Data(:,1),a.posG.Data(:,2),a.posG.Data(:,3),'lineWidth',2)
[x,y,z]=sphere;x=1*x;y=1*y;z=1*z;
h=surfl(x,y,z);set(h,'FaceAlpha',0.5);shading(ax,'interp')
view(90,30)
pause(3)
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
