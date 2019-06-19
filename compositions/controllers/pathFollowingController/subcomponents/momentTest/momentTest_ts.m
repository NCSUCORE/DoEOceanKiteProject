createModAyazPlantBus
createConstantUniformFlowEnvironmentBus
createTestUntilRollCtrlBus
%%%%%%%%% Env and Sim Params %%%%%%%%
flow=[1.5;0;0;];
sim_time=25;
%%%%%%%%% Plant Attributes %%%%%%%%%%
mass = 6182; %kgs
tetherLength = 50; %meters
tetherTen = 1.6e5;%30000; % newtons from sim used for proposal (33seconds)
velMag= 7;%m/s from sim used for proposal
accMag= tetherTen/mass; %assumes lift = tether tension
MOI_X=1e5; %kg*m^2 from sim used for proposal

long = 0;
lat = .6;
path_init = tetherLength*[cos(long).*cos(lat);
         sin(long).*cos(lat);
         sin(lat);];
initPos = [path_init(1);path_init(2);path_init(3);];
initVelAng = 180;%degrees
initVelTan= velMag*[cosd(initVelAng);sind(initVelAng);0];
%%%%%%%%%Controller Params%%%%%%
aBooth=1;bBooth=1;latCurve=.5;

%2 deg/s^2 for an error of 1 radian
kpRollMom =2*MOI_X;
kdRollMom = 5*MOI_X;
tauRollMom = .01; 

maxBank=45*pi/180;
kpVelAng=maxBank/(pi/2); %max bank divided by large error
kiVelAng=kpVelAng/100;
kdVelAng=kpVelAng;
tauVelAng=.01;

controlAlMat = [1 0 0 ; 0 1 0 ; 0 0 1];
controlSigMax = 5*10^7;

%%
sim('momentTest_th')

%%

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
%
pause(3)
% %%
% figure
% ax=axes;
% runtime=10;
% waittime=.05;
% pathvals=tetherLength*boothSToGroundPos(0:.01:2*pi,aBooth,bBooth,latCurve,0);
% % filename="Dummy_Controller_2_lowaccel.gif";
% for i=1:floor(length(a.positionVec.Data(:,1))/(runtime/waittime)):length(a.positionVec.Data(:,1))
% plot3(pathvals(1,:),pathvals(2,:),pathvals(3,:),'lineWidth',.5)
% hold on
% plot3(a.positionVec.Data(1:i,1),a.positionVec.Data(1:i,2),a.positionVec.Data(1:i,3),'lineWidth',2)
% title(['T=' num2str(a.positionVec.Time(i))])
% [x,y,z]=sphere;x=tetherLength*x;y=tetherLength*y;z=tetherLength*z;
% h=surfl(x,y,z);set(h,'FaceAlpha',0.5);shading(ax,'interp')
% if min(a.positionVec.Data(:,3))>0
%     zlim([0 inf])
% end
% view(100,45)
% scatter3(tetherLength*a.star_pos.Data(1:i,1),tetherLength*a.star_pos.Data(1:i,2),tetherLength*a.star_pos.Data(1:i,3),'k')
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
