function [sp,tanRoll,velAng] = eqSpeed(obj,vf,az,el)
%EQSPEED Summary of this function goes here
%   Detailed explanation goes here
tanRolls = linspace(-90,90,1000)*pi/180;
velAngs  = tanRolls;

CL = obj.portWing.CL.Value + obj.stbdWing.CL.Value + obj.hStab.CL.Value;
CD = obj.portWing.CD.Value + obj.stbdWing.CD.Value + obj.hStab.CD.Value + interp1(obj.vStab.alpha.Value,obj.vStab.CD.Value,0);
CLCD = CL./CD;
[CLCDMax,maxInd] = max(CLCD);
alphaOpt = obj.portWing.alpha.Value(maxInd);
CLOpt = CL(maxInd);
CDOpt = CD(maxInd);


velAng
latUnitVec = [-sin(az) cos(az) 0];
posUnitVec = [cos(az)*cos(el) sin(az)*cos(el) sin(el)];

vUVec = rodriguesRotation(latUnitVec,posUnitVec,(pi/2)-velAng);



end


function J = cost(spd,vUVec,posVec,CL,CD)


end

