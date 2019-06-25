close all
clear

wnch = OCT.winches;
wnch.numWinches.Value = 1;
wnch.build;

wnch.winch1.initLength.Value = 212;
wnch.winch1.maxSpeed.Value   = 0.4;
wnch.winch1.timeConst.Value  = 1;
wnch.winch1.maxAccel.Value   = inf;

wnch.struct('OCT.winch')