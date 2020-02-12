%         waveNumber
%         frequency
%         amplitude
%         phase



% env = ENV.env;
% 
% env.addFlow({'waterWave'},{'planarWaves'});
% env.waterWave.setNumWaves(3,'');
% env.waterWave.build;
% 
% env.waterWave.wave1.waveNumber.setValue(1,'rad/m')
% env.waterWave.wave1.frequency.setValue(1,'rad/s')
% env.waterWave.wave1.amplitude.setValue(1,'m')
% env.waterWave.wave1.phase.setValue(1,'rad')
% 
% env.waterWave.wave2.waveNumber.setValue(1,'rad/m')
% env.waterWave.wave2.frequency.setValue(1,'rad/s')
% env.waterWave.wave2.amplitude.setValue(1,'m')
% env.waterWave.wave2.phase.setValue(1,'rad')
% 
% env.waterWave.wave3.waveNumber.setValue(1,'rad/m')
% env.waterWave.wave3.frequency.setValue(1,'rad/s')
% env.waterWave.wave3.amplitude.setValue(1,'m')
% env.waterWave.wave3.phase.setValue(1,'rad')

 
param = env.waterWave.waveParamMat.Value;
oceanHeight = env.water.zGridPoints.Value(end);
pos = [0 0 200]';
t = 1;

% change your current position to be measure from the surf
pos = pos - [0,0,oceanHeight]';

% calculate ocean height at yout position
waveAmplitude = sum(param(:,3).*cos(param(:,1).*pos(1) - param(:,2)*t + param(:,4)),1);

% calculate the wave velocity at your location
xVel  = sum(param(:,2).*param(:,3).*exp(param(:,1)*pos(3)).*cos(param(:,1)*pos(1) - param(:,2)*t + param(:,4)),1);
zVel  = sum(param(:,2).*param(:,3).*exp(param(:,1)*pos(3)).*sin(param(:,1)*pos(1) - param(:,2)*t + param(:,4)),1);

% there is no y component of wave velocity in this formulation

velVecGnd = [xVel;0;zVel];