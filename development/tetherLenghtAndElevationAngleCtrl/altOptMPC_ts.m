clear

%% KFGP parameters
kfgptimeStep  = 1;
timeScale     = 22*60;
altScale      = 200;
covAmp        = 1;
xMeasure      = 100:100:1000;
noiseVar      = 0.1;
tempKern      = 'exponential';
powLawParams  = [3.77 0.14];

%% MPC parameters
mpctimeStep = 10;
nPred       = 6;
maxAlt      = 1000;
minAlt      = 100;
zStepMax    = 100;
tradeOffCon = 0;

