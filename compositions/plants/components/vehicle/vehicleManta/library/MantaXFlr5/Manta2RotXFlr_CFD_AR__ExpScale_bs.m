%%  Manta Ray Vehicle Build Script for 2 Rotors 
% clear; clc

VEHICLE               = "vehicleManta2Rot";
PLANT                 = "plantManta2Rot";
SIXDOFDYNAMICS        = "sixDoFDynamicsCoupledFossen";
LIBRARY               = "Manta2RotXFlr_CFD_AR";
SCALE                 = 1/10;

%% Essential Values
vhcl = OCT.vehicleM;

vhcl.setFluidDensity(1000,'kg/m^3')
vhcl.setNumTethers(1,'');
vhcl.setBuoyFactor(1.0,''); %Should this be slightly positively buoyant?
vhcl.setFluidCoeffsFileName('Manta_Inc-0_AR9','');
vhcl.setHydroCharacterization(4,'');
%% Volumes and Inertia
vhcl.setVolume(0.00149777,'m^3');
Ixx = 0.04865535;
Iyy = 0.03611101;
Izz = 0.0836951;
Ixy = 1.07e-6;
Ixz = -0.00104889;
Iyz = -1.1e-7;

vhcl.setInertia_CM([Ixx -Ixy -Ixz;...
                    -Ixy Iyy -Iyz;...
                    -Ixz -Iyz Izz],'kg*m^2')
                
%% Important Points
vhcl.setRCM_LE([.815587;0;.0379757]*SCALE,'m')
vhcl.setRB_LE([0;0;0],'m');
vhcl.setRCentOfBuoy_LE(vhcl.rCM_LE.Value + [0;0;0],'m');

%% Control Surfaces
vhcl.setAllMaxCtrlDef(30,'deg');
vhcl.setAllMinCtrlDef(-30,'deg');
vhcl.setAllMaxCtrlDefSpeed(67.082,'deg/s');

%% Wing
AR = 9; b = 8*SCALE; MAC = b/AR; cR = 2*MAC/1.8;
vhcl.setWingRootChord(cR,'m');
vhcl.setWingAR(9,'');
vhcl.setWingTR(1,'');
vhcl.setWingSweep(0,'deg');
vhcl.setWingDihedral(0,'deg');
vhcl.setWingIncidence(0,'deg');
vhcl.setWingAirfoil('NACA2412','');
vhcl.setWingClMin(-1.7,'');
vhcl.setWingClMax(1.7,'');

%% H-stab and V-stab
vhcl.hStab.setRSurfLE_WingLEBdy([3.45;0;0]*SCALE,'m');
vhcl.hStab.setNumTraps(2,'');
vhcl.hStab.setRootChord(.52*SCALE,'m');
vhcl.hStab.setTR(1,'');
vhcl.hStab.setHalfSpan(1.95*SCALE,'m');
vhcl.hStab.setSweep(0,'deg');
vhcl.hStab.setIncidence(.6,'deg');
% vhcl.hStab.setIncidence(0,'deg');
vhcl.hStab.setAirfoil('NACA0015','');
vhcl.hStab.setClMin(-1.7,'');
vhcl.hStab.setClMax(1.7,'');

vhcl.vStab.setRSurfLE_WingLEBdy([3.45;0;0]*SCALE,'m');
vhcl.vStab.setRootChord(.52*SCALE,'m');
vhcl.vStab.setHalfSpan(1.95*SCALE,'m');
vhcl.vStab.setTR(.8,'');
vhcl.vStab.setSweep(0,'deg');
vhcl.vStab.setAirfoil('NACA0015','');
vhcl.vStab.setClMin(-1.7,'');
vhcl.vStab.setClMax(1.7,'');

%% Fuselage (could use more realistic numbers)
vhcl.fuse.setDiameter(0.75*SCALE,'m');
vhcl.fuse.setEndDragCoeff(.1,'');
vhcl.fuse.setSideDragCoeff(1,'');
vhcl.fuse.setRNose_LE([-2.5;0;0]*SCALE,'m');
vhcl.fuse.setREnd_LE([max(vhcl.hStab.rSurfLE_WingLEBdy.Value(1)+vhcl.hStab.rootChord.Value,...
                          vhcl.vStab.rSurfLE_WingLEBdy.Value(1)+vhcl.vStab.rootChord.Value);0;0],'m');

vhcl.setRBridle_LE([vhcl.rCM_LE.Value(1)*.75;0;-vhcl.fuse.diameter.Value/2],'m');
% vhcl.setRBridle_LE(vhcl.rCM_LE.Value,'m');
%% Turbines
vhcl.setNumTurbines(2,'');
vhcl.build('TurbClass','turb');
% port rotor
vhcl.turb1.setMass(0,'kg')
vhcl.turb1.setDiameter(0,'m')
vhcl.turb1.setAxisUnitVec([1;0;0],'')
vhcl.turb1.setAttachPtVec(vhcl.portWing.outlinePtsBdy.Value(:,2)*1/3*SCALE,'m')
vhcl.turb1.setPowerCoeff(.5,'')
vhcl.turb1.setAxalInductionFactor(1.5,'')
vhcl.turb1.setTipSpeedRatio(6,'')
% starboard rotor
vhcl.turb2.setMass(0,'kg')
vhcl.turb2.setDiameter(0,'m')
vhcl.turb2.setAxisUnitVec([-1;0;0],'')
vhcl.turb2.setAttachPtVec(vhcl.stbdWing.outlinePtsBdy.Value(:,2)*1/3,'m')
vhcl.turb2.setPowerCoeff(.5,'')
vhcl.turb2.setAxalInductionFactor(1.5,'')
vhcl.turb2.setTipSpeedRatio(6,'')

%% load/generate fluid dynamic datan
vhcl.calcFluidDynamicCoefffs

%% Added Mass/Damping (defaults to zeros)
Input.wing.Thickness = 12;  Input.wing.Sections = 20; 
Input.hStab.Thickness = 15; Input.hStab.Sections = 20; 
Input.vStab.Thickness = 15; Input.vStab.Sections = 10; 
Input.fuse.Sections = 10; 
[MA] = getAddedMass(Input,vhcl);
vhcl.setMa6x6_LE(MA,'');
% vhcl.plot
%% save file in its respective directory
saveBuildFile('vhcl',mfilename,'variant',["VEHICLE","PLANT","SIXDOFDYNAMICS","LIBRARY"]);



