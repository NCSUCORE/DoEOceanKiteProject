figure
hold on
% pathParams = pathCtrl.pathParams.Value;
% pathParams = [.73,1,.37,0,125]; %Lem
pathParams = [.5,pi/8,0,tetherLength];%Circle
% pathParams = [pi/24,3*pi/8,pi/8,0,125];%Racetrack
% pathParams = [3*pi/8,pi/8,pi/8,0,125];%Ellipse
pathvals=circleOnSphere(linspace(0,.125,1000),pathParams);
tetherLength=pathParams(end);
plot3(pathvals(1,:),pathvals(2,:),pathvals(3,:),'lineWidth',.5)
[x,y,z]=sphere;x=tetherLength*x;y=tetherLength*y;z=tetherLength*z;
h=surfl(x,y,z);set(h,'FaceAlpha',0.5);shading(gca,'interp')
view(90,15)
ylims=ylim;
zlim([0 ylims(2)])
hold off