load('2014_new')

timeStart = 1; %hours
timeEnd = 1000; %hours
wayStation = 10;  %way stations 1- 16, see data description in documentation
depthRanges = 1:8; % depth ranges by 25 m for first 9 data points see data description in documentation
U = squeeze(u(timeStart:timeEnd,wayStation ,depthRanges));
V = squeeze(v(timeStart:timeEnd,wayStation ,depthRanges));


% figure;
% plot(U)
% figure;
% plot(V)

cnapsMat(:,:,2) = V;
cnapsMat(:,:,1) = U;

% save('cnapsMat.mat','cnapsMat','time')
timeVec   =(time(1:1000)-735600)*3600*60;
data = cnapsMat;
data = permute(data,[3 2 1]);
flowTimeseries = timeseries(data,timeVec);
sZ = size(flowTimeseries.data);
for ii = 1:sZ
    magDepthT = sqrt(sum(flowTimeseries.data(:,1,:).^2,1));
     
    %magnitude of xyz at each depth per time
    magDepth = [magDepth,magDepthT];
end