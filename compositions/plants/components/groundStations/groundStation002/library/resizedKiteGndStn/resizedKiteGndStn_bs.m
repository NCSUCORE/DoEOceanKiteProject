clear
clc
format compact

loadComponent('fullScale1Thr')

vhcl.scale(10,1);

gndStn = vhcl;
gndStn.setBuoyFactor(0.95,'')
gndStn.addprop('oceanFloor')
gndStn.oceanFloor = OCT.floor;
gndStn.oceanFloor.setBedrockZ(-gndStn.fuse.diameter.Value,'m');
gndStn.oceanFloor.setOceanFloorZ(0,'m');
gndStn.oceanFloor.setStiffnessZPt(-0.2,'m');
% Set stiffness coefficient to counteract net vertical force
gndStn.oceanFloor.setStiffnessFMag(-(gndStn.buoyFactor.Value-1)*gndStn.mass.Value*9.8,'N');
gndStn.oceanFloor.setFricCoeff(1,'');

GROUNDSTATION = 'groundStation002';

%% save file in its respective directory
saveBuildFile('gndStn',mfilename,'variant','GROUNDSTATION');



