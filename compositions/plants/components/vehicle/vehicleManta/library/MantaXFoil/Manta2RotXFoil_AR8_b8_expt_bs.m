%%  Manta Ray Vehicle Build Script for 2 Rotors 
% clear; clc

VEHICLE               = "vehicleManta2Rot";
PLANT                 = "plantManta2Rot";
SIXDOFDYNAMICS        = "sixDoFDynamicsCoupledFossen";
LIBRARY               = "Manta2RotXFoil_AR8_b8_expt";

%% Essential Values
vhcl = OCT.vehicleM;

vhcl.setFluidDensity(1000,'kg/m^3')
vhcl.setNumTethers(1,'');
vhcl.setBuoyFactor(1.,''); % 3.88 percent positive 
vhcl.setFluidCoeffsFileName('Manta_AR8_b8_exp','');
vhcl.setHydroCharacterization(2,'');
%% Volumes and Inertia
vhcl.setVolume(.00276934,'m^3');
Ixx = 0.02410385;
Iyy = 0.04737310;
Izz = 0.06980934;
Ixy = 5e-08;
Ixz = .00016205;
Iyz = 0;

vhcl.setInertia_CM([Ixx -Ixy -Ixz;...
                    -Ixy Iyy -Iyz;...
                    -Ixz -Iyz Izz],'kg*m^2')
                
%% Important Points
vhcl.setRCM_LE([.087;0;3.1365427e-03],'m')
vhcl.setRB_LE([0;0;0],'m');
vhcl.setRCentOfBuoy_LE(vhcl.rCM_LE.Value + [0;0;0],'m');

%% Control Surfaces
vhcl.setAllMaxCtrlDef(30,'deg');
vhcl.setAllMinCtrlDef(-30,'deg');
vhcl.setAllMaxCtrlDefSpeed(67.082,'deg/s');

vhcl.setOptAlpha(10,'deg');
%% Wing
AR = 7.4/2; b = .427; tr = 0.8; cR = 2*(b/(AR))/(1+tr);
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
vhcl.hStab.setRSurfLE_WingLEBdy([.345;0;0],'m');
vhcl.hStab.setNumTraps(2,'');
vhcl.hStab.setRootChord(.055,'m');
vhcl.hStab.setTR(.8,'');
vhcl.hStab.setHalfSpan(.2,'m');
vhcl.hStab.setSweep(0,'deg');
vhcl.hStab.setIncidence(.1,'deg');
vhcl.hStab.setIncidence(2,'deg');
vhcl.hStab.setAirfoil('NACA0015','');
vhcl.hStab.setClMin(-1.7,'');
vhcl.hStab.setClMax(1.7,'');

vhcl.vStab.setRSurfLE_WingLEBdy([.345;0;0],'m');
vhcl.vStab.setRootChord(.052,'m');
vhcl.vStab.setHalfSpan(.195,'m');
vhcl.vStab.setTR(.8,'');
vhcl.vStab.setSweep(0,'deg');
vhcl.vStab.setAirfoil('NACA0015','');
vhcl.vStab.setClMin(-1.7,'');
vhcl.vStab.setClMax(1.7,'');

%% Fuselage (could use more realistic numbers)
vhcl.fuse.setDiameter(0.0635,'m');
vhcl.fuse.setEndDragCoeff(.1,'');
vhcl.fuse.setSideDragCoeff(1,'');
vhcl.fuse.setRNose_LE([-.25;0;0],'m');
vhcl.fuse.setREnd_LE([.41;0;0],'m');
vhcl.setRBridle_LE([vhcl.rCM_LE.Value(1);0;-vhcl.fuse.diameter.Value/2],'m');
%% Turbines
vhcl.setNumTurbines(2,'');
vhcl.build('TurbClass','turb');
% port rotor
vhcl.turb1.setMass(0.6,'kg')
vhcl.turb1.setDiameter(0,'m')
vhcl.turb1.setAxisUnitVec([1;0;0],'')
vhcl.turb1.setAttachPtVec(vhcl.portWing.outlinePtsBdy.Value(:,2)*1/3,'m')
vhcl.turb1.setPowerCoeff(.4,'')
vhcl.turb1.setDragCoef(0,'')
vhcl.turb1.setAxalInductionFactor(1.5,'')
vhcl.turb1.setTipSpeedRatio(6,'')
vhcl.turb1.setStaticArea(0.0,'m^2')
vhcl.turb1.setStaticCD(0,'')
% starboard rotor
vhcl.turb2.setMass(.6,'kg')
vhcl.turb2.setDiameter(0,'m')
vhcl.turb2.setAxisUnitVec([-1;0;0],'')
vhcl.turb2.setAttachPtVec(vhcl.stbdWing.outlinePtsBdy.Value(:,2)*1/3,'m')
vhcl.turb2.setPowerCoeff(.4,'')
vhcl.turb2.setDragCoef(0,'')
vhcl.turb2.setAxalInductionFactor(1.5,'')
vhcl.turb2.setTipSpeedRatio(6,'')
vhcl.turb2.setStaticArea(0.0,'m^2')
vhcl.turb2.setStaticCD(0,'')
%% load/generate fluid dynamic datan
vhcl.calcFluidDynamicCoefffs

%% Added Mass/Damping (defaults to zeros)
Input.wing.Thickness = 16;  Input.wing.Sections = 20; 
Input.hStab.Thickness = 15; Input.hStab.Sections = 20; 
Input.vStab.Thickness = 15; Input.vStab.Sections = 10; 
Input.fuse.Sections = 10; 
[MA] = getAddedMass(Input,vhcl);
vhcl.setMa6x6_LE(MA,'');
% vhcl.plot
%% save file in its respective directory
saveBuildFile('vhcl',mfilename,'variant',["VEHICLE","PLANT","SIXDOFDYNAMICS","LIBRARY"]);




