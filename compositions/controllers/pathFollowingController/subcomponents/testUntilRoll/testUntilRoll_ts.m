createModAyazPlantBus
createConstantUniformFlowEnvironmentBus
createTestUntilRollCtrlBus

mass = 6182; %kgs
tetherLength = 50; %meters
tetherTen = 1.6e5; % newtons
velMag= 7;
accMag= tetherTen/mass; 

long = -.05;
lat = .51;
path_init = tetherLength*[cos(long).*cos(lat);
         sin(long).*cos(lat);
         sin(lat);];
initPos = [path_init(1);path_init(2);path_init(3);];
initVelAng = 180;%degrees
initVelTan= velMag*[cosd(initVelAng);sind(initVelAng);0];

maxBank=45*pi/180;
kpVelAng=maxBank/(pi/2); %max bank divided by large error
kiVelAng=kpVelAng/100;
kdVelAng=kpVelAng;
tauVelAng=.01;
flow=[1.5;0;0;];
sim_time=50;
%%
simWithMonitor('testUntilRoll_th')
%%
aBooth=1;bBooth=1;latCurve=.5;
a=parseLogsout;
% close all
figure
ax=axes;
pathvals=tetherLength*boothSToGroundPos(0:.01:2*pi,aBooth,bBooth,latCurve,0);
plot3(pathvals(1,:),pathvals(2,:),pathvals(3,:),'lineWidth',.5)
hold on

plot3(a.positionVec.Data(:,1),a.positionVec.Data(:,2),a.positionVec.Data(:,3),'lineWidth',2)
[x,y,z]=sphere;x=tetherLength*x;y=tetherLength*y;z=tetherLength*z;
h=surfl(x,y,z);set(h,'FaceAlpha',0.5);shading(ax,'interp')
if min(a.positionVec.Data(:,3))>0
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
