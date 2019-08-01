clear
clc
format compact

% this is the build script for creating winches using class definition
% 'winches' for a three tethered system that is being used by ayaz

% the script saves the variable 'wnch' to a 'ayazThreeTetWnch.mat'

%% Winches
% Create
wnch = OCT.winches;
wnch.numWinches.setValue(3,'');
wnch.build;

% Set values
wnch.winch1.maxSpeed.setValue(1,'m/s');
wnch.winch1.timeConst.setValue(0.05,'s');
wnch.winch1.maxAccel.setValue(inf,'m/s^2');

wnch.winch2.maxSpeed.setValue(1,'m/s');
wnch.winch2.timeConst.setValue(0.05,'s');
wnch.winch2.maxAccel.setValue(inf,'m/s^2');

wnch.winch3.maxSpeed.setValue(1,'m/s');
wnch.winch3.timeConst.setValue(0.05,'s');
wnch.winch3.maxAccel.setValue(inf,'m/s^2');


% check if all the initial conditions are empty
testEmpty = NaN(1,3);
for ii = 1:3
    testEmpty(1,ii) = isempty(wnch.(strcat('winch',num2str(ii))).initLength.Value);
    
end

%% save file in its respective directory
currentMfileLoc = fileparts(mfilename('fullpath'));

if all(testEmpty,'all')
    save(strcat(currentMfileLoc,'\ayazThreeTetWnch.mat'),'wnch');
else
    error('Please do not specify initial conditions in build script')
end