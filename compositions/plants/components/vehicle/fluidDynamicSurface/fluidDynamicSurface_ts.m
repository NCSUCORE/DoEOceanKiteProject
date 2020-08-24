clear;clc

loadComponent('ayazFullScaleOneThrVhcl')

fluidDensity = 1000;
cSMax = 30;
csMin = -30;
velCMBdy   = [1 0 0];
angVelBdy  = [0 0 0];

data = [];
for ii = 0.1:0.2:10
velWindBdy = repmat([ii; 0; 0],1,4);
ctrlSurfDefl = (csMin-cSMax).*rand(4,1) + cSMax;
sim('fluidDynamicSurface_th')
data = [data;ii,sum(MBdy.Data,2)'];
hold on
keyboard
end

for ii = 1:3
    subplot(3,1,ii)
    plot(data(:,1),data(:,1+ii))
end