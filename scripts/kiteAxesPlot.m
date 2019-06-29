
a=parseLogsout;
 close all
 figure
 ax=axes;
 pathvals=tetherLength*boothSToGroundPos(0:.01:2*pi,aBooth,bBooth,latCurve,0);
 
for i=1:floor(length(a.positionVec.Data(:,1))/(runtime/waittime)):length(a.positionVec.Data(:,1))

    
 
 plot3(pathvals(1,:),pathvals(2,:),pathvals(3,:),'lineWidth',.5)
 hold on
 
 plot3(a.positionVec.Data(i,:),a.positionVec.Data(i,:),a.positionVec.Data(i,:),'lineWidth',2)
 [x,y,z]=sphere;x=tetherLength*x;y=tetherLength*y;z=tetherLength*z;
 h=surfl(x,y,z);set(h,'FaceAlpha',0.5);shading(ax,'interp')
 if min(a.positionVec.Data(3,:))>0
     zlim([0 inf])
 end
 
 


posV = [a.positionVec.Data(i,1),a.positionVec.Data(i,2),a.positionVec.Data(i,3)];

eulerAnglesPlot = [a.eulerPitch.Data(i,1),a.eulerRoll.Data(i,2),a.eulerYaw.Data(i,3)];

 [grndToBody,bodyToGr]=rotation_sequence(eulerAnglesPlot);

bodyAxisPointsx1 =[-7,0, 0];
bodyAxisPointsx2 = [7,0, 0];

bodyAxisPointsy1 =[0,-3, 0];
bodyAxisPointsy2= [0,3, 0];

bodyAxisPointsz1 =[0,0, -1.5];
bodyAxisPointsz2= [0,0, 1.5];


groundBdyAxisX1=bodyToGr*[bodyAxisPointsx1]'+posV';
groundBdyAxisX2=bodyToGr*[bodyAxisPointsx2]'+posV';

groundBdyAxisY1=bodyToGr*[bodyAxisPointsy1]'+posV';
groundBdyAxisY2=bodyToGr*[bodyAxisPointsy2]'+posV';

groundBdyAxisZ1=bodyToGr*[bodyAxisPointsz1]'+posV';
groundBdyAxisZ2=bodyToGr*[bodyAxisPointsz2]'+posV';


scatter3([groundBdyAxisX1(1,:);groundBdyAxisX2(1,:)],[groundBdyAxisX1(2,:);groundBdyAxisX2(2,:)],[groundBdyAxisX1(3,:);groundBdyAxisX2(3,:)],'filled');
line([groundBdyAxisX1(1,:);groundBdyAxisX2(1,:)],[groundBdyAxisX1(2,:);groundBdyAxisX2(2,:)],[groundBdyAxisX1(3,:);groundBdyAxisX2(3,:)],'LineWidth',6)

scatter3([groundBdyAxisY1(1,:);groundBdyAxisY2(1,:)],[groundBdyAxisY1(2,:);groundBdyAxisY2(2,:)],[groundBdyAxisY1(3,:);groundBdyAxisY2(3,:)],'filled');
line([groundBdyAxisY1(1,:);groundBdyAxisY2(1,:)],[groundBdyAxisY1(2,:);groundBdyAxisY2(2,:)],[groundBdyAxisY1(3,:);groundBdyAxisY2(3,:)],'LineWidth',3)

scatter3([groundBdyAxisZ1(1,:);groundBdyAxisZ2(1,:)],[groundBdyAxisZ1(2,:);groundBdyAxisZ2(2,:)],[groundBdyAxisZ1(3,:);groundBdyAxisZ2(3,:)],'filled');
line([groundBdyAxisZ1(1,:);groundBdyAxisZ2(1,:)],[groundBdyAxisZ1(2,:);groundBdyAxisZ2(2,:)],[groundBdyAxisZ1(3,:);groundBdyAxisZ2(3,:)],'LineWidth',2)


view(100,45)
end 