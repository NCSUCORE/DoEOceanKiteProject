%script for visualizing transect data from shamir


% load transect Data
load('2014_new')

lonRad = deg2rad(lon(1:16));
latRad = deg2rad(lat(1:16));
% 
[X,Y,Z] = sph2cart(lonRad',latRad',1);



% plot sphere
% [x,y,z]=sphere;x=.2*x;y=.2*y;z=.2*z;
% h=surfl(x,y,z);set(h,'FaceAlpha',0.5);shading(gca,'interp')
% hold o
%transect plot
scatter3(X,Y,Z)



% u(time,station,z): u velocity
% v(time,station,z): v velocity

U1 = sqrt(sum([u(100:110,1,2),v(100:110,1,2);]'.^2))'; 
plot(U1)
