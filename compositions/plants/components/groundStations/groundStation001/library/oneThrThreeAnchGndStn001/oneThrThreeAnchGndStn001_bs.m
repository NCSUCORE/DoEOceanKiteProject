GROUNDSTATION         = 'groundStation001';
sixDOFDynamics         = 'sixDoFDynamicsEuler';
gndStn = OCT.sixDoFStation;

height = 4;
gndStn.cylRad.setValue(1.5*height,'m')
gndStn.angSpac.setValue(pi/4,'rad')
gndStn.heightSpac.setValue(height/4,'m')
gndStn.setVolume(pi*gndStn.cylRad.Value^2*height,'m^3');
gndStn.setMass(gndStn.volume.Value*(1000/3),'kg');
gndStn.setInertia([.25*gndStn.mass.Value*gndStn.cylRad.Value^2,0,0;...
    0,.25*gndStn.mass.Value*gndStn.cylRad.Value^2,0;
    0,0,.5*gndStn.mass.Value*gndStn.cylRad.Value^2],'kg*m^2');



gndStn.angMatExt.setValue([linspace(0,1.75*pi,8),linspace(0,1.75*pi,8),linspace(0,1.75*pi,8),linspace(0,1.75*pi,8)],'rad');
gndStn.zMatExt.setValue([-(height/2)*ones(1,8),(height/2)*ones(1,8),(height/4)*ones(1,8),-(height/4)*ones(1,8)],'m');
gndStn.rMatExt.setValue(repmat(gndStn.cylRad.Value,[1,32]),'m');

gndStn.angMatT.setValue([linspace(0,1.75*pi,8),0],'rad')
gndStn.angMatB.setValue([linspace(0,1.75*pi,8),0],'rad')

gndStn.zMatB.setValue(-(height/2)*ones(1,9),'m')
gndStn.zMatT.setValue((height/2)*ones(1,9),'m')

gndStn.rMatT.setValue([repmat(.5*gndStn.cylRad.Value,[1,8]),0],'m')
gndStn.rMatB.setValue([repmat(.5*gndStn.cylRad.Value,[1,8]),0],'m')

gndStn.angMatInt.setValue([linspace(0,1.75*pi,8),linspace(0,1.75*pi,8),linspace(0,1.75*pi,8),linspace(0,1.75*pi,8)],'rad')
gndStn.zMatInt.setValue([-(height/4)*ones(1,8),(height/4)*ones(1,8),-(height/8)*ones(1,8),(height/8)*ones(1,8)],'m');
gndStn.rMatInt.setValue(repmat(.5*gndStn.cylRad.Value,[1,32]),'m')


%number of tethers that go from the GS to the KITE
gndStn.numTethers.setValue(1,'');

