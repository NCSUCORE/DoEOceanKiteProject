%% Create floating platform ground station

GROUNDSTATION         = 'groundStation001';
gndStn = OCT.sixDoFStation;

gndStn.cylRad.setValue(4,'m')
gndStn.angSpac.setValue(pi/4,'rad')
gndStn.heightSpac.setValue(1/2,'m')

gndStn.setVolume(pi*gndStn.cylRad.Value^2*1,'m^3');
gndStn.setMass(gndStn.volume.Value*(1000/2),'kg');
gndStn.setInertiaMatrix([.25*gndStn.mass.Value*gndStn.cylRad.Value^2,0,0;...
   0,.25*gndStn.mass.Value*gndStn.cylRad.Value^2,0;
   0,0,.5*gndStn.mass.Value*gndStn.cylRad.Value^2],'kg*m^2');



gndStn.angMatExt.setValue([linspace(0,1.75*pi,8),linspace(0,1.75*pi,8)],'rad');
gndStn.zMatExt.setValue([-.5*ones(1,8),.5*ones(1,8)],'m');
gndStn.rMatExt.setValue(repmat(gndStn.cylRad.Value,[1,16]),'m');

gndStn.angMatT.setValue([linspace(0,1.75*pi,8),0],'rad')
gndStn.angMatB.setValue([linspace(0,1.75*pi,8),0],'rad')

gndStn.zMatB.setValue(-.5*ones(1,9),'m')
gndStn.zMatT.setValue(.5*ones(1,9),'m')

gndStn.rMatT.setValue([repmat(.5*gndStn.cylRad.Value,[1,8]),0],'m')
gndStn.rMatB.setValue([repmat(.5*gndStn.cylRad.Value,[1,8]),0],'m')

gndStn.angMatInt.setValue([linspace(0,1.75*pi,8),linspace(0,1.75*pi,8)],'rad')
gndStn.zMatInt.setValue([-.25*ones(1,8),.25*ones(1,8)],'m');
gndStn.rMatInt.setValue(repmat(.5*gndStn.cylRad.Value,[1,16]),'m')




gndStn.initAngVel.setValue(0,'rad/s')                                           
gndStn.initVel.setValue(0,'m/s')                                          
gndStn.initAngPos.setValue([0,0,0]','rad')                                        


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


gndStn.lumpedMassSphereRadius.setValue(.5,'m')


% tether attach point for the tether that goes from the GS to the KITE
gndStn.addThrAttch('kitThrAttchPt1',[0 0 0]);



% tether attach points for the tether that goes from the GS to the GND
gndStn.addThrAttch('pltThrAttchPt1',[1 0 0]');
gndStn.addThrAttch('pltThrAttchPt2',rotation_sequence([0 0  2*pi/3])*gndStn.pltThrAttchPt1.posVec.Value(:));
gndStn.addThrAttch('pltThrAttchPt3',rotation_sequence([0 0 -2*pi/3])*gndStn.pltThrAttchPt1.posVec.Value(:));

gndStn.addThrAttch('inrThrAttchPt1',[150 0 0]');
gndStn.addThrAttch('inrThrAttchPt2',rotation_sequence([0 0  2*pi/3])*gndStn.inrThrAttchPt1.posVec.Value(:));
gndStn.addThrAttch('inrThrAttchPt3',rotation_sequence([0 0 -2*pi/3])*gndStn.inrThrAttchPt1.posVec.Value(:));


gndStn.setPosVec([0 0 199.7],'m')

% gndStn.initAnchTetherLength.setValue(gndStn.calcInitTetherLen,'m')
gndStn.initAnchTetherLength.setValue([248.65 248.65 248.65 ],'m')
% Anchor Tethers
gndStn.anchThrs.setNumNodes(2,'');
gndStn.anchThrs.setNumTethers(3,'');
gndStn.anchThrs.build;

% Tether 1 properties
gndStn.anchThrs.tether1.diameter.setValue(.05,'m');              % tether diameter
gndStn.anchThrs.tether1.youngsMod.setValue(5e9,'Pa');          % tether Young's Modulus
gndStn.anchThrs.tether1.dampingRatio.setValue(.2,'');           % zeta, damping ratio
gndStn.anchThrs.tether1.dragCoeff.setValue(.5,'');               % drag coefficient for intermediate nodes
gndStn.anchThrs.tether1.density.setValue(1300,'kg/m^3');         % tether density
gndStn.anchThrs.tether1.vehicleMass.setValue(gndStn.mass.Value,'kg'); % mass of platform for damping coefficient calculations
gndStn.anchThrs.tether1.dragEnable.setValue(1,'');
gndStn.anchThrs.tether1.netBuoyEnable.setValue(1,'');


% Tether 2 properties
gndStn.anchThrs.tether2.diameter.setValue(.05,'m');              % tether diameter
gndStn.anchThrs.tether2.youngsMod.setValue(5e9,'Pa');          % tether Young's Modulus
gndStn.anchThrs.tether2.dampingRatio.setValue(.2,'');           % zeta, damping ratio
gndStn.anchThrs.tether2.dragCoeff.setValue(.5,'');               % drag coefficient for intermediate nodes
gndStn.anchThrs.tether2.density.setValue(1300,'kg/m^3');         % tether density
gndStn.anchThrs.tether2.vehicleMass.setValue(gndStn.mass.Value,'kg'); % mass of platform for damping coefficient calculations
gndStn.anchThrs.tether2.dragEnable.setValue(1,'');
gndStn.anchThrs.tether2.netBuoyEnable.setValue(1,'');



% Tether 3 properties
gndStn.anchThrs.tether3.diameter.setValue(.05,'m');              % tether diameter
gndStn.anchThrs.tether3.youngsMod.setValue(5e9,'Pa');          % tether Young's Modulus
gndStn.anchThrs.tether3.dampingRatio.setValue(.2,'');           % zeta, damping ratio
gndStn.anchThrs.tether3.dragCoeff.setValue(.5,'');               % drag coefficient for intermediate nodes
gndStn.anchThrs.tether3.density.setValue(1300,'kg/m^3');         % tether density
gndStn.anchThrs.tether3.vehicleMass.setValue(gndStn.mass.Value,'kg'); % mass of platform for damping coefficient calculations
gndStn.anchThrs.tether3.dragEnable.setValue(1,'');
gndStn.anchThrs.tether3.netBuoyEnable.setValue(1,'');

% Save the variable
saveBuildFile('gndStn',mfilename,'variant','GROUNDSTATION');
%clearvars gndStn ans
