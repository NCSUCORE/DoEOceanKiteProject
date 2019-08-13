figure
hold on
% pathParams = pathCtrl.pathParams.Value;
pathParams = [pi/4,1.7,.7854,0,tetherLength]; %Lem
% pathParams = [.4,3*pi/8,0,tetherLength];%Circle
pathvals=lemOfBooth(linspace(0,1,1000),pathParams);
tetherLength=pathParams(end);
plot3(pathvals(1,:),pathvals(2,:),pathvals(3,:),'lineWidth',.5)
[x,y,z]=sphere;x=tetherLength*x;y=tetherLength*y;z=tetherLength*z;
h=surfl(x,y,z);set(h,'FaceAlpha',0.5);shading(gca,'interp')
view(90,15)
zlim([0 inf])
hold off