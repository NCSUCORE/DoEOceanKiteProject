function val = computeSimLapStats(obj)

lapsStarted = unique(obj.lapNumS.Data);
plotLap = max(lapsStarted)-1;
%  Determine last lap Indices
lapNum = squeeze(obj.lapNumS.Data);
Idx1 = find(lapNum == plotLap,1,'first');
Idx2 = find(lapNum == plotLap,1,'last');
ran = Idx1:Idx2;

%% compute stats
% lap time
lapTime = squeeze(obj.currentPathVar.Time(ran));
lapTime = lapTime(end)-lapTime(1);

% distance traveled over lap
rCM = squeeze(obj.positionVec.Data);
rCM = rCM(:,ran);
disTraveled = sum(vecnorm(rCM(:,2:end) - rCM(:,1:end-1)));

% turbine power over lap
turbPow = obj.turbPow.Data(:)./1e3;
Avg_Power = mean(turbPow(ran));

% V_a,x^3 by V_w^3 over lap
B_vApp = squeeze(obj.vhclVapp.Data);
flowAtFuse = squeeze(obj.vWindFuseGnd.Data(1,:,:))';
vAppByvFlow = mean((max(0,B_vApp(1,ran))./flowAtFuse(ran)).^3);

% V_k^3 by V_w^3 over lap
vhclSpeed = squeeze(obj.velocityVec.Data);
vhclSpeed = vecnorm(vhclSpeed);
vKiteByvFlow = mean((vhclSpeed(ran)./flowAtFuse(ran)).^3);

% Average speed
avgVCM = mean(vhclSpeed(ran));

% Avg. V_app,x^3
vAppCubed = mean(max(0,B_vApp(1,ran)).^3);

% mean angle of attack
AoA = squeeze(obj.vhclAngleOfAttack.Data);
AoA = mean(AoA(ran));

% max tangent roll
tanRoll = squeeze(obj.tanRoll.Data)*180/pi;
maxTan  = max(abs(tanRoll(ran)));

val = {'Lap no.','Lap time','Dist. traveled','Avg. P','(V_app,x)^3',...
    '(V_app,x/V_w)^3','(V_k/V_w)^3','Avg. V_cm',...
    'Avg. AoA','Max roll'};
val(2,1:end) = {plotLap,lapTime,disTraveled,Avg_Power,vAppCubed,...
    vAppByvFlow,vKiteByvFlow,avgVCM,...
   AoA,maxTan};

end
