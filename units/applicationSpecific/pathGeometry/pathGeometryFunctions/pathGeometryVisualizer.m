% figure
hold on
% pathParams = pathCtrl.pathParams.Value;
% pathParams = [1,1.4,.37,0,125]; %Lem
pathParams = [.73,1.4,.36,0,125];%Circle
% pathParams = [pi/24,3*pi/8,pi/8,0,125];%Racetrack
%  pathParams = [1.200    2.2000    0.3600         0  125.0000];%Ellipse

%  pathParams = [1.6,.3,-.3,0,125];%Ellipse
%  pathvals=ellipse(linspace(0,1,1000),pathParams,[0 0 0]');
% plot3(pathvals(1,:),pathvals(2,:),pathvals(3,:),'lineWidth',1.5)

 pathvals=lemOfBooth(linspace(0,1,1000),pathParams,zeros(3,1));
 plot3(pathvals(1,:),pathvals(2,:),pathvals(3,:),'lineWidth',1.5)

% pathvals=lemOfBooth(linspace(.625,.725,1000),pathParams);
% plot3(pathvals(1,:),pathvals(2,:),pathvals(3,:),'lineWidth',1.5)
% 
% pathvals=lemOfBooth(linspace(.125,.225,1000),pathParams);
% plot3(pathvals(1,:),pathvals(2,:),pathvals(3,:),'lineWidth',1.5)



tetherLength=pathParams(end);
[x,y,z]=sphere;x=tetherLength*x;y=tetherLength*y;z=tetherLength*z;
h=surfl(x,y,z);set(h,'FaceAlpha',0.5);shading(gca,'interp')
view(90,37)
ylims=ylim;
zlim([0 125])
hold off