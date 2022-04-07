%%  Manta Ray Vehicle Build Script for 2 Rotors 
% clear; clc

VEHICLE               = "vhcl4turb";
PLANT                 = "plant2turb";
SIXDOFDYNAMICS        = "sixDoFDynamicsCoupledFossen";
LIBRARY               = "ULTKite";

%% Essential Values
vhcl = OCT.vehicleM;
vhcl.convEfficiency.setValue(.75,'');
vhcl.setFluidDensity(1000,'kg/m^3')
vhcl.setNumTethers(1,'');
vhcl.setBuoyFactor(1,'');
vhcl.setFluidCoeffsFileName('longTetherVehicle','');
vhcl.setHydroCharacterization(1,'');
%% Volumes and Inertia
vhcl.setVolume(1,'m^3');
Ixx = 3.3181109e+03;
Iyy = 4.0407857e+03;
Izz = 7.2456248e+03;
Ixy = 0;
Ixz = 1.0686861e+02;
Iyz = 0;

vhcl.setInertia_CM([Ixx -Ixy -Ixz;...
                    -Ixy Iyy -Iyz;...
                    -Ixz -Iyz Izz],'kg*m^2')

vhcl.genKt.setValue(1,'');
vhcl.genR.setValue(0,'');
vhcl.gearBoxLoss.setValue(0,'');
vhcl.gearBoxRatio.setValue(1,'');                
                
%% Important Points
vhcl.setRCM_LE([0.5;0;0],'m')
vhcl.setRB_LE([0;0;0],'m');
vhcl.setRCentOfBuoy_LE([0.6;0;0],'m');

%% Control Surfaces
vhcl.setAllMaxCtrlDef(30,'deg');
vhcl.setAllMinCtrlDef(-30,'deg');
vhcl.setAllMaxCtrlDefSpeed(15,'deg/s');

vhcl.setOptAlpha(10,'deg');
%% Wing
AR = 7.4/2; b = 3; tr = 0.8; cR = 2*(b/(AR))/(1+tr);
vhcl.setWingRootChord(cR,'m');
vhcl.setWingAR(AR*2,'');
vhcl.setWingTR(0.8,'');
vhcl.setWingSweep(0,'deg');
vhcl.setWingDihedral(0,'deg');
vhcl.setWingIncidence(0,'deg');
vhcl.setWingAirfoil('NACA2412','');
vhcl.setWingClMin(-1.7,'');
vhcl.setWingClMax(1.7,'');

vhcl.portWing.CH.setValue([0.0027 0.0046],'');
vhcl.portWing.cCtrlSurf.setValue(0.2775,'m');
vhcl.stbdWing.CH.setValue([0.0027 0.0046],'');
vhcl.stbdWing.cCtrlSurf.setValue(0.2775,'m');

%% H-stab and V-stab
vhcl.hStab.setRSurfLE_WingLEBdy([2.5;0;0],'m');
vhcl.hStab.setNumTraps(2,'');
vhcl.hStab.setRootChord(.55,'m');
vhcl.hStab.setTR(.8,'');
vhcl.hStab.setHalfSpan(1.5,'m');
vhcl.hStab.setSweep(0,'deg');
vhcl.hStab.setIncidence(0,'deg');
vhcl.hStab.setAirfoil('NACA0015','');
vhcl.hStab.setClMin(-1.7,'');
vhcl.hStab.setClMax(1.7,'');

vhcl.hStab.CH.setValue([0.0018 0.0036],'');
vhcl.hStab.cCtrlSurf.setValue(0.1375,'m');

vhcl.vStab.setRSurfLE_WingLEBdy([2.5;0;0],'m');
vhcl.vStab.setRootChord(.55,'m');
vhcl.vStab.setHalfSpan(1.5,'m');
vhcl.vStab.setTR(.8,'');
vhcl.vStab.setSweep(0,'deg');
vhcl.vStab.setAirfoil('NACA0015','');
vhcl.vStab.setClMin(-1.7,'');
vhcl.vStab.setClMax(1.7,'');

