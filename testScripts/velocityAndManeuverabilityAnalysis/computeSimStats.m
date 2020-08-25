function val = computeSimStats(obj)

pathParam = squeeze(obj.currentPathVar.Data);
lapsStarted = unique(obj.lapNumS.Data);
plotLap = max(lapsStarted)-1;
%  Determine Single Lap Indices
lapNum = squeeze(obj.lapNumS.Data);
Idx1 = find(lapNum == plotLap,1,'first');
Idx2 = find(lapNum == plotLap,1,'last');
ran = Idx1:Idx2;
% v_Appx
B_vApp = squeeze(obj.vhclVapp.Data);
% tangent pitch and roll
tanPitch = squeeze(obj.tanPitch.Data)*180/pi;
tanRoll = squeeze(obj.tanRoll.Data)*180/pi;
% vhcl speed
vhclSpeed = squeeze(obj.velocityVec.Data);
vhclSpeed = vecnorm(vhclSpeed);
% plot angle of attack
AoA = squeeze(obj.vhclAngleOfAttack.Data);
% lap time
lapTime = squeeze(obj.currentPathVar.Time(ran));
lapTime = lapTime(end)-lapTime(1);
% average apparent velocity in x direction cubed
meanVappxCubed = mean(max(0,B_vApp(1,:)).^3);
% distance traveled
rCM = squeeze(obj.positionVec.Data);
rCM = rCM(:,ran);
disTraveled = sum(vecnorm(rCM(:,2:end) - rCM(:,1:end-1)));
% average vCM
avgVCM = mean(vhclSpeed(ran));
% avereage speed
avgSpeed = disTraveled/lapTime;
% calculate derivative
dv = diff(vhclSpeed(ran));
dTanPitch = diff(tanPitch(ran));
dTanRoll = diff(tanRoll(ran));
dPath = diff(pathParam(ran));
dvdp = dv(:)./dPath(:);
dTpdp = dTanPitch(:)./dPath(:);
dTanRoll = dTanRoll(:)./dPath(:);

garbareRes = any(abs([dvdp dTpdp dTanRoll])>1e3,'all');

tanMax = any(abs(tanPitch(ran))>=20,'all');

val = {'Lap no.','Lap time','Dist. traveled','(V_app,x)^2','Avg. V_cm',...
    'Avg. tan pitch','Avg. AoA','garbage?','tanRoll saturate?','max dv/dp',...
    'max dTPitch/dp','max dTRoll/dp'};
val(2,1:end-3) = {plotLap,lapTime,disTraveled,meanVappxCubed,avgVCM,...
    mean(tanPitch(ran)),mean(AoA(ran)),garbareRes,tanMax};
val(2,end-2:end) = num2cell(max(abs([dvdp dTpdp dTanRoll])));

end
