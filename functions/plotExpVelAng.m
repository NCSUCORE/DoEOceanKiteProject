function [velAngle] = plotExpVelAng(tsc,towSpeed,cutoffFreq)
T = tsc.kite_azi.Time;
el = squeeze(tsc.kite_elev.Data);
az = squeeze(tsc.kite_azi.Data);

pos = 2.63*[-cosd(az).*cosd(el)+towSpeed/2.63*T...
    sind(az).*cosd(el)...
    sind(el)];

sl = sind(az)';
cl = cosd(az)';
sp = sind(el)';
cp = cosd(el)';
gnd2tan(1,1,:) = -sp.*cl;
gnd2tan(1,2,:) = -sl;
gnd2tan(1,3,:) = -cl.*cp;
gnd2tan(2,1,:) = -sp.*sl;
gnd2tan(2,2,:) = cl;
gnd2tan(2,3,:) = -sl.*cp;
gnd2tan(3,1,:) = cp;
gnd2tan(3,2,:) = zeros(size(sp));
gnd2tan(3,3,:) = sp;

%Data Filtering
tauRate = 1/(cutoffFreq*2*pi);
lowFiltRate = tf(1,[tauRate 1]);

pos(:,1) = lsim(lowFiltRate,pos(:,1),T);
pos(:,2) = lsim(lowFiltRate,pos(:,2),T);
pos(:,3) = lsim(lowFiltRate,pos(:,3),T);

vel = diff(pos)./.01;

for i = 1:numel(sl)-1
    velTan(:,i) = (gnd2tan(:,:,i)*vel(i,:)')';
end
velAngle = atan2(velTan(2,:),velTan(1,:));
velAngle = mod(velAngle,2*pi)-pi;