vhcl.vStab.CH.setValue([0.0016 0.0031],'')
vhcl.vStab.cCtrlSurf.setValue(0.13,'m')
%% Fuselage (could use more realistic numbers)
vhcl.fuse.setDiameter(0.25,'m');
vhcl.fuse.setEndDragCoeff(.1,'');
vhcl.fuse.setSideDragCoeff(1,'');
vhcl.fuse.setRNose_LE([-1.5;0;0],'m');
vhcl.fuse.setREnd_LE([3;0;0],'m');
vhcl.setRBridle_LE([vhcl.stbdWing.rAeroCent_SurfLE.Value(1);0;-vhcl.fuse.diameter.Value/2],'m');
%% Turbines
vhcl.setNumTurbines(4,'');
vhcl.build('TurbClass','turb');
% port rotor
vhcl.turb1.numBlades.setValue(3,'')
vhcl.turb1.torqueLim.setValue(500,'(N*m)')
vhcl.turb1.setHubMass(1,'kg')
vhcl.turb1.setBladeMass(1,'kg')
vhcl.turb1.setDiameter(.4,'m')
vhcl.turb1.hubDiameter.setValue(.075,'m')
vhcl.turb1.setAxisUnitVec([1;0;0],'')
vhcl.turb1.setAttachPtVec(vhcl.portWing.outlinePtsBdy.Value(:,2)*1/3+[0;0;0.25],'m')
vhcl.turb1.setPowerCoeff(.4,'')
vhcl.turb1.setDragCoef(.9,'')
vhcl.turb1.setAxalInductionFactor(1.5,'')
vhcl.turb1.setTipSpeedRatio(3,'')
vhcl.turb1.setStaticArea(0.08,'m^2')
vhcl.turb1.setStaticCD(1.5,'')
vhcl.turb1.CpLookup.setValue([0.45 0.45],'')
vhcl.turb1.CtLookup.setValue([0.6 .6],'')
vhcl.turb1.RPMref.setValue([1 7],'')

%portLower Rotor

vhcl.turb2.setAxisUnitVec([-1;0;0],'')
vhcl.turb2.setAttachPtVec(vhcl.portWing.outlinePtsBdy.Value(:,2)*1/3-[0;0;0.25],'m')
vhcl.turb2.numBlades.setValue(3,'')
vhcl.turb2.torqueLim.setValue(500,'(N*m)')
vhcl.turb2.setHubMass(1,'kg')
vhcl.turb2.setBladeMass(1,'kg')
vhcl.turb2.setDiameter(.4,'m')
vhcl.turb2.hubDiameter.setValue(.075,'m')
vhcl.turb2.setPowerCoeff(.4,'')
vhcl.turb2.setDragCoef(.9,'')
vhcl.turb2.setAxalInductionFactor(1.5,'')
vhcl.turb2.setTipSpeedRatio(3,'')
vhcl.turb2.setStaticArea(0.08,'m^2')
vhcl.turb2.setStaticCD(1.5,'')
vhcl.turb2.CpLookup.setValue([0.45 0.45],'')
vhcl.turb2.CtLookup.setValue([0.6 .6],'')
vhcl.turb2.RPMref.setValue([1 7],'')

vhcl.turb3.setAxisUnitVec([-1;0;0],'')
vhcl.turb3.setAttachPtVec(vhcl.stbdWing.outlinePtsBdy.Value(:,2)*1/3+[0;0;0.25],'m')
vhcl.turb3.numBlades.setValue(3,'')
vhcl.turb3.torqueLim.setValue(500,'(N*m)')
vhcl.turb3.setHubMass(1,'kg')
vhcl.turb3.setBladeMass(1,'kg')
vhcl.turb3.setDiameter(.4,'m')
vhcl.turb3.hubDiameter.setValue(.075,'m')
vhcl.turb3.setPowerCoeff(.4,'')
vhcl.turb3.setDragCoef(.9,'')
vhcl.turb3.setAxalInductionFactor(1.5,'')
vhcl.turb3.setTipSpeedRatio(3,'')
vhcl.turb3.setStaticArea(0.08,'m^2')
vhcl.turb3.setStaticCD(1.5,'')
vhcl.turb3.CpLookup.setValue([0.45 0.45],'')
vhcl.turb3.CtLookup.setValue([0.6 .6],'')
vhcl.turb3.RPMref.setValue([1 7],'')


vhcl.turb4.setAxisUnitVec([1;0;0],'')
vhcl.turb4.setAttachPtVec(vhcl.stbdWing.outlinePtsBdy.Value(:,2)*1/3-[0;0;0.25],'m')
vhcl.turb4.numBlades.setValue(3,'')
vhcl.turb4.torqueLim.setValue(500,'(N*m)')
vhcl.turb4.setHubMass(1,'kg')
vhcl.turb4.setBladeMass(1,'kg')
vhcl.turb4.setDiameter(.4,'m')
vhcl.turb4.hubDiameter.setValue(.075,'m')
vhcl.turb4.setPowerCoeff(.4,'')
vhcl.turb4.setDragCoef(.9,'')
vhcl.turb4.setAxalInductionFactor(1.5,'')
vhcl.turb4.setTipSpeedRatio(3,'')
vhcl.turb4.setStaticArea(0.08,'m^2')
vhcl.turb4.setStaticCD(1.5,'')
vhcl.turb4.CpLookup.setValue([0.45 0.45],'')
vhcl.turb4.CtLookup.setValue([0.6 .6],'')
vhcl.turb4.RPMref.setValue([1 7],'')
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



