close all
clear
clc
gndStn = OCT.sixDoFStation;

gndStn.setVolume(3.5,'m^3');
gndStn.setMass(1000*gndStn.volume.Value,'kg');
gndStn.setInertiaMatrix(((1/6)*gndStn.mass.Value*gndStn.volume.Value^(2/3)).*eye(3),'kg*m^2');
gndStn.setCentOfBuoy([0 0 0]','m');
gndStn.setThrAttchPt1([5 0 0]','m');
gndStn.setThrAttchPt2(rotation_sequence([0 0  120]*pi/180)*gndStn.thrAttchPt1.Value,'m');
gndStn.setThrAttchPt3(rotation_sequence([0 0 -120]*pi/180)*gndStn.thrAttchPt1.Value,'m');
gndStn.setInitPos([0 0 0]','m');
gndStn.setInitVel([0 0 0],'m/s');
gndStn.setInitEulAng([0 0 0],'rad');
gndStn.setInitAngVel([0 0 0],'rad/s');

gndStn.anchThrs.setNumTethers(3,'');
gndStn.anchThrs.setNumNodes(4,'');
gndStn.anchThrs.build;

gndStn.anchThrs.tether1.setInitGndNodePos([100 0 0]','m');
gndStn.anchThrs.tether1.setInitAirNodePos(gndStn.initPos.Value+gndStn.thrAttchPt1.Value,'m');
gndStn.anchThrs.tether1.setInitGndNodeVel([0 0 0],'m/s');
gndStn.anchThrs.tether1.setInitAirNodeVel([0 0 0],'m/s');
gndStn.anchThrs.tether1.setDiameter(0.015,'m');
gndStn.anchThrs.tether1.setYoungsMod(20e9,'Pa');
gndStn.anchThrs.tether1.setDampingRatio(0.5,'');
gndStn.anchThrs.tether1.setDragCoeff(0.5,'');
gndStn.anchThrs.tether1.setDensity(1300,'kg/m^3');
gndStn.anchThrs.tether1.setVehicleMass(6000,'kg');
gndStn.anchThrs.tether1.setDragEnable(true,'');
gndStn.anchThrs.tether1.setSpringDamperEnable(true,'');
gndStn.anchThrs.tether1.setNetBuoyEnable(true,'');

gndStn.anchThrs.tether2.setInitGndNodePos(rotation_sequence([0 0  120]*pi/180)*gndStn.anchThrs.tether1.initGndNodePos.Value(:),'m');
gndStn.anchThrs.tether2.setInitAirNodePos(gndStn.initPos.Value+gndStn.thrAttchPt2.Value,'m');
gndStn.anchThrs.tether2.setInitGndNodeVel([0 0 0],'m/s');
gndStn.anchThrs.tether2.setInitAirNodeVel([0 0 0],'m/s');
gndStn.anchThrs.tether2.setDiameter(0.015,'m');
gndStn.anchThrs.tether2.setYoungsMod(20e9,'Pa');
gndStn.anchThrs.tether2.setDampingRatio(0.5,'');
gndStn.anchThrs.tether2.setDragCoeff(0.5,'');
gndStn.anchThrs.tether2.setDensity(1300,'kg/m^3');
gndStn.anchThrs.tether2.setVehicleMass(6000,'kg');
gndStn.anchThrs.tether2.setDragEnable(true,'');
gndStn.anchThrs.tether2.setSpringDamperEnable(true,'');
gndStn.anchThrs.tether2.setNetBuoyEnable(true,'');

gndStn.anchThrs.tether3.setInitGndNodePos(rotation_sequence([0 0  -120]*pi/180)*gndStn.anchThrs.tether1.initGndNodePos.Value(:),'m');
gndStn.anchThrs.tether3.setInitAirNodePos(gndStn.initPos.Value+gndStn.thrAttchPt3.Value,'m');
gndStn.anchThrs.tether3.setInitGndNodeVel([0 0 0],'m/s');
gndStn.anchThrs.tether3.setInitAirNodeVel([0 0 0],'m/s');
gndStn.anchThrs.tether3.setDiameter(0.015,'m');
gndStn.anchThrs.tether3.setYoungsMod(20e9,'Pa');
gndStn.anchThrs.tether3.setDampingRatio(0.5,'');
gndStn.anchThrs.tether3.setDragCoeff(0.5,'');
gndStn.anchThrs.tether3.setDensity(1300,'kg/m^3');
gndStn.anchThrs.tether3.setVehicleMass(6000,'kg');
gndStn.anchThrs.tether3.setDragEnable(true,'');
gndStn.anchThrs.tether3.setSpringDamperEnable(true,'');
gndStn.anchThrs.tether3.setNetBuoyEnable(true,'');