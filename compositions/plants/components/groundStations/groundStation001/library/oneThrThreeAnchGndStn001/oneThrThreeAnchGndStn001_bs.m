%% Create floating platform ground station
gndStn = OCT.sixDoFStation;
gndStn.setVolume(3.5,'m^3');
gndStn.setMass(gndStn.volume.Value*(1000/1.5),'kg');
gndStn.setInertiaMatrix(((1/6)*gndStn.mass.Value*gndStn.volume.Value^(2/3)).*eye(3),'kg*m^2');
gndStn.setCentOfBuoy([0 0 gndStn.volume.Value^(1/3)/2],'m');
gndStn.setDragCoefficient(0.8,'');
bodyPosMatlumpy = [ 1 1  1 0 0  0 -1 -1 -1 1 1  1 0 0  0 -1 -1 -1 1 1  1 0 0  0 -1 -1 -1 ;
                    1 0 -1 1 0 -1  1  0 -1 1 0 -1 1 0 -1  1  0 -1 1 0 -1 1 0 -1  1  0 -1;
                    0 0  0 0 0  0  0  0  0 1 1  1 1 1  1  1  1  1 -1 -1  -1 -1 -1 -1  -1 -1  -1 ;];
gndStn.setLumpedMassPositionMatrixBdy(bodyPosMatlumpy,'m')
                                           
                                        
                                       

gndStn.addThrAttch('airThrAttchPt1',[0 0 ((gndStn.volume.Value)^(1/3))/2]);
gndStn.addThrAttch('airThrAttchPt2',[0 0 ((gndStn.volume.Value)^(1/3))/2]);
gndStn.addThrAttch('airThrAttchPt3',[0 0 ((gndStn.volume.Value)^(1/3))/2]);

gndStn.addThrAttch('bdyThrAttchPt1',[0 1 0]');
gndStn.addThrAttch('bdyThrAttchPt2',rotation_sequence([0 0  120])*gndStn.bdyThrAttchPt1.posVec.Value(:));
gndStn.addThrAttch('bdyThrAttchPt3',rotation_sequence([0 0 -120])*gndStn.bdyThrAttchPt1.posVec.Value(:));

gndStn.addThrAttch('gndThrAttchPt1',[100 0 0]');
gndStn.addThrAttch('gndThrAttchPt2',rotation_sequence([0 0  120])*gndStn.gndThrAttchPt1.posVec.Value(:));
gndStn.addThrAttch('gndThrAttchPt3',rotation_sequence([0 0 -120])*gndStn.gndThrAttchPt1.posVec.Value(:));

% Anchor Tethers
% gndStn.anchThrs.setNumNodes(2,'');
gndStn.anchThrs.setNumTethers(3,'');
gndStn.anchThrs.build;

% Tether 1 properties
gndStn.anchThrs.tether1.diameter.setValue(.05,'m');              % tether diameter
gndStn.anchThrs.tether1.youngsMod.setValue(3.8e9,'Pa');          % tether Young's Modulus
gndStn.anchThrs.tether1.dampingRatio.setValue(.05,'');           % zeta, damping ratio
gndStn.anchThrs.tether1.dragCoeff.setValue(.5,'');               % drag coefficient for intermediate nodes
gndStn.anchThrs.tether1.density.setValue(1300,'kg/m^3');         % tether density
gndStn.anchThrs.tether1.vehicleMass.setValue(gndStn.mass.Value,'kg'); % mass of platform for damping coefficient calculations

% Tether 2 properties
gndStn.anchThrs.tether2.diameter.setValue(.05,'m');              % tether diameter
gndStn.anchThrs.tether2.youngsMod.setValue(3.8e9,'Pa');          % tether Young's Modulus
gndStn.anchThrs.tether2.dampingRatio.setValue(.05,'');           % zeta, damping ratio
gndStn.anchThrs.tether2.dragCoeff.setValue(.5,'');               % drag coefficient for intermediate nodes
gndStn.anchThrs.tether2.density.setValue(1300,'kg/m^3');         % tether density
gndStn.anchThrs.tether2.vehicleMass.setValue(gndStn.mass.Value,'kg'); % mass of platform for damping coefficient calculations

% Tether 3 properties
gndStn.anchThrs.tether3.diameter.setValue(.05,'m');              % tether diameter
gndStn.anchThrs.tether3.youngsMod.setValue(3.8e9,'Pa');          % tether Young's Modulus
gndStn.anchThrs.tether3.dampingRatio.setValue(.05,'');           % zeta, damping ratio
gndStn.anchThrs.tether3.dragCoeff.setValue(.5,'');               % drag coefficient for intermediate nodes
gndStn.anchThrs.tether3.density.setValue(1300,'kg/m^3');         % tether density
gndStn.anchThrs.tether3.vehicleMass.setValue(gndStn.mass.Value,'kg'); % mass of platform for damping coefficient calculations

% Save the variable
save(fullfile(fileparts(which(mfilename)),strrep(mfilename,'_bs','')),'gndStn')
%clearvars gndStn ans
