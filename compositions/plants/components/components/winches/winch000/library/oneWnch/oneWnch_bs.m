% Script to build 1 identical winches
wnch = OCT.winches;
wnch.numWinches.setValue(1,'');
wnch.build;

wnch.winch1.maxSpeed.setValue(1,'m/s');
wnch.winch1.timeConst.setValue(0.05,'s');
wnch.winch1.maxAccel.setValue(inf,'m/s^2');
wnch.winch1.initLength.setValue(50.01,'m');

% Save the variable
save(fullfile(fileparts(which(mfilename)),strrep(mfilename,'_bs','')),'wnch')
clearvars wnch ans