% clear
% clc
% format compact

VEHICLE               = "vehicleLE";
SIXDOFDYNAMICS        = "sixDoFDynamicsCoupled";

%% Essential Values
vhcl = OCT.vehicle;

vhcl.setFluidDensity(1000,'kg/m^3')
vhcl.setNumTethers(1,'');
vhcl.setBuoyFactor(1.0,'');
vhcl.oldFluidMomentArms.setValue(1,'');
vhcl.setFluidCoeffsFileName('someFile3','');

%% Turbines
vhcl.setNumTurbines(2,'');
vhcl.setTurbDiam(0,'m');

%% Volumes and Inertia
vhcl.setVolume(945352023.474*1e-9,'m^3');
% vhcl.setVolume(2.85698,'m^3')
Ixx=6.303080401918E+09*1e-6;
Iyy=2080666338.077*1e-6;
Izz=8.320369733598E+09*1e-6;
Ixy=0;
Ixz=81875397.942*1e-6;
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
vhcl.setRB_LE([0;0;0],'m');
vhcl.setRCM_LE([0;0;0],'m');
vhcl.setRBridle_LE(vhcl.rCM_LE.Value + [0;0;0],'m');
vhcl.setRCentOfBuoy_LE(vhcl.rCM_LE.Value + [0;0;0],'m');

%% Wing
% vhcl.setRwingLE_cm([-.47064 0 0],'m');
vhcl.setWingRootChord(1,'m');
vhcl.setWingAR(10,'');
vhcl.setWingTR(0.8,'');
vhcl.setWingSweep(5,'deg');
vhcl.setWingDihedral(2,'deg');
vhcl.setWingIncidence(0,'deg');
vhcl.setWingNACA('2412','');
vhcl.setWingClMin(-1.7,'');
vhcl.setWingClMax(1.7,'');

%% H-stab and V-stab
vhcl.hStab.setRSurfLE_WingLEBdy([6;0;0],'m');
vhcl.hStab.setNumTraps(2,'');
vhcl.hStab.setRootChord(.5,'m');
vhcl.hStab.setSpanOrAR('AR',8,'');
vhcl.hStab.setTR(.8,'');
vhcl.hStab.setSweep(10,'deg');
vhcl.hStab.setIncidence(-13.5,'deg');
vhcl.hStab.setNACA('0015','');
vhcl.hStab.setClMin(-1.7,'');
vhcl.hStab.setClMax(1.7,'');

vhcl.vStab.setRSurfLE_WingLEBdy([6;0;0],'m');
vhcl.vStab.setRootChord(.6,'m');
vhcl.vStab.setSpanOrAR('Span',2,'m');
vhcl.vStab.setTR(.8,'');
vhcl.vStab.setSweep(15,'deg');
vhcl.vStab.setNACA('0015','');
vhcl.vStab.setClMin(-1.7,'');
vhcl.vStab.setClMax(1.7,'');

%% Fuselage (could use more realistic numbers)
vhcl.fuse.setDiameter(0.15,'m');
vhcl.fuse.setEndDragCoeff(0,'');
vhcl.fuse.setSideDragCoeff(0,'');
vhcl.fuse.setRNose_LE([-2;0;0],'m');
vhcl.fuse.setREnd_LE([min(vhcl.hStab.rSurfLE_WingLEBdy.Value(1),vhcl.vStab.rSurfLE_WingLEBdy.Value(1));0;0],'m');
    
%% load/generate fluid dynamic datan
vhcl.calcFluidDynamicCoefffs

%% save file in its respective directory
saveBuildFile('vhcl',mfilename,'variant',["VEHICLE","SIXDOFDYNAMICS"]);



