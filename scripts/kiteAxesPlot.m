%%
a=parseLogsout;


 figure
 ax=axes;
 pathvals=tetherLength*boothSToGroundPos(0:.01:2*pi,aBooth,bBooth,latCurve,0);
 waittime = .5; 
 filename="Dummy_Controller_4";
 %%
for i=1:floor(length(a.positionVec.Data(1,:))/(duration_s/waittime)):length(a.positionVec.Data(1,:))
 plot3(pathvals(1,:),pathvals(2,:),pathvals(3,:),'lineWidth',.5)
 hold on
 
posV = [a.positionVec.Data(1,:,i),a.positionVec.Data(2,:,i),a.positionVec.Data(3,:,i)];
eulerAnglesPlot = [a.eulerRoll.Data(i),a.eulerPitch.Data(i),a.eulerYaw.Data(i)];
[grndToBody,bodyToGr]=rotation_sequence(eulerAnglesPlot);

bodyAxisPointsx1 =[-11,0, 0];
bodyAxisPointsx2 = [11,0, 0];

bodyAxisPointsy1 =[0,-5, 0];
bodyAxisPointsy2= [0,5, 0];

bodyAxisPointsz1 =[0,0, -3];
bodyAxisPointsz2= [0,0, 3];


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

plot3(a.positionVec.Data(1,1:i),a.positionVec.Data(2,1:i),a.positionVec.Data(3,1:i),'lineWidth',2)
title(['T=' num2str(a.positionVec.Time(i))])
[x,y,z]=sphere;x=tetherLength*x;y=tetherLength*y;z=tetherLength*z;
h=surfl(x,y,z);set(h,'FaceAlpha',0.5);shading(ax,'interp')
if min(a.positionVec.Data(:,3))>0
    zlim([0 inf])
end
view(90,15)
% scatter3(tetherLength*a.star_pos.Data(1:i,1),tetherLength*a.star_pos.Data(1:i,2),tetherLength*a.star_pos.Data(1:i,3),'k')
hold off
% pause(waittime)
                        % Capture the plot as an image 
                        frame = getframe(ax); 
                        im = frame2im(frame); 
                        [imind,cm] = rgb2ind(im,256); 
                        % Write to the GIF File 
                        if i == 1 
                          imwrite(imind,cm,filename,'gif', 'Loopcount',inf); 
                        else 
                          imwrite(imind,cm,filename,'gif','DelayTime',waittime,'WriteMode','append'); 
                        end 
end