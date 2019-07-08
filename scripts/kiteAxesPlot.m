%%
parseLogsout;


figure
ax=axes;
% pathvals=tetherLength*boothSToGroundPos(0:.01:2*pi,aBooth,bBooth,latCurve,0);
lat=pi/4;
long=0:.01:2*pi;
pathvals=tetherLength*[cos(long).*cos(lat);
         sin(long).*cos(lat);
         ones(1,length(long)).*sin(lat);];
waittime = .05; 
animation_time = 3;
filename="Dummy_Controller_4";
timevec=tsc.positionVec.Time;
 %%
for t=linspace(0,timevec(end),ceil(animation_time/waittime))
[~,i]=min(abs(timevec-t));
plot3(pathvals(1,:),pathvals(2,:),pathvals(3,:),'lineWidth',.5)
hold on
 
posV = tsc.positionVec.Data(:,:,i);
eulerAnglesPlot = [tsc.eulerRoll.Data(i),tsc.eulerPitch.Data(i),tsc.eulerYaw.Data(i)];
[bodyToGr,~]=rotation_sequence(eulerAnglesPlot);

bodyAxisPointsx1 =[-8;0; 0];
bodyAxisPointsx2 = [8;0; 0];

bodyAxisPointsy1 =[0;-5; 0];
bodyAxisPointsy2= [0;5; 0];

bodyAxisPointsz1 =[8;0; 0];
bodyAxisPointsz2= [8;0; 6];


groundBdyAxisX1=bodyToGr*bodyAxisPointsx1+posV;
groundBdyAxisX2=bodyToGr*bodyAxisPointsx2+posV;

groundBdyAxisY1=bodyToGr*bodyAxisPointsy1+posV;
groundBdyAxisY2=bodyToGr*bodyAxisPointsy2+posV;

groundBdyAxisZ1=bodyToGr*bodyAxisPointsz1+posV;
groundBdyAxisZ2=bodyToGr*bodyAxisPointsz2+posV;


scatter3([groundBdyAxisX1(1,:);groundBdyAxisX2(1,:)],[groundBdyAxisX1(2,:);groundBdyAxisX2(2,:)],[groundBdyAxisX1(3,:);groundBdyAxisX2(3,:)],'filled');
line([groundBdyAxisX1(1,:);groundBdyAxisX2(1,:)],[groundBdyAxisX1(2,:);groundBdyAxisX2(2,:)],[groundBdyAxisX1(3,:);groundBdyAxisX2(3,:)],'LineWidth',4)

scatter3([groundBdyAxisY1(1,:);groundBdyAxisY2(1,:)],[groundBdyAxisY1(2,:);groundBdyAxisY2(2,:)],[groundBdyAxisY1(3,:);groundBdyAxisY2(3,:)],'filled');
line([groundBdyAxisY1(1,:);groundBdyAxisY2(1,:)],[groundBdyAxisY1(2,:);groundBdyAxisY2(2,:)],[groundBdyAxisY1(3,:);groundBdyAxisY2(3,:)],'LineWidth',3)

scatter3([groundBdyAxisZ1(1,:);groundBdyAxisZ2(1,:)],[groundBdyAxisZ1(2,:);groundBdyAxisZ2(2,:)],[groundBdyAxisZ1(3,:);groundBdyAxisZ2(3,:)],'filled');
line([groundBdyAxisZ1(1,:);groundBdyAxisZ2(1,:)],[groundBdyAxisZ1(2,:);groundBdyAxisZ2(2,:)],[groundBdyAxisZ1(3,:);groundBdyAxisZ2(3,:)],'LineWidth',2)

plot3(tsc.positionVec.Data(1,1:i),tsc.positionVec.Data(2,1:i),tsc.positionVec.Data(3,1:i),'lineWidth',2)
title(['T=' num2str(tsc.positionVec.Time(i))])
[x,y,z]=sphere;x=tetherLength*x;y=tetherLength*y;z=tetherLength*z;
h=surfl(x,y,z);set(h,'FaceAlpha',0.5);shading(ax,'interp')
quiver3(tsc.positionVec.Data(1,i),tsc.positionVec.Data(2,i),tsc.positionVec.Data(3,i),tsc.velocityVec.Data(1,i),tsc.velocityVec.Data(2,i),tsc.velocityVec.Data(3,i))
if min(tsc.positionVec.Data(3,1,:))>0
    zlim([0 inf])
end
if exist('AZ','var') && exist('EL','var')
    view(AZ,EL)
else
    view(90,15)
end
% scatter3(tetherLength*tsc.star_pos.Data(1:i,1),tetherLength*tsc.star_pos.Data(1:i,2),tetherLength*tsc.star_pos.Data(1:i,3),'k')
hold off
% % pause(waittime)
%                         % Capture the plot as an image 
%                         frame = getframe(ax); 
%                         im = frame2im(frame); 
%                         [imind,cm] = rgb2ind(im,256); 
%                         % Write to the GIF File 
%                         if i == 1 
%                           imwrite(imind,cm,filename,'gif', 'Loopcount',inf); 
%                         else 
%                           imwrite(imind,cm,filename,'gif','DelayTime',waittime,'WriteMode','append'); 
%                         end 
pause(.05)
end