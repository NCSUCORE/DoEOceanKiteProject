function [tanRoll] = plotExpTanRoll(tsc)
% Create Rotation Matrices
T = tsc.kite_elev.Time;
el = squeeze(tsc.kite_elev.Data);
az = squeeze(tsc.kite_azi.Data);
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

kR = squeeze(tsc.kiteRoll.Data);
kP = squeeze(tsc.kitePitch.Data);
kY = squeeze(tsc.kiteYaw.Data);

for i = 1:numel(kR)
    bdy2Gr(:,:,i) = rotz(kY(i))*roty(kP(i))*rotx(kR(i));
    vec1(:,i) = gnd2tan(:,:,i)'*[0 0 1]';
    vec2(:,i) = bdy2Gr(:,:,i)*[0 1 0]';
end

crossDotSqrt = sqrt(dot(cross(vec2,vec1),cross(vec2,vec1)));
otherOp = dot(vec1,vec2);
tanRoll = -(pi/2-abs(atan2(crossDotSqrt,otherOp)));

figure
plot(T,tanRoll*180/pi)
xlabel('Time [s]')
ylabel('Tangent Roll Angle [deg]')


