% Script to build 3 uniform anchor tethers
anchWnch = OCT.winches;                                     % initiate winch creation
anchWnch.setNumWinches(3,'');% number of winches = number of tethers
anchWnch.build;                                             % builds winches in code

anchWnch.winch1.maxSpeed.setValue(0.4,'m/s');               % set maximum speed
anchWnch.winch1.timeConst.setValue(.1,'s');                 % set time constant
anchWnch.winch1.maxAccel.setValue(.5,'m/s^2')               % set maximum accleration

anchWnch.winch2.maxSpeed.setValue(0.4,'m/s');               % set maximum speed
anchWnch.winch2.timeConst.setValue(.1,'s');                 % set time constant
anchWnch.winch2.maxAccel.setValue(.5,'m/s^2')               % set maximum accleration

anchWnch.winch3.maxSpeed.setValue(0.4,'m/s');               % set maximum speed
anchWnch.winch3.timeConst.setValue(.1,'s');                 % set time constant
anchWnch.winch3.maxAccel.setValue(.5,'m/s^2')               % set maximum accleration


% Save the variable
save(fullfile(fileparts(which(mfilename)),strrep(mfilename,'_bs','')),'anchWnch')
clearvars anchWnch ans
