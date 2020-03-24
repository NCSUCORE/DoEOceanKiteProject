%% Create floating platform ground station

% GROUNDSTATION         = 'groundStation001';
% sixDOFDynamics         = 'sixDoFDynamicsEuler';
% gndStn = OCT.sixDoFStation;
% 
% gndStn.cylRad.setValue(4,'m')
% gndStn.angSpac.setValue(pi/4,'rad')
% gndStn.heightSpac.setValue(1/2,'m')
% 
% gndStn.setVolume(pi*gndStn.cylRad.Value^2*1,'m^3');
% gndStn.setMass(gndStn.volume.Value*(1000/2),'kg');
% gndStn.setInertia([.25*gndStn.mass.Value*gndStn.cylRad.Value^2,0,0;...
%    0,.25*gndStn.mass.Value*gndStn.cylRad.Value^2,0;
%    0,0,.5*gndStn.mass.Value*gndStn.cylRad.Value^2],'kg*m^2');
% 
% 
% 
% gndStn.angMatExt.setValue([linspace(0,1.75*pi,8),linspace(0,1.75*pi,8)],'rad');
% gndStn.zMatExt.setValue([-.5*ones(1,8),.5*ones(1,8)],'m');
% gndStn.rMatExt.setValue(repmat(gndStn.cylRad.Value,[1,16]),'m');
% 
% gndStn.angMatT.setValue([linspace(0,1.75*pi,8),0],'rad')
% gndStn.angMatB.setValue([linspace(0,1.75*pi,8),0],'rad')
% 
% gndStn.zMatB.setValue(-.5*ones(1,9),'m')
% gndStn.zMatT.setValue(.5*ones(1,9),'m')
% 
% gndStn.rMatT.setValue([repmat(.5*gndStn.cylRad.Value,[1,8]),0],'m')
% gndStn.rMatB.setValue([repmat(.5*gndStn.cylRad.Value,[1,8]),0],'m')
% 
% gndStn.angMatInt.setValue([linspace(0,1.75*pi,8),linspace(0,1.75*pi,8)],'rad')
% gndStn.zMatInt.setValue([-.25*ones(1,8),.25*ones(1,8)],'m');
% gndStn.rMatInt.setValue(repmat(.5*gndStn.cylRad.Value,[1,16]),'m')
% 
% 
% %number of tethers that go from the GS to the KITE
% gndStn.numTethers.setValue(1,'');
% 
% gndStn.build;
% gndStn.buildCylStation
% gndStn.thrAttch1.posVec.setValue([0 0 0]','m');
% gndStn.bouyancy
% 
% % added mass and drag coefficants of lumped masses
% gndStn.cdX.setValue(1,'')
% gndStn.cdY.setValue(1,'')
% gndStn.cdZ.setValue(1,'')
% gndStn.aMX.setValue(.1,'')
% gndStn.aMY.setValue(.1,'')
% gndStn.aMZ.setValue(.1,'')
% gndStn.addedMass.setValue(zeros(3,3),'')
% gndStn.addedInertia.setValue(zeros(3,3),'')
% 
% gndStn.lumpedMassSphereRadius.setValue(.5,'m');
% 
% 
% % tether attach point for the tether that goes from the GS to the KITE
% % gndStn.addThrAttch('kitThrAttchPt1',[gndStn.cylRad.Value 0 -0.5*gndStn.cylTotH.Value]);
% gndStn.addThrAttch('kitThrAttchPt1',[0 0 0]);
% 
% 
% % tether attach points for the tether that goes from the GS to the GND
% gndStn.addThrAttch('pltThrAttchPt1',[gndStn.cylRad.Value 0 -0.5*gndStn.cylTotH.Value]');
% gndStn.addThrAttch('pltThrAttchPt2',rotation_sequence([0 0  2*pi/3])*gndStn.pltThrAttchPt1.posVec.Value(:));
% gndStn.addThrAttch('pltThrAttchPt3',rotation_sequence([0 0 -2*pi/3])*gndStn.pltThrAttchPt1.posVec.Value(:));
% 
% gndStn.addThrAttch('inrThrAttchPt1',[250 0 0]');
% gndStn.addThrAttch('inrThrAttchPt2',rotation_sequence([0 0  2*pi/3])*gndStn.inrThrAttchPt1.posVec.Value(:));
% gndStn.addThrAttch('inrThrAttchPt3',rotation_sequence([0 0 -2*pi/3])*gndStn.inrThrAttchPt1.posVec.Value(:));
% 
% 
% % gndStn.initAnchTetherLength.setValue(gndStn.calcInitTetherLen,'m')
% gndStn.initAnchTetherLength.setValue([316  316  316 ],'m')
% % Anchor Tethers
% gndStn.anchThrs.setNumNodes(2,'');
% gndStn.anchThrs.setNumTethers(3,'');
% gndStn.anchThrs.build;
% 
% % Tether 1 properties
% gndStn.anchThrs.tether1.diameter.setValue(.05,'m');              % tether diameter
% gndStn.anchThrs.tether1.youngsMod.setValue(50e9,'Pa');          % tether Young's Modulus
% gndStn.anchThrs.tether1.dampingRatio.setValue(.2,'');           % zeta, damping ratio
% gndStn.anchThrs.tether1.dragCoeff.setValue(.5,'');               % drag coefficient for intermediate nodes
% gndStn.anchThrs.tether1.density.setValue(1300,'kg/m^3');         % tether density
% gndStn.anchThrs.tether1.vehicleMass.setValue(gndStn.mass.Value,'kg'); % mass of platform for damping coefficient calculations
% gndStn.anchThrs.tether1.dragEnable.setValue(1,'');
% gndStn.anchThrs.tether1.netBuoyEnable.setValue(1,'');
% 
% 
% % Tether 2 properties
% gndStn.anchThrs.tether2.diameter.setValue(.05,'m');              % tether diameter
% gndStn.anchThrs.tether2.youngsMod.setValue(50e9,'Pa');          % tether Young's Modulus
% gndStn.anchThrs.tether2.dampingRatio.setValue(.2,'');           % zeta, damping ratio
% gndStn.anchThrs.tether2.dragCoeff.setValue(.5,'');               % drag coefficient for intermediate nodes
% gndStn.anchThrs.tether2.density.setValue(1300,'kg/m^3');         % tether density
% gndStn.anchThrs.tether2.vehicleMass.setValue(gndStn.mass.Value,'kg'); % mass of platform for damping coefficient calculations
% gndStn.anchThrs.tether2.dragEnable.setValue(1,'');
% gndStn.anchThrs.tether2.netBuoyEnable.setValue(1,'');
% 
% 
% 
% % Tether 3 properties
% gndStn.anchThrs.tether3.diameter.setValue(.05,'m');              % tether diameter
% gndStn.anchThrs.tether3.youngsMod.setValue(50e9,'Pa');          % tether Young's Modulus
% gndStn.anchThrs.tether3.dampingRatio.setValue(.2,'');           % zeta, damping ratio
% gndStn.anchThrs.tether3.dragCoeff.setValue(.5,'');               % drag coefficient for intermediate nodes
% gndStn.anchThrs.tether3.density.setValue(1300,'kg/m^3');         % tether density
% gndStn.anchThrs.tether3.vehicleMass.setValue(gndStn.mass.Value,'kg'); % mass of platform for damping coefficient calculations
% gndStn.anchThrs.tether3.dragEnable.setValue(1,'');
% gndStn.anchThrs.tether3.netBuoyEnable.setValue(1,'');
% 
% % Save the variable
% saveBuildFile('gndStn',mfilename,'variant','GROUNDSTATION');
%clearvars gndStn ans

% %% Create floating platform ground station
% 
% GROUNDSTATION         = 'groundStation001';
% sixDOFDynamics         = 'sixDoFDynamicsEuler';
% gndStn = OCT.sixDoFStation;
% 
% gndStn.cylRad.setValue(50,'m')
% gndStn.angSpac.setValue(pi/4,'rad')
% gndStn.heightSpac.setValue(16,'m')
% 
% gndStn.setVolume(pi*gndStn.cylRad.Value^2*32,'m^3');
% gndStn.setMass(gndStn.volume.Value*(1000/2),'kg');
% gndStn.setInertia([.25*gndStn.mass.Value*gndStn.cylRad.Value^2,0,0;...
%    0,.25*gndStn.mass.Value*gndStn.cylRad.Value^2,0;
%    0,0,.5*gndStn.mass.Value*gndStn.cylRad.Value^2],'kg*m^2');
% 
% 
% 
% gndStn.angMatExt.setValue([linspace(0,1.75*pi,8),linspace(0,1.75*pi,8)],'rad');
% gndStn.zMatExt.setValue([-16*ones(1,8),16*ones(1,8)],'m');
% gndStn.rMatExt.setValue(repmat(gndStn.cylRad.Value,[1,16]),'m');
% 
% gndStn.angMatT.setValue([linspace(0,1.75*pi,8),0],'rad')
% gndStn.angMatB.setValue([linspace(0,1.75*pi,8),0],'rad')
% 
% gndStn.zMatB.setValue(-16*ones(1,9),'m')
% gndStn.zMatT.setValue(16*ones(1,9),'m')
% 
% gndStn.rMatT.setValue([repmat(.5*gndStn.cylRad.Value,[1,8]),0],'m')
% gndStn.rMatB.setValue([repmat(.5*gndStn.cylRad.Value,[1,8]),0],'m')
% 
% gndStn.angMatInt.setValue([linspace(0,1.75*pi,8),linspace(0,1.75*pi,8)],'rad')
% gndStn.zMatInt.setValue([-8*ones(1,8),8*ones(1,8)],'m');
% gndStn.rMatInt.setValue(repmat(.5*gndStn.cylRad.Value,[1,16]),'m')
% 
% 
% %number of tethers that go from the GS to the KITE
% gndStn.numTethers.setValue(1,'');  
% 
% gndStn.build;
% gndStn.buildCylStation
% gndStn.thrAttch1.posVec.setValue([0 0 0]','m');
% gndStn.bouyancy
% 
% % added mass and drag coefficants of lumped masses
% gndStn.cdX.setValue(1,'')
% gndStn.cdY.setValue(1,'')
% gndStn.cdZ.setValue(1,'')
% gndStn.aMX.setValue(.1,'')
% gndStn.aMY.setValue(.1,'')
% gndStn.aMZ.setValue(.1,'')
% gndStn.addedMass.setValue(zeros(3,3),'')
% gndStn.addedInertia.setValue(zeros(3,3),'')
% 
% gndStn.lumpedMassSphereRadius.setValue(25,'m'); % 1/2 at 1 m height
% 
% 
% % tether attach point for the tether that goes from the GS to the KITE
% % gndStn.addThrAttch('kitThrAttchPt1',[gndStn.cylRad.Value 0 -0.5*gndStn.cylTotH.Value]);
% gndStn.addThrAttch('kitThrAttchPt1',[0 0 0]);
% 
% 
% % tether attach points for the tether that goes from the GS to the GND
% gndStn.addThrAttch('pltThrAttchPt1',[gndStn.cylRad.Value 0 -0.5*gndStn.cylTotH.Value]');
% gndStn.addThrAttch('pltThrAttchPt2',rotation_sequence([0 0  2*pi/3])*gndStn.pltThrAttchPt1.posVec.Value(:));
% gndStn.addThrAttch('pltThrAttchPt3',rotation_sequence([0 0 -2*pi/3])*gndStn.pltThrAttchPt1.posVec.Value(:));
% 
% gndStn.addThrAttch('inrThrAttchPt1',[300 0 0]');
% gndStn.addThrAttch('inrThrAttchPt2',rotation_sequence([0 0  2*pi/3])*gndStn.inrThrAttchPt1.posVec.Value(:));
% gndStn.addThrAttch('inrThrAttchPt3',rotation_sequence([0 0 -2*pi/3])*gndStn.inrThrAttchPt1.posVec.Value(:));
% 
% 
% % gndStn.initAnchTetherLength.setValue(gndStn.calcInitTetherLen,'m')
% gndStn.initAnchTetherLength.setValue([308.4126  308.4126  308.4126],'m')
% 
% 
% 
% % Anchor Tethers
% gndStn.anchThrs.setNumNodes(2,'');
% gndStn.anchThrs.setNumTethers(3,'');
% gndStn.anchThrs.build;
% 
% % Tether 1 properties
% gndStn.anchThrs.tether1.diameter.setValue(.05,'m');              % tether diameter
% gndStn.anchThrs.tether1.youngsMod.setValue(50e9,'Pa');          % tether Young's Modulus
% gndStn.anchThrs.tether1.dampingRatio.setValue(.2,'');           % zeta, damping ratio
% gndStn.anchThrs.tether1.dragCoeff.setValue(.5,'');               % drag coefficient for intermediate nodes
% gndStn.anchThrs.tether1.density.setValue(1300,'kg/m^3');         % tether density
% gndStn.anchThrs.tether1.vehicleMass.setValue(gndStn.mass.Value,'kg'); % mass of platform for damping coefficient calculations
% gndStn.anchThrs.tether1.dragEnable.setValue(1,'');
% gndStn.anchThrs.tether1.netBuoyEnable.setValue(1,'');
% 
% 
% % Tether 2 properties
% gndStn.anchThrs.tether2.diameter.setValue(.05,'m');              % tether diameter
% gndStn.anchThrs.tether2.youngsMod.setValue(50e9,'Pa');          % tether Young's Modulus
% gndStn.anchThrs.tether2.dampingRatio.setValue(.2,'');           % zeta, damping ratio
% gndStn.anchThrs.tether2.dragCoeff.setValue(.5,'');               % drag coefficient for intermediate nodes
% gndStn.anchThrs.tether2.density.setValue(1300,'kg/m^3');         % tether density
% gndStn.anchThrs.tether2.vehicleMass.setValue(gndStn.mass.Value,'kg'); % mass of platform for damping coefficient calculations
% gndStn.anchThrs.tether2.dragEnable.setValue(1,'');
% gndStn.anchThrs.tether2.netBuoyEnable.setValue(1,'');
% 
% 
% 
% % Tether 3 properties
% gndStn.anchThrs.tether3.diameter.setValue(.05,'m');              % tether diameter
% gndStn.anchThrs.tether3.youngsMod.setValue(50e9,'Pa');          % tether Young's Modulus
% gndStn.anchThrs.tether3.dampingRatio.setValue(.2,'');           % zeta, damping ratio
% gndStn.anchThrs.tether3.dragCoeff.setValue(.5,'');               % drag coefficient for intermediate nodes
% gndStn.anchThrs.tether3.density.setValue(1300,'kg/m^3');         % tether density
% gndStn.anchThrs.tether3.vehicleMass.setValue(gndStn.mass.Value,'kg'); % mass of platform for damping coefficient calculations
% gndStn.anchThrs.tether3.dragEnable.setValue(1,'');
% gndStn.anchThrs.tether3.netBuoyEnable.setValue(1,'');
% 
% % Save the variable
% saveBuildFile('gndStn',mfilename,'variant','GROUNDSTATION');
% %clearvars gndStn ans



%% Create floating platform ground station
% 
% GROUNDSTATION         = 'groundStation001';
% sixDOFDynamics         = 'sixDoFDynamicsEuler';
% gndStn = OCT.sixDoFStation;
% 
% gndStn.cylRad.setValue(4,'m')
% gndStn.angSpac.setValue(pi/4,'rad')
% gndStn.heightSpac.setValue(1/2,'m')
% 
% gndStn.setVolume(pi*gndStn.cylRad.Value^2*1,'m^3');
% gndStn.setMass(gndStn.volume.Value*(1000/2),'kg');
% gndStn.setInertia([.25*gndStn.mass.Value*gndStn.cylRad.Value^2,0,0;...
%    0,.25*gndStn.mass.Value*gndStn.cylRad.Value^2,0;
%    0,0,.5*gndStn.mass.Value*gndStn.cylRad.Value^2],'kg*m^2');
% 
% 
% 
% gndStn.angMatExt.setValue([linspace(0,1.75*pi,8),linspace(0,1.75*pi,8)],'rad');
% gndStn.zMatExt.setValue([-.5*ones(1,8),.5*ones(1,8)],'m');
% gndStn.rMatExt.setValue(repmat(gndStn.cylRad.Value,[1,16]),'m');
% 
% gndStn.angMatT.setValue([linspace(0,1.75*pi,8),0],'rad')
% gndStn.angMatB.setValue([linspace(0,1.75*pi,8),0],'rad')
% 
% gndStn.zMatB.setValue(-.5*ones(1,9),'m')
% gndStn.zMatT.setValue(.5*ones(1,9),'m')
% 
% gndStn.rMatT.setValue([repmat(.5*gndStn.cylRad.Value,[1,8]),0],'m')
% gndStn.rMatB.setValue([repmat(.5*gndStn.cylRad.Value,[1,8]),0],'m')
% 
% gndStn.angMatInt.setValue([linspace(0,1.75*pi,8),linspace(0,1.75*pi,8)],'rad')
% gndStn.zMatInt.setValue([-.25*ones(1,8),.25*ones(1,8)],'m');
% gndStn.rMatInt.setValue(repmat(.5*gndStn.cylRad.Value,[1,16]),'m')
% 
% 
% %number of tethers that go from the GS to the KITE
% gndStn.numTethers.setValue(1,'');  
% 
% gndStn.build;
% gndStn.buildCylStation
% gndStn.thrAttch1.posVec.setValue([0 0 0]','m');
% gndStn.bouyancy
% 
% % added mass and drag coefficants of lumped masses
% gndStn.cdX.setValue(1,'')
% gndStn.cdY.setValue(1,'')
% gndStn.cdZ.setValue(1,'')
% gndStn.aMX.setValue(.1,'')
% gndStn.aMY.setValue(.1,'')
% gndStn.aMZ.setValue(.1,'')
% gndStn.addedMass.setValue(zeros(3,3),'')
% gndStn.addedInertia.setValue(zeros(3,3),'')
% 
% gndStn.lumpedMassSphereRadius.setValue(1/2,'m'); % 1/2 at 1 m height
% 
% 
% % tether attach point for the tether that goes from the GS to the KITE
% % gndStn.addThrAttch('kitThrAttchPt1',[gndStn.cylRad.Value 0 -0.5*gndStn.cylTotH.Value]);
% gndStn.addThrAttch('kitThrAttchPt1',[0 0 0]);
% 
% 
% % tether attach points for the tether that goes from the GS to the GND
% gndStn.addThrAttch('pltThrAttchPt1',[gndStn.cylRad.Value 0 -0.5*gndStn.cylTotH.Value]');
% gndStn.addThrAttch('pltThrAttchPt2',rotation_sequence([0 0  2*pi/3])*gndStn.pltThrAttchPt1.posVec.Value(:));
% gndStn.addThrAttch('pltThrAttchPt3',rotation_sequence([0 0 -2*pi/3])*gndStn.pltThrAttchPt1.posVec.Value(:));
% 
% gndStn.addThrAttch('inrThrAttchPt1',[250 0 0]');
% gndStn.addThrAttch('inrThrAttchPt2',rotation_sequence([0 0  2*pi/3])*gndStn.inrThrAttchPt1.posVec.Value(:));
% gndStn.addThrAttch('inrThrAttchPt3',rotation_sequence([0 0 -2*pi/3])*gndStn.inrThrAttchPt1.posVec.Value(:));
% 
% 
% % gndStn.initAnchTetherLength.setValue(gndStn.calcInitTetherLen,'m')
% gndStn.initAnchTetherLength.setValue([316.2274  316.2274  316.2274],'m')
% 
% 
% 
% % Anchor Tethers
% gndStn.anchThrs.setNumNodes(2,'');
% gndStn.anchThrs.setNumTethers(3,'');
% gndStn.anchThrs.build;
% 
% % Tether 1 properties
% gndStn.anchThrs.tether1.diameter.setValue(.05,'m');              % tether diameter
% gndStn.anchThrs.tether1.youngsMod.setValue(50e9,'Pa');          % tether Young's Modulus
% gndStn.anchThrs.tether1.dampingRatio.setValue(.2,'');           % zeta, damping ratio
% gndStn.anchThrs.tether1.dragCoeff.setValue(.5,'');               % drag coefficient for intermediate nodes
% gndStn.anchThrs.tether1.density.setValue(1300,'kg/m^3');         % tether density
% gndStn.anchThrs.tether1.vehicleMass.setValue(gndStn.mass.Value,'kg'); % mass of platform for damping coefficient calculations
% gndStn.anchThrs.tether1.dragEnable.setValue(1,'');
% gndStn.anchThrs.tether1.netBuoyEnable.setValue(1,'');
% 
% 
% % Tether 2 properties
% gndStn.anchThrs.tether2.diameter.setValue(.05,'m');              % tether diameter
% gndStn.anchThrs.tether2.youngsMod.setValue(50e9,'Pa');          % tether Young's Modulus
% gndStn.anchThrs.tether2.dampingRatio.setValue(.2,'');           % zeta, damping ratio
% gndStn.anchThrs.tether2.dragCoeff.setValue(.5,'');               % drag coefficient for intermediate nodes
% gndStn.anchThrs.tether2.density.setValue(1300,'kg/m^3');         % tether density
% gndStn.anchThrs.tether2.vehicleMass.setValue(gndStn.mass.Value,'kg'); % mass of platform for damping coefficient calculations
% gndStn.anchThrs.tether2.dragEnable.setValue(1,'');
% gndStn.anchThrs.tether2.netBuoyEnable.setValue(1,'');
% 
% 
% 
% % Tether 3 properties
% gndStn.anchThrs.tether3.diameter.setValue(.05,'m');              % tether diameter
% gndStn.anchThrs.tether3.youngsMod.setValue(50e9,'Pa');          % tether Young's Modulus
% gndStn.anchThrs.tether3.dampingRatio.setValue(.2,'');           % zeta, damping ratio
% gndStn.anchThrs.tether3.dragCoeff.setValue(.5,'');               % drag coefficient for intermediate nodes
% gndStn.anchThrs.tether3.density.setValue(1300,'kg/m^3');         % tether density
% gndStn.anchThrs.tether3.vehicleMass.setValue(gndStn.mass.Value,'kg'); % mass of platform for damping coefficient calculations
% gndStn.anchThrs.tether3.dragEnable.setValue(1,'');
% gndStn.anchThrs.tether3.netBuoyEnable.setValue(1,'');
% 
% % Save the variable
% saveBuildFile('gndStn',mfilename,'variant','GROUNDSTATION');
% %clearvars gndStn ans



GROUNDSTATION         = 'groundStation001';
sixDOFDynamics         = 'sixDoFDynamicsEuler';
gndStn = OCT.sixDoFStation;

gndStn.cylRad.setValue(9,'m')
gndStn.angSpac.setValue(pi/4,'rad')
gndStn.heightSpac.setValue(1.5,'m')

gndStn.setVolume(pi*gndStn.cylRad.Value^2*6,'m^3');
gndStn.setMass(gndStn.volume.Value*(1000/2),'kg');
gndStn.setInertia([.25*gndStn.mass.Value*gndStn.cylRad.Value^2,0,0;...
   0,.25*gndStn.mass.Value*gndStn.cylRad.Value^2,0;
   0,0,.5*gndStn.mass.Value*gndStn.cylRad.Value^2],'kg*m^2');



gndStn.angMatExt.setValue([linspace(0,1.75*pi,8),linspace(0,1.75*pi,8),linspace(0,1.75*pi,8),linspace(0,1.75*pi,8)],'rad');
gndStn.zMatExt.setValue([-3*ones(1,8),3*ones(1,8),1.5*ones(1,8),-1.5*ones(1,8)],'m');
gndStn.rMatExt.setValue(repmat(gndStn.cylRad.Value,[1,32]),'m');

gndStn.angMatT.setValue([linspace(0,1.75*pi,8),0],'rad')
gndStn.angMatB.setValue([linspace(0,1.75*pi,8),0],'rad')

gndStn.zMatB.setValue(-3*ones(1,9),'m')
gndStn.zMatT.setValue(3*ones(1,9),'m')

gndStn.rMatT.setValue([repmat(.5*gndStn.cylRad.Value,[1,8]),0],'m')
gndStn.rMatB.setValue([repmat(.5*gndStn.cylRad.Value,[1,8]),0],'m')

gndStn.angMatInt.setValue([linspace(0,1.75*pi,8),linspace(0,1.75*pi,8),linspace(0,1.75*pi,8),linspace(0,1.75*pi,8)],'rad')
gndStn.zMatInt.setValue([-1.5*ones(1,8),1.5*ones(1,8),-.75*ones(1,8),.75*ones(1,8)],'m');
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
gndStn.aMX.setValue(.1,'')
gndStn.aMY.setValue(.1,'')
gndStn.aMZ.setValue(.1,'')

gndStn.lumpedMassSphereRadius.setValue(.5*gndStn.heightSpac.Value,'m'); 


% tether attach point for the tether that goes from the GS to the KITE
% gndStn.addThrAttch('kitThrAttchPt1',[gndStn.cylRad.Value 0 -0.5*gndStn.cylTotH.Value]);
gndStn.addThrAttch('kitThrAttchPt1',[0 0 0]);


% tether attach points for the tether that goes from the GS to the GND
gndStn.addThrAttch('pltThrAttchPt1',[gndStn.cylRad.Value 0 -0.5*gndStn.cylTotH.Value]');
gndStn.addThrAttch('pltThrAttchPt2',rotation_sequence([0 0  2*pi/3])*gndStn.pltThrAttchPt1.posVec.Value(:));
gndStn.addThrAttch('pltThrAttchPt3',rotation_sequence([0 0 -2*pi/3])*gndStn.pltThrAttchPt1.posVec.Value(:));

gndStn.addThrAttch('inrThrAttchPt1',[250 0 0]');
gndStn.addThrAttch('inrThrAttchPt2',rotation_sequence([0 0  2*pi/3])*gndStn.inrThrAttchPt1.posVec.Value(:));
gndStn.addThrAttch('inrThrAttchPt3',rotation_sequence([0 0 -2*pi/3])*gndStn.inrThrAttchPt1.posVec.Value(:));

gndStn.setInitPosVecGnd([0 0 200],'m')
% gndStn.calcInitTetherLen 0.9937
gndStn.initAnchTetherLength.setValue(0.9937*gndStn.calcInitTetherLen,'m')



% Anchor Tethers
gndStn.anchThrs.setNumNodes(2,'');
gndStn.anchThrs.setNumTethers(3,'');
gndStn.anchThrs.build;

% Tether 1 properties
gndStn.anchThrs.tether1.diameter.setValue(.05,'m');              % tether diameter
gndStn.anchThrs.tether1.youngsMod.setValue(50e9,'Pa');          % tether Young's Modulus
gndStn.anchThrs.tether1.dampingRatio.setValue(.2,'');           % zeta, damping ratio
gndStn.anchThrs.tether1.dragCoeff.setValue(.5,'');               % drag coefficient for intermediate nodes
gndStn.anchThrs.tether1.density.setValue(1300,'kg/m^3');         % tether density
gndStn.anchThrs.tether1.vehicleMass.setValue(gndStn.mass.Value,'kg'); % mass of platform for damping coefficient calculations
gndStn.anchThrs.tether1.dragEnable.setValue(1,'');
gndStn.anchThrs.tether1.netBuoyEnable.setValue(1,'');


% Tether 2 properties
gndStn.anchThrs.tether2.diameter.setValue(.05,'m');              % tether diameter
gndStn.anchThrs.tether2.youngsMod.setValue(50e9,'Pa');          % tether Young's Modulus
gndStn.anchThrs.tether2.dampingRatio.setValue(.2,'');           % zeta, damping ratio
gndStn.anchThrs.tether2.dragCoeff.setValue(.5,'');               % drag coefficient for intermediate nodes
gndStn.anchThrs.tether2.density.setValue(1300,'kg/m^3');         % tether density
gndStn.anchThrs.tether2.vehicleMass.setValue(gndStn.mass.Value,'kg'); % mass of platform for damping coefficient calculations
gndStn.anchThrs.tether2.dragEnable.setValue(1,'');
gndStn.anchThrs.tether2.netBuoyEnable.setValue(1,'');



% Tether 3 properties
gndStn.anchThrs.tether3.diameter.setValue(.05,'m');              % tether diameter
gndStn.anchThrs.tether3.youngsMod.setValue(50e9,'Pa');          % tether Young's Modulus
gndStn.anchThrs.tether3.dampingRatio.setValue(.2,'');           % zeta, damping ratio
gndStn.anchThrs.tether3.dragCoeff.setValue(.5,'');               % drag coefficient for intermediate nodes
gndStn.anchThrs.tether3.density.setValue(1300,'kg/m^3');         % tether density
gndStn.anchThrs.tether3.vehicleMass.setValue(gndStn.mass.Value,'kg'); % mass of platform for damping coefficient calculations
gndStn.anchThrs.tether3.dragEnable.setValue(1,'');
gndStn.anchThrs.tether3.netBuoyEnable.setValue(1,'');

% Save the variable
saveBuildFile('gndStn',mfilename,'variant','GROUNDSTATION');
%clearvars gndStn ans

