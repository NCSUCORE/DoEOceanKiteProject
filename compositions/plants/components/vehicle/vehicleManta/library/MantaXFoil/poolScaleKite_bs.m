%%  Manta Ray Vehicle Build Script for 2 Rotors 
% clear; clc

VEHICLE               = "vehicleManta2RotPool";
PLANT                 = "plantManta2Rot";
SIXDOFDYNAMICS        = "sixDoFDynamicsCoupledFossen12Int";
LIBRARY               = "Manta2RotXFoil_AR8_b8";
% Vehicle is scaled at the end.
%% Essential Values
vhcl = OCT.vehicleM;

vhcl.setFluidDensity(1000,'kg/m^3')
vhcl.setNumTethers(1,'');
vhcl.setBuoyFactor(0.97,''); %Should this be slightly positively buoyant?
vhcl.setFluidCoeffsFileName('poolScaleKite','');
vhcl.setHydroCharacterization(2,'');
%% Volumes and Inertia
vhcl.setVolume(3.27,'m^3');
Ixx = 5.79e+03;
Iyy = 7.83e+03;
Izz = 13.3e+03;
Ixy = -0.017+03;
Ixz = -0.061e+03;
Iyz = 0.0075e+03;

vhcl.setInertia_CM([Ixx -Ixy -Ixz;...
                    -Ixy Iyy -Iyz;...
                    -Ixz -Iyz Izz],'kg*m^2')
                
%% Important Points
vhcl.setRCM_LE([9.7e-01;0;0],'m')
vhcl.setRB_LE([0;0;0],'m');
vhcl.setRCentOfBuoy_LE([9.29e-01;0;3.01e-02],'m');

%% Control Surfaces
vhcl.setAllMaxCtrlDef(30,'deg');
vhcl.setAllMinCtrlDef(-30,'deg');
vhcl.setAllMaxCtrlDefSpeed(67.082,'deg/s');

vhcl.setOptAlpha(14,'deg');
%% Wing
AR = 7.4/2; b = 4.27; tr = 0.8; cR = 2*(b/(AR))/(1+tr);
vhcl.setWingRootChord(cR,'m');
vhcl.setWingAR(AR*2,'');
vhcl.setWingTR(0.8,'');
vhcl.setWingSweep(0,'deg');
vhcl.setWingDihedral(0,'deg');
vhcl.setWingIncidence(0,'deg');
vhcl.setWingAirfoil('SG6040.dat','');
vhcl.setWingClMin(-1.7,'');
vhcl.setWingClMax(1.7,'');

%% H-stab and V-stab
vhcl.hStab.setRSurfLE_WingLEBdy([3.45;0;0],'m');
vhcl.hStab.setNumTraps(2,'');
vhcl.hStab.setRootChord(.55,'m');
vhcl.hStab.setTR(1,'');
vhcl.hStab.setHalfSpan(2,'m');
vhcl.hStab.setSweep(0,'deg');
vhcl.hStab.setIncidence(0,'deg');
vhcl.hStab.setAirfoil('NACA0015','');
vhcl.hStab.setClMin(-1.7,'');
vhcl.hStab.setClMax(1.7,'');

vhcl.vStab.setRSurfLE_WingLEBdy([3.45;0;0],'m');
vhcl.vStab.setRootChord(.55,'m');
vhcl.vStab.setHalfSpan(2,'m');
vhcl.vStab.setTR(1,'');
vhcl.vStab.setSweep(0,'deg');
vhcl.vStab.setAirfoil('NACA0015','');
vhcl.vStab.setClMin(-1.7,'');
vhcl.vStab.setClMax(1.7,'');
% vhcl.vStab.setSpanUnitVec([0;0;-1],'');
% vhcl.vStab.setIncAlphaUnitVecSurf([0;-1;0],'');

%% Fuselage (could use more realistic numbers)
vhcl.fuse.setDiameter(0.635,'m');

vhcl.fuse.setEndDragCoeff(.1,'');
vhcl.fuse.setSideDragCoeff(1,'');
vhcl.fuse.setRNose_LE([-2.5;0;0],'m');
vhcl.fuse.setREnd_LE([4.1;0;0],'m');
vhcl.setRBridle_LE([0.19;0; -0.79],'m')
%% Turbines
vhcl.setNumTurbines(2,'');
vhcl.build('TurbClass','turb');
T1 = readtable('ct_0_7mdia_5_4_21.txt'); T1 = table2array(T1);
T2 = readtable('cp_0_7mdia_5_4_21.txt'); T2 = table2array(T2);
% port rotor
vhcl.turb1.numBlades.setValue(3,'')
vhcl.turb1.setHubMass(0,'kg')
vhcl.turb1.setBladeMass(0,'kg')
vhcl.turb1.setDiameter(0,'m')
vhcl.turb1.hubDiameter.setValue(0,'m')
vhcl.turb1.setAxisUnitVec([1;0;0],'')
vhcl.turb1.setAttachPtVec(vhcl.portWing.outlinePtsBdy.Value(:,2)*1/3,'m')
vhcl.turb1.setPowerCoeff(.4,'')
vhcl.turb1.setDragCoef(.9,'')
vhcl.turb1.setAxalInductionFactor(1.5,'')
vhcl.turb1.setTipSpeedRatio(6,'')
vhcl.turb1.setStaticArea(0.08,'m^2')
vhcl.turb1.setStaticCD(1.5,'')
vhcl.turb1.CpLookup.setValue(T2(:,2),'')
vhcl.turb1.CtLookup.setValue(T1(:,2),'')
vhcl.turb1.RPMref.setValue(T1(:,1),'')
% starboard rotor
vhcl.turb2.numBlades.setValue(3,'')
vhcl.turb2.setHubMass(0,'kg')
vhcl.turb2.setBladeMass(0,'kg')
vhcl.turb2.setDiameter(0,'m')
vhcl.turb2.hubDiameter.setValue(0,'m')
vhcl.turb2.setAxisUnitVec([-1;0;0],'')
vhcl.turb2.setAttachPtVec(vhcl.stbdWing.outlinePtsBdy.Value(:,2)*1/3,'m')
vhcl.turb2.setPowerCoeff(.4,'')
vhcl.turb2.setDragCoef(.9,'')
vhcl.turb2.setAxalInductionFactor(1.5,'')
vhcl.turb2.setTipSpeedRatio(6,'')
vhcl.turb2.setStaticArea(0.08,'m^2')
vhcl.turb2.setStaticCD(1.5,'')
vhcl.turb2.CpLookup.setValue(T2(:,2),'')
vhcl.turb2.CtLookup.setValue(T1(:,2),'')
vhcl.turb2.RPMref.setValue(T1(:,1),'')
%Scale the Vehicle
vhcl.scale(.1,1)
vhcl.turb1.scale(.1,1)
vhcl.turb2.scale(.1,1)
%% load/generate fluid dynamic datan
vhcl.calcFluidDynamicCoefffs
%% Added Mass/Damping (defaults to zeros)
% vhcl.hStab.setHalfSpan(.1,'m');
Input.wing.Thickness = 12;  Input.wing.Sections = 20; 
Input.hStab.Thickness = 15; Input.hStab.Sections = 20; 
Input.vStab.Thickness = 15; Input.vStab.Sections = 10; 
Input.fuse.Sections = 10; 
[MA] = getAddedMass(Input,vhcl);
vhcl.setMa6x6_LE(MA,'');
% vhcl.plot
%% save file in its respective directory
saveBuildFile('vhcl',mfilename,'variant',["VEHICLE","PLANT","SIXDOFDYNAMICS","LIBRARY"]);




