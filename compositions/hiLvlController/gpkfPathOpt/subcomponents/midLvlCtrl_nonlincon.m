function [c,ceq] = midLvlCtrl_nonlincon(dLdT,nPred,dt,LthrMax,LthrMin,...
    Tmax,Tmin,Lthr,elev)

% separate spooling and elevation rates
dL = dLdT(1:nPred);
dT = dLdT(nPred+1:end);
% local variables
LthrTraj = nan(nPred,1);
elevTraj = nan(nPred,1);
% changes in tether length and elevation angle
LthrChanged = dL*dt*60;
elevChanged = dT*dt*60;
% dynamics
LthrTraj(1) = Lthr + LthrChanged(1);
elevTraj(1) = elev + elevChanged(1);
for ii = 2:nPred
    LthrTraj(ii) = LthrTraj(ii-1) + LthrChanged(ii);
    elevTraj(ii) = elevTraj(ii-1) + elevChanged(ii);
end

% upper and lower bounds constraints
LthrLowerThan   =  LthrTraj - LthrMax;
LthrgreaterThan = -LthrTraj + LthrMin;
elevLowerThan   =  elevTraj - Tmax;
elevgreaterThan = -elevTraj + Tmin;

c = [LthrLowerThan;LthrgreaterThan;elevLowerThan;elevgreaterThan];
ceq = [];

end