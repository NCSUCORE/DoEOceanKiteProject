
function J = cpEst(turb,a)
a = [a; 1];
gam = turb.RPMref.Value;
CpDes = turb.CpLookup.Value;

indFact = polyval(a,gam);
CP = 4*indFact.*(1-indFact).^2;

g(1)
