load('deploy4_adcp.mat')
figure;
contourf(459:461,z,east_vel(:,459:461))
figure;
% contourf(451:454,z,north_vel(:,458:461))
% figure;
% contourf(1:1000,z,north_vel(:,1:1000))
% 
% 
% figure;
% contourf(1:100,obj.depthArray.Value,squeeze(bobo(:,1,1:100)))