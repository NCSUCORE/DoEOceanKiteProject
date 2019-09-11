
%%
simDuration = 400; 
depth = 200 ; %meters
depthArray = 1:200;
rep = 2;
timeVec = linspace(0,simDuration,simDuration);
x = linspace(-pi*rep,pi*rep,simDuration);
onesMat = [ones(1,depth);zeros(1,depth);zeros(1,depth)];
wave = .5*sin(x)+1.5;

tvTemp = [];
for i = 1:simDuration
    
  tvTemp = onesMat * wave(i);
  timeVaryingFlow(:,:,i) = tvTemp;
  
end 
timeVaryingFlowSeries = timeseries(timeVaryingFlow,timeVec); 




%simWithMonitor('flowSpeedCalculation_th')