function tscExp = processExpData(fileName,varargin)

% parse input
p = inputParser;
addRequired(p,'fileName', @(x) ischar(x));
addParameter(p,'filterWindow',20,@(x) isnumeric(x));
addParameter(p,'expStartTime',0,@(x) isnumeric(x));
addParameter(p,'Ro_c_in_meters',[0;0;0],@(x) isnumeric(x));
addParameter(p,'yawOffset',0,@(x) isnumeric(x));
addParameter(p,'rollOffset',0,@(x) isnumeric(x));

parse(p,fileName,varargin{:});

% load file
load(p.Results.fileName,'tsc');
tscExp = tsc;

% filter bad data in yaw
% filter bad data
badData = find(tscExp.yaw_rad.Data>100);
tscExp.yaw_rad.Data(badData) = 0.5*(tscExp.yaw_rad.Data(badData-1) +...
    tscExp.yaw_rad.Data(badData+1));
tscExp.yaw_rad.Data = tscExp.yaw_rad.Data + p.Results.yawOffset*pi/180;
tscExp.roll_rad.Data = tscExp.roll_rad.Data + p.Results.rollOffset*pi/180;

% apply moving average filter to roll,pitch, and yaw
b = (1/p.Results.filterWindow)*ones(1,p.Results.filterWindow);
% moving aveage filtering
tscExp.yaw_rad.Data = filter(b,1,tscExp.yaw_rad.Data);
tscExp.roll_rad.Data = filter(b,1,tscExp.roll_rad.Data);
tscExp.pitch_rad.Data = filter(b,1,tscExp.pitch_rad.Data);

% center of mass position
cmDat = tscExp.CoMPosVec_cm.Data./100 + p.Results.Ro_c_in_meters(:);
tscExp.CoMPosVec_cm.Data = cmDat;

% adjust motor commands
mtrCmd = squeeze(tscExp.mtrCmds.Data);
mtrCmd = mtrCmd([2 3 1],:);
mtrCmd(mtrCmd>1) = 1;
mtrCmd(mtrCmd<-1) = -1;

tscExp.mtrCmds.Data = mtrCmd;

% calculate velocity
Vx = diff(cmDat(1,:))./0.01;
Vy = diff(cmDat(2,:))./0.01;
Vz = diff(cmDat(3,:))./0.01;

% filter values
Vx_f = filter(b,1,Vx);
Vy_f = filter(b,1,Vy);
Vz_f = filter(b,1,Vz);

tscExp.CoMVelVec_cm =  timeseries([Vx_f;Vy_f;Vz_f],tscExp.roll_rad.Time(1:end-1),'Name','Vcm');

end
