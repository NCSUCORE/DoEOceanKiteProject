clear;clc

loadComponent('pathFollowingVhcl')

fluidDensity = 1000;
ctrlSurfDefl = [-30 30 0 0];
velCMBdy   = [0 0 0];
angVelBdy  = [0 0 0];

data = [];
for ii = 0.1:0.2:10
velWindBdy = [ii 0 0];
sim('fluidDynamicSurface_th')
data = [data;ii,sum(MBdy.Data,2)'];
hold on
end

for ii = 1:3
    subplot(3,1,ii)
    plot(data(:,1),data(:,1+ii))
end