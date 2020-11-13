% clear
% clc
% format compact

VEHICLE               = "vehicleLE";
PLANT                 = "plantDOE";
SIXDOFDYNAMICS        = "sixDoFDynamicsCoupled";

%% Essential Values
vhcl = OCT.vehicle;

loadComponent('ayazAirborneFlow');

vhcl.setFluidDensity(env.water.density.Value,'kg/m^3')
vhcl.setNumTethers(1,'');
vhcl.setBuoyFactor(1.0,'');
vhcl.setFluidCoeffsFileName('ayazAirborneCoeff_v1','');

%% Volumes and Inertia
vhcl.setVolume(0.36,'m^3') %From CAD
Ixx = 25;
Iyy = 32;
Izz = 56;
Ixy = 0;
Ixz = 0.47;
Iyz = 0;

vhcl.setInertia_CM([Ixx -Ixy -Ixz;...
                    -Ixy Iyy -Iyz;...
                    -Ixz -Iyz Izz],'kg*m^2');
                
%% Important Points
vhcl.setRB_LE([0 0 0],'m');
vhcl.setRCM_LE([0 0 0],'m');
vhcl.setRBridle_LE(vhcl.rCM_LE.Value + [0;0;0],'m');
vhcl.setRCentOfBuoy_LE([0;0;0],'m');% [.492,0,.0682] from CAD

%% Added Mass/Damping (defaults to zeros)
vhcl.setMa6x6_LE(zeros(6),'');
% vhcl.setD6x6_B([],'');

%% Control Surfaces
vhcl.setAllMaxCtrlDef(30,'deg');
vhcl.setAllMinCtrlDef(-30,'deg');
vhcl.setAllMaxCtrlDefSpeed(60,'deg/s');

% super high clMax so that none of the surfaces stall
clMax = 5;

%% Wing
vhcl.setWingRootChord(0.666,'m');
vhcl.setWingAR(8.25,''); %Span 10, hspan 5
vhcl.setWingTR(2/3,'');
vhcl.setWingSweep(0,'deg');
vhcl.setWingDihedral(2,'deg');
vhcl.setWingIncidence(0,'deg');
vhcl.setWingAirfoil('NACA2412','');
vhcl.setWingClMin(-clMax,'');
vhcl.setWingClMax(clMax,'');

%% H-stab and V-stab
vhcl.hStab.setRSurfLE_WingLEBdy([2;0;0],'m');
vhcl.hStab.setNumTraps(2,'');
vhcl.hStab.setRootChord(.29,'m');
vhcl.hStab.setTR(1,'');
vhcl.hStab.setHalfSpanGivenAR(4.65,''); %Span 4, hspan 2
vhcl.hStab.setSweep(0,'deg');
vhcl.hStab.setIncidence(0,'deg');
vhcl.hStab.setAirfoil('NACA0015','');
vhcl.hStab.setClMin(-clMax,'');
vhcl.hStab.setClMax(clMax,'');

vhcl.vStab.setRSurfLE_WingLEBdy([1.892;0;0],'m');
vhcl.vStab.setRootChord(.398,'m');
vhcl.vStab.setHalfSpan(.609,'m');
vhcl.vStab.setTR(.9,'');
vhcl.vStab.setSweep(3,'deg');
vhcl.vStab.setAirfoil('NACA0015','');
vhcl.vStab.setClMin(-clMax,'');
vhcl.vStab.setClMax(clMax,'');

%% Fuselage (could use more realistic numbers)
vhcl.fuse.setDiameter(0.08,'m');
vhcl.fuse.setEndDragCoeff(0,'');
vhcl.fuse.setSideDragCoeff(0,'');
vhcl.fuse.setRNose_LE([-1;0;0],'m');
vhcl.fuse.setREnd_LE([max(vhcl.hStab.rSurfLE_WingLEBdy.Value(1)+vhcl.hStab.rootChord.Value,...
    vhcl.vStab.rSurfLE_WingLEBdy.Value(1)+vhcl.vStab.rootChord.Value);0;0],'m');

    
%% load/generate fluid dynamic datan
vhcl.setHydroCharacterization(1,'');
vhcl.calcFluidDynamicCoefffs

%% artificially increase value
kk = 2;
vhcl.portWing.CL.setValue(2*vhcl.portWing.CL.Value,'')
vhcl.stbdWing.CL.setValue(2*vhcl.stbdWing.CL.Value,'')
vhcl.hStab.CL.setValue(2*vhcl.hStab.CL.Value,'')
vhcl.vStab.CL.setValue(2*vhcl.vStab.CL.Value,'')

%% Turbines


totalCD = vhcl.portWing.CD.Value + vhcl.stbdWing.CD.Value + ...
    vhcl.hStab.CD.Value + vhcl.vStab.CD.Value;
opAoA = 11;
[~,aIdx] = min(abs(opAoA - vhcl.portWing.alpha.Value));

idealTurbCD = 0.5*totalCD(aIdx);
idealArea   = idealTurbCD*vhcl.fluidRefArea.Value;
ideaTurbDia = sqrt(4*idealArea/pi);
vhcl.setNumTurbines(2,'');
vhcl.build('TurbClass','turb');
% port rotor
vhcl.turb1.setMass(0.001,'kg');
vhcl.turb1.setDiameter(ideaTurbDia/2,'m');
vhcl.turb1.setAxisUnitVec([1;0;0],'');
vhcl.turb1.setAttachPtVec(vhcl.portWing.outlinePtsBdy.Value(:,2)*1/3,'m');
vhcl.turb1.setPowerCoeff(.4,'');
vhcl.turb1.setDragCoef(.9,'');
vhcl.turb1.setAxalInductionFactor(1.5,'');
vhcl.turb1.setTipSpeedRatio(6,'');
vhcl.turb1.setStaticArea(0.08,'m^2');
vhcl.turb1.setStaticCD(1.5,'');
% starboard rotor
vhcl.turb2.setMass(0.001,'kg');
vhcl.turb2.setDiameter(ideaTurbDia/2,'m');
vhcl.turb2.setAxisUnitVec([1;0;0],'');
vhcl.turb2.setAttachPtVec(vhcl.stbdWing.outlinePtsBdy.Value(:,2)*1/3,'m');
vhcl.turb2.setPowerCoeff(.4,'');
vhcl.turb2.setDragCoef(.9,'');
vhcl.turb2.setAxalInductionFactor(1.5,'');
vhcl.turb2.setTipSpeedRatio(6,'');
vhcl.turb2.setStaticArea(0.08,'m^2');
vhcl.turb2.setStaticCD(1.5,'');


%% save file in its respective directory
saveBuildFile('vhcl',mfilename,'variant',["VEHICLE","PLANT","SIXDOFDYNAMICS"]);



