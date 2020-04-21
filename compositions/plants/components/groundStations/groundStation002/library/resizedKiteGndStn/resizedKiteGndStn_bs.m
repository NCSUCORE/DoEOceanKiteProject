clear
clc
format compact

loadComponent('fullScale1Thr')

m = vhcl.mass.Value;

vhcl.scale(20,1);

gndStn = vhcl;
gndStn.addprop('oceanFloor')
gndStn.oceanFloor = OCT.floor;
gndStn.oceanFloor.setBedrockZ(-0.5,'m');
gndStn.oceanFloor.setOceanFloorZ(0,'m');
gndStn.oceanFloor.setStiffnessZPt(0.01,'m');
gndStn.oceanFloor.setStiffnessFMag(m*9.8,'N');
gndStn.oceanFloor.setFricCoeff(0.5,'');

GROUNDSTATION = 'groundStation002';

%% save file in its respective directory
saveBuildFile('gndStn',mfilename,'variant','GROUNDSTATION');



