load('2014_new')
%% This is a file to grab a huge chunk of Cnaps Data
%PLEASE DONT EDIT OR DELETE UNTIL AFTER PRESENTATION TUESDAY OCTOBER 8
% I KNOW ITS SUPER JANKY AND IM SORRY - JAMES
timeStart = 1; %hours
timeEnd = 1000; %hours
wayStation = 10;  %way stations 1- 16, see data description in documentation
depthRanges = 1:8; % depth ranges by 25 m for first 9 data points see data description in documentation
U = squeeze(u(timeStart:timeEnd,wayStation ,depthRanges));
V = squeeze(v(timeStart:timeEnd,wayStation ,depthRanges));


figure;
plot(U)
figure;
plot(V)

cnapsMat(:,:,2) = V;
cnapsMat(:,:,1) = U;

save('cnapsMat.mat','cnapsMat','time')