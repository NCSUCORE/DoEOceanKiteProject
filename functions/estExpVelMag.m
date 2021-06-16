function [velMag,velAug] = estExpVelMag(tsc,cutOffFreq)
%Grab Time and Position Angles from Time Series
T = tsc.kite_azi.Time;
sampPeriod = T(2)-T(1);
el = squeeze(tsc.kite_elev.Data);
az = squeeze(tsc.kite_azi.Data);
towSpeed = tsc.winch1rpm.Data(100)*.0098

%Estimate Position based on straight tether approximation
pos = 2.63*[-cosd(az).*cosd(el)+towSpeed/2.63*T...
    sind(az).*cosd(el)...
    sind(el)];

%Filter position data and calculate filtered velocity
tauRate = 1/(cutOffFreq*2*pi);
lowFiltRate = tf(1,[tauRate 1]);

pos(:,1) = lsim(lowFiltRate,pos(:,1),T);
pos(:,2) = lsim(lowFiltRate,pos(:,2),T);
pos(:,3) = lsim(lowFiltRate,pos(:,3),T);

vel = diff(pos)./sampPeriod;
%Calculate velocity magnitude
velMag = sqrt(dot(vel',vel'));
velAug = velMag/towSpeed;