gndStn.build;
gndStn.buildCylStation
gndStn.thrAttch1.posVec.setValue([0 0 0]','m');
gndStn.bouyancy

% added mass and drag coefficants of lumped masses
gndStn.cdX.setValue(1,'')
gndStn.cdY.setValue(1,'')
gndStn.cdZ.setValue(1,'')
gndStn.aMX.setValue(.09,'')
gndStn.aMY.setValue(.09,'')
gndStn.aMZ.setValue(.09,'')
gndStn.addedMass.setValue(zeros(3,3),'')
gndStn.addedInertia.setValue(zeros(3,3),'')

gndStn.lumpedMassSphereRadius.setValue(.5*gndStn.heightSpac.Value,'m');


% tether attach point for the tether that goes from the GS to the KITE
% gndStn.addThrAttch('kitThrAttchPt1',[gndStn.cylRad.Value 0 -0.5*gndStn.cylTotH.Value]);
gndStn.addThrAttch('kitThrAttchPt1',[0 0 0]);


% tether attach points for the tether that goes from the GS to the GND
gndStn.addThrAttch('pltThrAttchPt1',[gndStn.cylRad.Value 0 -0.5*gndStn.cylTotH.Value]');
gndStn.addThrAttch('pltThrAttchPt2',rotation_sequence([0 0 pi/3])*gndStn.pltThrAttchPt1.posVec.Value(:));
gndStn.addThrAttch('pltThrAttchPt3',rotation_sequence([0 0 2*pi/3])*gndStn.pltThrAttchPt1.posVec.Value(:));
gndStn.addThrAttch('pltThrAttchPt4',rotation_sequence([0 0 pi])*gndStn.pltThrAttchPt1.posVec.Value(:));
gndStn.addThrAttch('pltThrAttchPt5',rotation_sequence([0 0 4*pi/3])*gndStn.pltThrAttchPt1.posVec.Value(:));
gndStn.addThrAttch('pltThrAttchPt6',rotation_sequence([0 0 5*pi/3])*gndStn.pltThrAttchPt1.posVec.Value(:));

gndStn.addThrAttch('inrThrAttchPt1',[200 0 0]');
gndStn.addThrAttch('inrThrAttchPt2',rotation_sequence([0 0  pi/3])*gndStn.inrThrAttchPt1.posVec.Value(:));
gndStn.addThrAttch('inrThrAttchPt3',rotation_sequence([0 0 2*pi/3])*gndStn.inrThrAttchPt1.posVec.Value(:));
gndStn.addThrAttch('inrThrAttchPt4',rotation_sequence([0 0 pi])*gndStn.inrThrAttchPt1.posVec.Value(:));
gndStn.addThrAttch('inrThrAttchPt5',rotation_sequence([0 0 4*pi/3])*gndStn.inrThrAttchPt1.posVec.Value(:));
gndStn.addThrAttch('inrThrAttchPt6',rotation_sequence([0 0 5*pi/3])*gndStn.inrThrAttchPt1.posVec.Value(:));

gndStn.setInitPosVecGnd([0 0 200],'m')
% gndStn.calcInitTetherLen 0.9937
% gndStn.initAnchTetherLength.setValue(.9937*gndStn.calcInitTetherLen,'m')
gndStn.initAnchTetherLength.setValue(.995*gndStn.calcInitTetherLen,'m')


% Anchor Tethers
gndStn.anchThrs.setNumNodes(2,'');
gndStn.anchThrs.setNumTethers(6,'');
gndStn.anchThrs.build;

% Tether 1 properties
gndStn.anchThrs.tether1.diameter.setValue(.14,'m');              % tether diameter
gndStn.anchThrs.tether1.youngsMod.setValue(27e9,'Pa');          % tether Young's Modulus
gndStn.anchThrs.tether1.dampingRatio.setValue(.01,'');           % zeta, damping ratio
gndStn.anchThrs.tether1.dragCoeff.setValue(.5,'');               % drag coefficient for intermediate nodes
gndStn.anchThrs.tether1.density.setValue(1000,'kg/m^3');         % tether density
gndStn.anchThrs.tether1.vehicleMass.setValue(gndStn.mass.Value,'kg'); % mass of platform for damping coefficient calculations
gndStn.anchThrs.tether1.dragEnable.setValue(1,'');
gndStn.anchThrs.tether1.netBuoyEnable.setValue(1,'');


% Tether 2 properties
gndStn.anchThrs.tether2.diameter.setValue(.14,'m');              % tether diameter
gndStn.anchThrs.tether2.youngsMod.setValue(27e9,'Pa');          % tether Young's Modulus
gndStn.anchThrs.tether2.dampingRatio.setValue(.01,'');           % zeta, damping ratio
gndStn.anchThrs.tether2.dragCoeff.setValue(.5,'');               % drag coefficient for intermediate nodes
gndStn.anchThrs.tether2.density.setValue(1000,'kg/m^3');         % tether density
gndStn.anchThrs.tether2.vehicleMass.setValue(gndStn.mass.Value,'kg'); % mass of platform for damping coefficient calculations
gndStn.anchThrs.tether2.dragEnable.setValue(1,'');
gndStn.anchThrs.tether2.netBuoyEnable.setValue(1,'');



% Tether 3 properties
gndStn.anchThrs.tether3.diameter.setValue(.14,'m');              % tether diameter
gndStn.anchThrs.tether3.youngsMod.setValue(27e9,'Pa');          % tether Young's Modulus
gndStn.anchThrs.tether3.dampingRatio.setValue(.01,'');           % zeta, damping ratio
gndStn.anchThrs.tether3.dragCoeff.setValue(.5,'');               % drag coefficient for intermediate nodes
gndStn.anchThrs.tether3.density.setValue(1000,'kg/m^3');         % tether density
gndStn.anchThrs.tether3.vehicleMass.setValue(gndStn.mass.Value,'kg'); % mass of platform for damping coefficient calculations
gndStn.anchThrs.tether3.dragEnable.setValue(1,'');
gndStn.anchThrs.tether3.netBuoyEnable.setValue(1,'');




% Tether 4 properties
gndStn.anchThrs.tether4.diameter.setValue(.14,'m');              % tether diameter
gndStn.anchThrs.tether4.youngsMod.setValue(27e9,'Pa');          % tether Young's Modulus
gndStn.anchThrs.tether4.dampingRatio.setValue(.01,'');           % zeta, damping ratio
gndStn.anchThrs.tether4.dragCoeff.setValue(.5,'');               % drag coefficient for intermediate nodes
gndStn.anchThrs.tether4.density.setValue(1000,'kg/m^3');         % tether density
gndStn.anchThrs.tether4.vehicleMass.setValue(gndStn.mass.Value,'kg'); % mass of platform for damping coefficient calculations
gndStn.anchThrs.tether4.dragEnable.setValue(1,'');
gndStn.anchThrs.tether4.netBuoyEnable.setValue(1,'');





% Tether 5 properties
gndStn.anchThrs.tether5.diameter.setValue(.14,'m');              % tether diameter
gndStn.anchThrs.tether5.youngsMod.setValue(27e9,'Pa');          % tether Young's Modulus
gndStn.anchThrs.tether5.dampingRatio.setValue(.01,'');           % zeta, damping ratio
gndStn.anchThrs.tether5.dragCoeff.setValue(.5,'');               % drag coefficient for intermediate nodes
gndStn.anchThrs.tether5.density.setValue(1000,'kg/m^3');         % tether density
gndStn.anchThrs.tether5.vehicleMass.setValue(gndStn.mass.Value,'kg'); % mass of platform for damping coefficient calculations
gndStn.anchThrs.tether5.dragEnable.setValue(1,'');
gndStn.anchThrs.tether5.netBuoyEnable.setValue(1,'');




% Tether 6 properties
gndStn.anchThrs.tether6.diameter.setValue(.14,'m');              % tether diameter
gndStn.anchThrs.tether6.youngsMod.setValue(27e9,'Pa');          % tether Young's Modulus
gndStn.anchThrs.tether6.dampingRatio.setValue(.01,'');           % zeta, damping ratio
gndStn.anchThrs.tether6.dragCoeff.setValue(.5,'');               % drag coefficient for intermediate nodes
gndStn.anchThrs.tether6.density.setValue(1000,'kg/m^3');         % tether density
gndStn.anchThrs.tether6.vehicleMass.setValue(gndStn.mass.Value,'kg'); % mass of platform for damping coefficient calculations
gndStn.anchThrs.tether6.dragEnable.setValue(1,'');
gndStn.anchThrs.tether6.netBuoyEnable.setValue(1,'');


% Save the variable
saveBuildFile('gndStn','oneThrThreeAnchGndStn001_bs','variant','GROUNDSTATION');
