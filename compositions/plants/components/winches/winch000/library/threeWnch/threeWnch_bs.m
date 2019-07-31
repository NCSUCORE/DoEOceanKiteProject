% Script to build 3 identical winches
wnch = OCT.winches;
wnch.numWinches.setValue(3,'');
wnch.build;

wnch.winch1.maxSpeed.setValue(1,'m/s');
wnch.winch1.timeConst.setValue(0.05,'s');
wnch.winch1.maxAccel.setValue(inf,'m/s^2');
wnch.winch1.initLength.setValue(50.01,'m');

wnch.winch2.maxSpeed.setValue(1,'m/s');
wnch.winch2.timeConst.setValue(0.05,'s');
wnch.winch2.maxAccel.setValue(inf,'m/s^2');
wnch.winch2.initLength.setValue(49.90,'m');

wnch.winch3.maxSpeed.setValue(1,'m/s');
wnch.winch3.timeConst.setValue(0.05,'s');
wnch.winch3.maxAccel.setValue(inf,'m/s^2');
wnch.winch3.initLength.setValue(50.01,'m');

% Save the variable
save(fullfile(fileparts(which(mfilename)),strrep(mfilename,'_bs','')),'wnch')
clearvars wnch ans