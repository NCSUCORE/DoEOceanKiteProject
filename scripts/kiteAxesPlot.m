%%
parseLogsout;
grow = false;
figure
ax=axes;
% pathvals=tetherLength*boothSToGroundPos(0:.01:2*pi,aBooth,bBooth,latCurve,0);
% lat=pi/8;
% long=0:.01:2*pi;
% pathvals=tetherLength*[cos(long).*cos(lat);
%          sin(long).*cos(lat);
%          ones(1,length(long)).*sin(lat);];
pathvals=swapablePath(linspace(0,1,1000),pathCtrl.pathParams.Value);
% [tanPathVals,tans]=constantLat(linspace(0,1,10),[pi/4,0,pi/2,tetherLength]);
waittime = .1; 
animation_time = 10;
filename="MMadd_success.gif";
timevec=tsc.positionVec.Time;
tetherLength=pathCtrl.pathParams.Value(end);
 %%
for t=linspace(0,timevec(end),ceil(animation_time/waittime))
[~,i]=min(abs(timevec-t));

posG = tsc.positionVec.Data(:,:,i);
if grow
    tetherLength = norm(posG);
    pathvals=swapablePath(linspace(0,1,1000),[pathCtrl.pathParams.Value(1:end-1) tetherLength]);
end
plot3(pathvals(1,:),pathvals(2,:),pathvals(3,:),'lineWidth',.5)
hold on
% quiver3(tanPathVals(1,:),tanPathVals(2,:),tanPathVals(3,:),tans(1,:),tans(2,:),tans(3,:))

 

eulerAnglesPlot = [tsc.eulerRoll.Data(i),tsc.eulerPitch.Data(i),tsc.eulerYaw.Data(i)];
[bodyToGr,~]=rotation_sequence(eulerAnglesPlot);

bodyAxisPointsx1 =[-8;0; 0];
bodyAxisPointsx2 = [8;0; 0];

bodyAxisPointsy1 =[0;-5; 0];
bodyAxisPointsy2= [0;5; 0];

bodyAxisPointsz1 =[8;0; 0];
bodyAxisPointsz2= [8;0; 6];


groundBdyAxisX1=bodyToGr*bodyAxisPointsx1+posG;
groundBdyAxisX2=bodyToGr*bodyAxisPointsx2+posG;

groundBdyAxisY1=bodyToGr*bodyAxisPointsy1+posG;
groundBdyAxisY2=bodyToGr*bodyAxisPointsy2+posG;

groundBdyAxisZ1=bodyToGr*bodyAxisPointsz1+posG;
groundBdyAxisZ2=bodyToGr*bodyAxisPointsz2+posG;


scatter3([groundBdyAxisX1(1,:);groundBdyAxisX2(1,:)],[groundBdyAxisX1(2,:);groundBdyAxisX2(2,:)],[groundBdyAxisX1(3,:);groundBdyAxisX2(3,:)],'filled');
line([groundBdyAxisX1(1,:);groundBdyAxisX2(1,:)],[groundBdyAxisX1(2,:);groundBdyAxisX2(2,:)],[groundBdyAxisX1(3,:);groundBdyAxisX2(3,:)],'LineWidth',4)

scatter3([groundBdyAxisY1(1,:);groundBdyAxisY2(1,:)],[groundBdyAxisY1(2,:);groundBdyAxisY2(2,:)],[groundBdyAxisY1(3,:);groundBdyAxisY2(3,:)],'filled');
line([groundBdyAxisY1(1,:);groundBdyAxisY2(1,:)],[groundBdyAxisY1(2,:);groundBdyAxisY2(2,:)],[groundBdyAxisY1(3,:);groundBdyAxisY2(3,:)],'LineWidth',3)

scatter3([groundBdyAxisZ1(1,:);groundBdyAxisZ2(1,:)],[groundBdyAxisZ1(2,:);groundBdyAxisZ2(2,:)],[groundBdyAxisZ1(3,:);groundBdyAxisZ2(3,:)],'filled');
line([groundBdyAxisZ1(1,:);groundBdyAxisZ2(1,:)],[groundBdyAxisZ1(2,:);groundBdyAxisZ2(2,:)],[groundBdyAxisZ1(3,:);groundBdyAxisZ2(3,:)],'LineWidth',2)

plot3(tsc.positionVec.Data(1,1:i),tsc.positionVec.Data(2,1:i),tsc.positionVec.Data(3,1:i),'k','lineWidth',2)
title(['T=' num2str(tsc.positionVec.Time(i))])
[x,y,z]=sphere;x=tetherLength*x;y=tetherLength*y;z=tetherLength*z;
h=surfl(x,y,z);set(h,'FaceAlpha',0.5);shading(ax,'interp')
quiver3(tsc.positionVec.Data(1,i),tsc.positionVec.Data(2,i),tsc.positionVec.Data(3,i),tsc.velocityVec.Data(1,i),tsc.velocityVec.Data(2,i),tsc.velocityVec.Data(3,i))
dispVelVecDes=tsc.velVectorDes.Data(:,i)*10;
quiver3(tsc.positionVec.Data(1,i),tsc.positionVec.Data(2,i),tsc.positionVec.Data(3,i),dispVelVecDes(1),dispVelVecDes(2),dispVelVecDes(3),'r','lineWidth',2)
if min(tsc.positionVec.Data(3,1,:))>0
    zlim([0 inf])
end
pause(.01)
if exist('AZ','var') && exist('EL','var')
    view(AZ,EL)
else
    view(90,15)
end
% scatter3(tetherLength*     tsc.star_pos.Data(1:i,1),tetherLength*tsc.star_pos.Data(1:i,2),tetherLength*tsc.star_pos.Data(1:i,3),'k')
hold off
pause(.1)
%                         % Capture the plot as an image 
%                         frame = getframe(gcf); 
%                         im = frame2im(frame); 
%                         [imind,cm] = rgb2ind(im,256); 
%                         % Write to the GIF File 
%                         if i == 1 
%                           imwrite(imind,cm,filename,'gif', 'Loopcount',inf); 
%                         else 
%                           imwrite(imind,cm,filename,'gif','DelayTime',waittime,'WriteMode','append'); 
%                         end 
% pause(.05)
end