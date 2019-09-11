%script for visualizing transect data from shamir
%%

%load transect Data
%load('2014_new')
timeSel = 7000;
lonRad = deg2rad(lon(1:16));
latRad = deg2rad(lat(1:16));
radiusE  = 6.371e6; 
[X,Y,Z] = sph2cart(lonRad',latRad',radiusE);
botherJames = 0; 

arcLengths  = sqrt((X(2:end) - X(1:end-1)).^2 +   (Y(2:end) - Y(1:end-1)).^2 + (Z(2:end) - Z(1:end-1)).^2 );
xPosAL =[0, cumsum(arcLengths)];
V = NaN(size(squeeze(u(timeSel,1:16,:))));

for i = 1:16

tempV = sqrt(squeeze(u(timeSel,i,~isnan(u(timeSel,i,:)))).^2 + ...
             squeeze(v(timeSel,i,~isnan(v(timeSel,i,:)))).^2);



V(1:length(tempV),i)=tempV;
maxV(i)=max(tempV);
end

 xq = linspace(0,xPosAL(end),100); 
 vq = interp1(xPosAL,maxV,xq);
 
 
 plot(xq,vq)
 




% u(time,station,z): u velocity
% v(time,station,z): v velocity

% plot(u(3000,1:16,9))
% title('xflow')
% ylabel('flowspeed')
% xlabel('substation')
if botherJames == 1
figure(3)
for i = 1:100:length(time)
    
 contourf(flipud(squeeze(u(i,1:16,1:15))'))
 pause(.1) 
 
 
end 
end 
%distance in m from station 1 = x
%V = station flow speed mag at picked time step

%radius of earth 6.371 million meters

% 
% 
% V = sqrt(sum([u(600,1:16,:),v(600,1:16,:);]'.^2))'; 
% %xq = length of x )
% vq = interp1(x,v,xq