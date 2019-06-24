% turbine intialiaztion script

nTurbines = length(turb_struct);

attchPts = zeros(3,nTurbines);
dias = zeros(1,nTurbines);
Cps = zeros(1,nTurbines);
Cds = zeros(1,nTurbines);

for ii = 1:nTurbines
    attchPts(:,ii) = turb_struct(ii).Rturb_cm;
    dias(:,ii) = turb_struct(ii).dia;
    Cps(:,ii) = turb_struct(ii).Cp;
    Cds(:,ii) = turb_struct(ii).Cd;
end

if all(dias == dias(1))~=1 || all(Cps == Cps(1))~=1 || all(Cds == Cds(1))~=1
    warning('The turbines are not identical');
end



    
    