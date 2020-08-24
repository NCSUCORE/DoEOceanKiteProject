% clear
% clc
% format compact

VEHICLE               = "vehicleLE";
PLANT                 = "plantDOE";
SIXDOFDYNAMICS        = "sixDoFDynamicsCoupled";

%% Essential Values
vhcl = OCT.vehicle;

vhcl.setFluidDensity(1000,'kg/m^3')
vhcl.setNumTethers(1,'');
vhcl.setBuoyFactor(1.0,''); %Should this be slightly positively buoyant?
vhcl.setFluidCoeffsFileName('AR_s_wingPos_SenA_21','');

%% Volumes and Inertia
vhcl.setVolume(2.39,'m^3') %From CAD

% Copy past values from SW here  
Lxx = 4985.45;	Lxy = 0.03;	Lxz = 257.21;
Lyx = 0.03;	Lyy = 6857.26;	Lyz = 0.00;
Lzx = 257.21;	Lzy = 0.00;	Lzz = 11607.13;

vhcl.setInertia_CM([Lxx -Lxy -Lxz;...
                    -Lxy Lyy -Lyz;...In
                    -Lxz -Lyz Lzz],'kg*m^2')
                
%% Important Points
vhcl.setRCM_LE([0 0 0],'m')
vhcl.setRB_LE(vhcl.rCM_LE.Value,'m');
vhcl.setRBridle_LE(vhcl.rCM_LE.Value + [-0.1;0;0],'m');
vhcl.setRCentOfBuoy_LE(vhcl.rCM_LE.Value + [0;0;0],'m');% [.492,0,.0682] from CAD

%% Control Surfaces
vhcl.setAllMaxCtrlDef(30,'deg');
vhcl.setAllMinCtrlDef(-30,'deg');
vhcl.setAllMaxCtrlDefSpeed(60,'deg/s');

%% Setting for analysis 
vhcl.setWingRootChord(1.29,'m');
AR = 6;
vhcl.fuse.setRNose_LE([-4.75;0;0],'m');
vhcl.hStab.setRSurfLE_WingLEBdy([2.25;0;0],'m');
vhcl.vStab.setRSurfLE_WingLEBdy([vhcl.hStab.rSurfLE_WingLEBdy.Value(1)-0.15;0;0],'m');

%% Wing
area = 10;

span = area/vhcl.wingRootChord.Value;
vhcl.setWingTR(0.8,'');

vhcl.setWingAR(AR,''); %Span 10, hspan 5
vhcl.setWingSweep(2.3,'deg');
vhcl.setWingDihedral(2,'deg');
vhcl.setWingIncidence(0,'deg');
vhcl.setWingAirfoil('NACA2412','');
vhcl.setWingClMin(-1.7,'');
vhcl.setWingClMax(1.7,'');

%% Fuselage (could use more realistic numbers)
vhcl.fuse.setDiameter(0.4445,'m');
vhcl.fuse.setEndDragCoeff(.1,'');
vhcl.fuse.setSideDragCoeff(1,'');

vhcl.fuse.setREnd_LE([9;0;0],'m');

%% H-stab and V-stab

vhcl.hStab.setNumTraps(2,'');
vhcl.hStab.setRootChord(.5,'m');
vhcl.hStab.setTR(.8,'');
vhcl.hStab.setHalfSpanGivenAR(4/.45,''); %Span 4, hspan 2
vhcl.hStab.setSweep(2.8624,'deg');
vhcl.hStab.setIncidence(-20,'deg');
vhcl.hStab.setAirfoil('NACA0015','');
vhcl.hStab.setClMin(-1.7,'');
vhcl.hStab.setClMax(1.7,'');


vhcl.vStab.setRootChord(.65,'m');
vhcl.vStab.setHalfSpan(2.4375,'m');
vhcl.vStab.setTR(.8,'');
vhcl.vStab.setSweep(3.44,'deg');
vhcl.vStab.setAirfoil('NACA0015','');
vhcl.vStab.setClMin(-1.7,'');
vhcl.vStab.setClMax(1.7,'');


%% Turbines
vhcl.setNumTurbines(2,'');
vhcl.build('TurbClass','turb');
% port rotor
vhcl.turb1.setMass(6,'kg')
vhcl.turb1.setDiameter(0,'m')
vhcl.turb1.setAxisUnitVec([1;0;0],'')
vhcl.turb1.setAttachPtVec(vhcl.portWing.outlinePtsBdy.Value(:,2),'m')
vhcl.turb1.setPowerCoeff(.5,'')
vhcl.turb1.setAxalInductionFactor(1.5,'')
vhcl.turb1.setTipSpeedRatio(6,'')
% starboard rotor
vhcl.turb2.setMass(6,'kg')
vhcl.turb2.setDiameter(0,'m')
vhcl.turb2.setAxisUnitVec([-1;0;0],'')
vhcl.turb2.setAttachPtVec(vhcl.stbdWing.outlinePtsBdy.Value(:,2),'m')
vhcl.turb2.setPowerCoeff(.5,'')
vhcl.turb2.setAxalInductionFactor(1.5,'')
vhcl.turb2.setTipSpeedRatio(6,'')

%% Added Mass/Damping 
Input.wing.Thickness = 12;
Input.wing.Sections = 20; 
Input.hStab.Thickness = 12; 
Input.hStab.Sections = 20; 
Input.vStab.Thickness = 12; 
Input.vStab.Sections = 10; 
Input.fuse.Sections = 10; 

[MA] = getAddedMass(Input,vhcl); 
vhcl.setMa6x6_LE([MA],'');

    
%% load/generate fluid dynamic datan
vhcl.calcFluidDynamicCoefffs

%% save file in its respective directory
saveBuildFile('vhcl',mfilename,'variant',["VEHICLE","PLANT","SIXDOFDYNAMICS"]);



