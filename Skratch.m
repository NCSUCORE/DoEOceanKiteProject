%         waveNumber
%         frequency
%         amplitude
%         phase



env = ENV.env;

env.addFlow({'waterWave'},{'planarWaves'});
env.waterWave.setNumWaves(3,'');
env.waterWave.build;

env.waterWave.wave1.waveNumber.setValue(1,'rad/m')
env.waterWave.wave1.frequency.setValue(1,'rad/s')
env.waterWave.wave1.amplitude.setValue(1,'m')
env.waterWave.wave1.phase.setValue(1,'rad')

env.waterWave.wave2.waveNumber.setValue(1,'rad/m')
env.waterWave.wave2.frequency.setValue(1,'rad/s')
env.waterWave.wave2.amplitude.setValue(1,'m')
env.waterWave.wave2.phase.setValue(1,'rad')

env.waterWave.wave3.waveNumber.setValue(1,'rad/m')
env.waterWave.wave3.frequency.setValue(1,'rad/s')
env.waterWave.wave3.amplitude.setValue(1,'m')
env.waterWave.wave3.phase.setValue(1,'rad')


