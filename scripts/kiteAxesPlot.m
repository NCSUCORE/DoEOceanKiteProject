%%
parseLogsout;
% close all
grow = true;
figure
ax=axes;
% axes(spl3);
% subplot(1,3,3)
% pathvals=tetherLength*boothSToGroundPos(0:.01:2*pi,aBooth,bBooth,latCurve,0);
% lat=pi/8;
% long=0:.01:2*pi;
% pathvals=tetherLength*[cos(long).*cos(lat);
%          sin(long).*cos(lat);
%          ones(1,length(long)).*sin(lat);];
pathvals=swapablePath(linspace(0,1,1000),pathCtrl.pathParams.Value);
% [tanPathVals,tans]=constantLat(linspace(0,1,10),[pi/4,0,pi/2,tetherLength]);
    waittime = .1; 
animation_time = 5;
filename="controlSurfDef.gif";
timevec=tsc.positionVec.Time;
tetherLength=pathCtrl.pathParams.Value(end);
 %%
% manual=true;
manual=false;
range1=100;
% for t=60:.2:120
for t=linspace(0,timevec(end),ceil(animation_time/waittime))%t=223.4%timevec(end)
[~,i]=min(abs(timevec-t));

% subplot(1,3,1)
% plot(tsc.velocityVec.Time(1:i), squeeze(velmags(1:i)));
% xlim([0,1000])
% xlabel('time (s)')
% ylabel('ground frame velocity (m)')
% 
% subplot(1,3,2)
% plot(tsc.velocityVec.Time(1:i),squeeze(radialPos(1:i)));
% xlim([0,1000])
% xlabel('time (s)')
% ylabel('radial position/tether length (m)')
% 
% subplot(1,3,3)

posG = tsc.positionVec.Data(:,:,i);
if grow
    tetherLength = norm(posG);
    pathvals=swapablePath(linspace(0,1,1000),[pathCtrl.pathParams.Value(1:end-1) tetherLength]);
end
plot3(pathvals(1,:),pathvals(2,:),pathvals(3,:),'lineWidth',.5)
hold on
% quiver3(tanPathVals(1,:),tanPathVals(2,:),tanPathVals(3,:),tans(1,:),tans(2,:),tans(3,:))



eulerAnglesPlot = tsc.eulerAngles.Data(:,1,i);
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
%% Random other stuff
plot3(tsc.positionVec.Data(1,1:i),tsc.positionVec.Data(2,1:i),tsc.positionVec.Data(3,1:i),'k','lineWidth',2)

% title(sprintf("t=%4.1f;percent perp=%4.4f; central ang=%4.2f;",tsc.positionVec.Time(i),tsc.perc_perp.Data(i),tsc.central_angle.Data(i)*180/pi))
title(sprintf("t=%4.1f;tanroll=%4.2f",tsc.positionVec.Time(i),tsc.tanRoll.Data(i)*180/pi))

[x,y,z]=sphere;x=tetherLength*x;y=tetherLength*y;z=tetherLength*z;
h=surfl(x,y,z);set(h,'FaceAlpha',0.5);shading(gca,'interp')
quiver3(tsc.positionVec.Data(1,i),tsc.positionVec.Data(2,i),tsc.positionVec.Data(3,i),tsc.velocityVec.Data(1,i),tsc.velocityVec.Data(2,i),tsc.velocityVec.Data(3,i),'w','lineWidth',1.2)

% starpos=tsc.star_pos.Data(i,:);
% starpos=tetherLength*starpos/norm(starpos);
% scatter3(starpos(1),starpos(2),starpos(3),'k')
% 
% startanvec=tsc.tan_unit.Data(i,:);
% startanvec=7*startanvec;
% 
% starperpvec=tsc.perp_unit.Data(i,:);
% starperpvec = 7*starperpvec;
% 
% dispVelVecDes=tsc.velVectorDes.Data(i,:);
% dispVelVecDes = 10*dispVelVecDes;
% 
% quiver3(tsc.positionVec.Data(1,i),tsc.positionVec.Data(2,i),tsc.positionVec.Data(3,i),dispVelVecDes(1),dispVelVecDes(2),dispVelVecDes(3),'r','lineWidth',2)
% quiver3(tsc.positionVec.Data(1,i),tsc.positionVec.Data(2,i),tsc.positionVec.Data(3,i),starperpvec(1),starperpvec(2),starperpvec(3),'g','lineWidth',2)
% quiver3(tsc.positionVec.Data(1,i),tsc.positionVec.Data(2,i),tsc.positionVec.Data(3,i),startanvec(1),startanvec(2),startanvec(3),'b','lineWidth',2)

%% limits plotti
if min(tsc.positionVec.Data(3,1,:))>0
    zlim([0 inf])
end
if exist('AZ','var') && exist('EL','var')
    view(AZ,EL)
else
    view(90,15)
end
pause(.01)
% axis([tsc.positionVec.Data(1,i)-range1 tsc.positionVec.Data(1,i)+range1 tsc.positionVec.Data(2,i)-range1 tsc.positionVec.Data(2,i)+range1 tsc.positionVec.Data(3,i)-range1 tsc.positionVec.Data(3,i)+range1])

hold off
                        % Capture the plot as an image 
                        frame = getframe(gcf); 
                        im = frame2im(frame); 
                        [imind,cm] = rgb2ind(im,256); 
                        % Write to the GIF File 
                        if i == 1 
                          imwrite(imind,cm,filename,'gif', 'Loopcount',inf); 
                        else 
                          imwrite(imind,cm,filename,'gif','DelayTime',waittime,'WriteMode','append'); 
                        end 
if manual
    pause
else
    pause(waittime)
end
end