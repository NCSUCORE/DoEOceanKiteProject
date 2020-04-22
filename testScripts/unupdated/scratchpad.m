close all
gndStn.oceanFloor.setOceanFloorZ(1,'m')
z = linspace(-gndStn.fuse.diameter.Value/2,gndStn.fuse.diameter.Value,1000);
Fn = gndStn.oceanFloor.calcNormForceMag(z);
plot(z,Fn)

gndStn.oceanFloor.calcNormForceMag(gndStn.oceanFloor.stiffnessZPt.Value) ...
    - gndStn.oceanFloor.stiffnessFMag.Value