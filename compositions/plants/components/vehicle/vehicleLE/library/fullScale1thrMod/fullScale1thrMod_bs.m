% clear
% clc
% format compact
%TEMPTEMPTEMP
VEHICLE               = "vehicleLE";
SIXDOFDYNAMICS        = "sixDoFDynamicsCoupled";

%% Essential Values
vhcl = OCT.vehicle;

vhcl.setFluidDensity(1000,'kg/m^3')
vhcl.setNumTethers(1,'');
vhcl.setBuoyFactor(1.0,'');
vhcl.setFluidCoeffsFileName('fullScaleMod4','');

%% Turbines
vhcl.setNumTurbines(2,'');
vhcl.setTurbDiam(0,'m');

%% Volumes and Inertia
vhcl.setVolume(2.85698,'m^3')
Ixx=1.094057613168724e+04;
Iyy=1.247604938271605e+04;
Izz=2.467555555555556e+04;
Ixy=0;
Ixz=5.293827160493829e+02;
Iyz=0;
vhcl.setInertia_CM([Ixx -Ixy -Ixz;...
                    -Ixy Iyy -Iyz;...
                    -Ixz -Iyz Izz],'kg*m^2')

%% Added Mass/Damping (defaults to zeros)
% vhcl.setMa6x6_B([],'');
% vhcl.setD6x6_B([],'');

%% Control Surfaces
vhcl.setAllMaxCtrlDef(30,'deg');
vhcl.setAllMinCtrlDef(-30,'deg');
vhcl.setAllMaxCtrlDefSpeed(60,'deg/s');

%% Important Points
vhcl.setRCM_LE([.47064 0 0],'m');
vhcl.setRB_LE(vhcl.rCM_LE.Value,'m');
vhcl.setRBridle_LE(vhcl.rCM_LE.Value + [0;0;0],'m');
vhcl.setRCentOfBuoy_LE(vhcl.rCM_LE.Value + [0.02136;0;0.0682],'m');

%% Wing
vhcl.setWingRootChord(1,'m');
vhcl.setWingAR(10,'');
vhcl.setWingTR(0.8,'');
vhcl.setWingSweep(2.3,'deg');
vhcl.setWingDihedral(2,'deg');
vhcl.setWingIncidence(0,'deg');
vhcl.setWingNACA('2412','');
vhcl.setWingClMin(-1.7,'');
vhcl.setWingClMax(1.7,'');

%% H-stab and V-stab
vhcl.hStab.setRSurfLE_WingLEBdy([4.5;0;0],'m');
vhcl.hStab.setNumTraps(2,'');
vhcl.hStab.setRootChord(.5,'m');
vhcl.hStab.setSpanOrAR('AR',8,'');
vhcl.hStab.setTR(.8,'');
vhcl.hStab.setSweep(2.8624,'deg');
vhcl.hStab.setIncidence(0,'deg');
vhcl.hStab.setNACA('0015','');
vhcl.hStab.setClMin(-1.7,'');
vhcl.hStab.setClMax(1.7,'');

vhcl.vStab.setRSurfLE_WingLEBdy([4.35;0;0],'m');
vhcl.vStab.setRootChord(.65,'m');
vhcl.vStab.setSpanOrAR('Span',2.4375,'m');
vhcl.vStab.setTR(.8,'');
vhcl.vStab.setSweep(3.44,'deg');
vhcl.vStab.setNACA('0015','');
vhcl.vStab.setClMin(-1.7,'');
vhcl.vStab.setClMax(1.7,'');

%% Fuselage (could use more realistic numbers)
vhcl.fuse.setDiameter(0.445,'m');
vhcl.fuse.setEndDragCoeff(.1,'');
vhcl.fuse.setSideDragCoeff(1,'');
vhcl.fuse.setRNose_LE([-2;0;0],'m');
vhcl.fuse.setREnd_LE([max(vhcl.hStab.rSurfLE_WingLEBdy.Value(1),vhcl.vStab.rSurfLE_WingLEBdy.Value(1));0;0],'m');
    
%% load/generate fluid dynamic datan
vhcl.calcFluidDynamicCoefffs

%% save file in its respective directory
saveBuildFile('vhcl',mfilename,'variant',["VEHICLE","SIXDOFDYNAMICS"]);



