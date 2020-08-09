%%  Manta Ray Vehicle Build Script for 2 Rotors 
clear; clc

VEHICLE               = "vehicleManta2Rot";
PLANT                 = "plantManta2Rot";
SIXDOFDYNAMICS        = "sixDoFDynamicsCoupled";
LIBRARY               = "Manta2RotNACA2412";

%% Essential Values
vhcl = OCT.vehicleM;

vhcl.setFluidDensity(1000,'kg/m^3')
vhcl.setNumTethers(1,'');
vhcl.setBuoyFactor(1.0,''); %Should this be slightly positively buoyant?
vhcl.setFluidCoeffsFileName('Manta04','');

%% Volumes and Inertia
vhcl.setVolume(1.050865,'m^3');
Ixx = 1.7362769e3;
Iyy = 2.9120475e3;
Izz = 4.5431424e3;
Ixy = 2.4783456e-2;
Ixz = 1.0916733e2;
Iyz = 0;

vhcl.setInertia_CM([Ixx -Ixy -Ixz;...
                    -Ixy Iyy -Iyz;...
                    -Ixz -Iyz Izz],'kg*m^2')
                
%% Important Points
vhcl.setRCM_LE([.84;0;.04153],'m')
% vhcl.setRB_LE(vhcl.rCM_LE.Value,'m');
vhcl.setRB_LE([0;0;0],'m');
vhcl.setRBridle_LE(vhcl.rCM_LE.Value + [0;0;0],'m');
vhcl.setRCentOfBuoy_LE([0;0;0],'m');

%% Added Mass/Damping (defaults to zeros)
vhcl.setMa6x6_LE([68.608         0           0           0        5.73           0;...
                       0   814.592           0     -403.87           0     2115.99;...
                       0         0     4743.68           0    -3359.54           0;...
                       0   -403.87           0    22089.56           0    -1509.95;...
                       5.73      0    -3359.54           0     6622.09           0;...
                       0   2115.99           0    -1509.95           0      7641.5;],'');

%% Control Surfaces
vhcl.setAllMaxCtrlDef(30,'deg');
vhcl.setAllMinCtrlDef(-30,'deg');
vhcl.setAllMaxCtrlDefSpeed(67.082,'deg/s');

%% Wing
vhcl.setWingRootChord(.8,'m');
vhcl.setWingAR(100/9,'');
vhcl.setWingTR(0.8,'');
vhcl.setWingSweep(0,'deg');
vhcl.setWingDihedral(0,'deg');
vhcl.setWingIncidence(0,'deg');
vhcl.setWingAirfoil('NACA2412','');
vhcl.setWingClMin(-1.7,'');
vhcl.setWingClMax(1.7,'');

%% H-stab and V-stab
vhcl.hStab.setRSurfLE_WingLEBdy([3.45;0;0],'m');
vhcl.hStab.setNumTraps(2,'');
vhcl.hStab.setRootChord(.52,'m');
vhcl.hStab.setTR(.8,'');
vhcl.hStab.setHalfSpanGivenAR(4/.45,''); %Span 4, hspan 2
vhcl.hStab.setSweep(0,'deg');
vhcl.hStab.setIncidence(1.44,'deg');
vhcl.hStab.setAirfoil('NACA0015','');
vhcl.hStab.setClMin(-1.7,'');
vhcl.hStab.setClMax(1.7,'');

vhcl.vStab.setRSurfLE_WingLEBdy([3.45;0;0],'m');
vhcl.vStab.setRootChord(.52,'m');
vhcl.vStab.setHalfSpan(1.95,'m');
vhcl.vStab.setTR(.8,'');
vhcl.vStab.setSweep(0,'deg');
vhcl.vStab.setAirfoil('NACA0015','');
vhcl.vStab.setClMin(-1.7,'');
vhcl.vStab.setClMax(1.7,'');

%% Fuselage (could use more realistic numbers)
vhcl.fuse.setDiameter(0.3556,'m');
vhcl.fuse.setEndDragCoeff(.1,'');
vhcl.fuse.setSideDragCoeff(1,'');
vhcl.fuse.setRNose_LE([-2.5;0;0],'m');
% vhcl.fuse.setREnd_LE([max(vhcl.hStab.rSurfLE_WingLEBdy.Value(1),vhcl.vStab.rSurfLE_WingLEBdy.Value(1));0;0],'m');
vhcl.fuse.setREnd_LE([max(vhcl.hStab.rSurfLE_WingLEBdy.Value(1)+vhcl.hStab.rootChord.Value,...
                          vhcl.vStab.rSurfLE_WingLEBdy.Value(1)+vhcl.vStab.rootChord.Value);0;0],'m');

%% Turbines
vhcl.setNumTurbines(2,'');
vhcl.build('TurbClass','turb');
% port rotor
vhcl.turb1.setMass(6,'kg')
vhcl.turb1.setDiameter(.56,'m')
vhcl.turb1.setAxisUnitVec([1;0;0],'')
vhcl.turb1.setAttachPtVec(vhcl.portWing.outlinePtsBdy.Value(:,2)*1/2,'m')
vhcl.turb1.setPowerCoeff(.5,'')
vhcl.turb1.setAxalInductionFactor(1.5,'')
vhcl.turb1.setTipSpeedRatio(6,'')
% starboard rotor
vhcl.turb2.setMass(6,'kg')
vhcl.turb2.setDiameter(.56,'m')
vhcl.turb2.setAxisUnitVec([-1;0;0],'')
vhcl.turb2.setAttachPtVec(vhcl.stbdWing.outlinePtsBdy.Value(:,2)*1/2,'m')
vhcl.turb2.setPowerCoeff(.5,'')
vhcl.turb2.setAxalInductionFactor(1.5,'')
vhcl.turb2.setTipSpeedRatio(6,'')

%% load/generate fluid dynamic datan
vhcl.calcFluidDynamicCoefffs
vhcl.plot
%% save file in its respective directory
saveBuildFile('vhcl',mfilename,'variant',["VEHICLE","PLANT","SIXDOFDYNAMICS","LIBRARY"]);



