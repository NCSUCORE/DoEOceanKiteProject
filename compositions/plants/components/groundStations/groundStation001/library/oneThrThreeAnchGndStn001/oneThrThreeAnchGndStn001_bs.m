%% Create floating platform ground station

GROUNDSTATION         = 'groundStation001';
gndStn = OCT.sixDoFStation;
gndStn.setVolume(8,'m^3');
gndStn.setMass(gndStn.volume.Value*(1000/1.5),'kg');
gndStn.setInertiaMatrix((1/6)*gndStn.mass.Value*(8^2).*eye(3),'kg*m^2');
bodyPosMatlumps = 4*[ 1 1  1 0   0 -1 -1 -1 1 1  1 0 0  0 -1 -1 -1 1 1  1 0 0  0 -1 -1 -1 ;
                    1 0 -1 1  -1  1  0 -1 1 0 -1 1 0 -1  1  0 -1 1 0 -1 1 0 -1  1  0 -1;
                    0 0  0 0   0  0  0  0 1 1  1 1 1  1  1  1  1 -1 -1  -1 -1 -1 -1  -1 -1  -1 ;];
gndStn.setLumpedMassPositionMatrixBdy(bodyPosMatlumps,'m')
gndStn.initAngVel.setValue(0,'rad/s')                                           
gndStn.initVel.setValue(0,'m/s')                                          
gndStn.initAngPos.setValue([0,0,0]','rad')                                        
gndStn.initAnchTetherLength.setValue([200,200,200],'m')

%number of tethers that go from the GS to the KITE
gndStn.numTethers.setValue(1,'');
gndStn.build;
gndStn.thrAttch1.posVec.setValue([0 0 0]','m');
gndStn.bouyancy

% added mass and drag coefficants of lumped masses
gndStn.cdX.setValue(1,'')
gndStn.cdY.setValue(1,'')
gndStn.cdZ.setValue(1,'')
gndStn.aMX.setValue(1,'')
gndStn.aMY.setValue(1,'')
gndStn.aMZ.setValue(1,'')

gndStn.areaPerLumpedMass.setValue(384/27,'m^2')
gndStn.lumpedMassSphereRadius.setValue(1,'m')


% tether attach point for the tether that goes from the GS to the KITE
gndStn.addThrAttch('airThrAttchPt1',[0 0 ((gndStn.volume.Value)^(1/3))/2]);



% tether attach points for the tether that goes from the GS to the GND
gndStn.addThrAttch('bdyThrAttchPt1',[0 1 0]');
gndStn.addThrAttch('bdyThrAttchPt2',rotation_sequence([0 0  120])*gndStn.bdyThrAttchPt1.posVec.Value(:));
gndStn.addThrAttch('bdyThrAttchPt3',rotation_sequence([0 0 -120])*gndStn.bdyThrAttchPt1.posVec.Value(:));

gndStn.addThrAttch('gndThrAttchPt1',[200 0 0]');
gndStn.addThrAttch('gndThrAttchPt2',rotation_sequence([0 0  120])*gndStn.gndThrAttchPt1.posVec.Value(:));
gndStn.addThrAttch('gndThrAttchPt3',rotation_sequence([0 0 -120])*gndStn.gndThrAttchPt1.posVec.Value(:));

% Anchor Tethers
gndStn.anchThrs.setNumNodes(2,'');
gndStn.anchThrs.setNumTethers(3,'');
gndStn.anchThrs.build;

% Tether 1 properties
gndStn.anchThrs.tether1.diameter.setValue(.05,'m');              % tether diameter
gndStn.anchThrs.tether1.youngsMod.setValue(50e1,'Pa');          % tether Young's Modulus
gndStn.anchThrs.tether1.dampingRatio.setValue(.05,'');           % zeta, damping ratio
gndStn.anchThrs.tether1.dragCoeff.setValue(.5,'');               % drag coefficient for intermediate nodes
gndStn.anchThrs.tether1.density.setValue(1300,'kg/m^3');         % tether density
gndStn.anchThrs.tether1.vehicleMass.setValue(gndStn.mass.Value,'kg'); % mass of platform for damping coefficient calculations

% Tether 2 properties
gndStn.anchThrs.tether2.diameter.setValue(.05,'m');              % tether diameter
gndStn.anchThrs.tether2.youngsMod.setValue(50e1,'Pa');          % tether Young's Modulus
gndStn.anchThrs.tether2.dampingRatio.setValue(.05,'');           % zeta, damping ratio
gndStn.anchThrs.tether2.dragCoeff.setValue(.5,'');               % drag coefficient for intermediate nodes
gndStn.anchThrs.tether2.density.setValue(1300,'kg/m^3');         % tether density
gndStn.anchThrs.tether2.vehicleMass.setValue(gndStn.mass.Value,'kg'); % mass of platform for damping coefficient calculations

% Tether 3 properties
gndStn.anchThrs.tether3.diameter.setValue(.05,'m');              % tether diameter
gndStn.anchThrs.tether3.youngsMod.setValue(50e1,'Pa');          % tether Young's Modulus
gndStn.anchThrs.tether3.dampingRatio.setValue(.05,'');           % zeta, damping ratio
gndStn.anchThrs.tether3.dragCoeff.setValue(.5,'');               % drag coefficient for intermediate nodes
gndStn.anchThrs.tether3.density.setValue(1300,'kg/m^3');         % tether density
gndStn.anchThrs.tether3.vehicleMass.setValue(gndStn.mass.Value,'kg'); % mass of platform for damping coefficient calculations

% Save the variable
saveBuildFile('gndStn',mfilename,'variant','GROUNDSTATION');
%clearvars gndStn ans
