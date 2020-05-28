testPosYZ = zeros(100,2);
testPosX = linspace(1,100)';
testPos = [testPosX testPosYZ];
time = linspace(0,200);

ts = timesignal(timeseries(testPos,time));
gndStn.setPosVecTrajectory(ts,'m');
gndStn.velVecTrajectory.Value.plot