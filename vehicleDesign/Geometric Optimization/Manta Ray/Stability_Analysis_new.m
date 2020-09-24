%%  Kite Design optimization
clc;clear;

%%  Input definitions 
% loadComponent('Manta2RotAVL_0Inc');                          %   Load new vehicle with 2 rotors
% loadComponent('Manta2RotXFoil_0Inc');                          %   Load new vehicle with 2 rotors
loadComponent('Manta2RotXFlr_0Inc');                          %   Load new vehicle with 2 rotors
% loadComponent('Manta2RotXFlr_Thr075');                              %   Manta kite with XFlr5 
% loadComponent('Manta2RotXFlr_CFD');                              %   Manta kite with XFlr5 
loadComponent('Manta2RotXFlr_CFD_AR10');                                 %   Manta kite with XFlr5
wing.alpha = vhcl.portWing.alpha.Value;             %   Wing alpha vec
wing.AR = vhcl.portWing.AR.Value;                   %   Wing alpha vec
wing.b = 8;                                         %   Wing span
wing.S = vhcl.fluidRefArea.Value;                   %   Reference area for wing
wing.CL = vhcl.portWing.CL.Value;                   %   Wing lift coefficient at zero alpha
wing.CD = vhcl.portWing.CD.Value;                   %   Wing drag coefficient at zero alpha
wing.CD_visc = 0.0297;                              %   Wing viscous drag coefficient
wing.CD_ind = 0.2697;                               %   Wing induced drag coefficient
wing.Cfe = 0.003;                                   %   Wing skin-friction drag coefficient
wing.gamma = 1;                                     %   Wing airfoil lift curve slope multiplicative constant
wing.eL = 0.9;                                      %   Wing lift Oswald efficiency factor
wing.eD = 0.9;                                      %   Wing drag Oswald efficiency factor
wing.aeroCent = [.1807 0 0]';                       %   Wing aerodynamic center 
wing.E = 69e9;                                      %   Wing modulus of elasticity 

hStab.alpha = vhcl.hStab.alpha.Value;               %   Horizontal stabilizer alpha vec
hStab.CL = vhcl.hStab.CL.Value;                     %   Horizontal stabilizer lift coefficient
hStab.CD = vhcl.hStab.CD.Value;                     %   Horizontal stabilizer drag coefficient
hStab.AR = vhcl.hStab.AR.Value;                     %   Horizontal stabilizer aspect ratio 
hStab.S = vhcl.fluidRefArea.Value;                  %   Reference area for horizontal stabilizer
hStab.gamma = 1;                                    %   Horizontal stabilizer airfoil lift curve slope multiplicative constant
hStab.eL = 0.9;                                     %   Horizontal stabilizer lift Oswald efficiency factor
hStab.eD = 0.9;                                     %   Horizontal stabilizer drag Oswald efficiency factor
hStab.aeroCent = vhcl.hStab.rAeroCent_SurfLE.Value; %   Horizontal stabilizer aero center
hstab.dCLElevator = 0.08;                           %   change in hstab CL per deg deflection of elevator

vStab.alpha = vhcl.vStab.alpha.Value;               %   Find index corresponding to 0 AoA
vStab.CD = vhcl.vStab.CD.Value;                     %   Horizontal stabilizer drag coefficient at zero alpha
vStab.S = vhcl.fluidRefArea.Value;                  %   Reference area for horizontal stabilizer
vStab.eD = 0.9;                                     %   Vertical stabilizer drag Oswald efficiency factor
vStab.aeroCent = [.1739 0 .9389]';                  %   Vertical stabilizer aero center

fuse.CD0 = vhcl.fuse.endDragCoeff.Value;            %   Fuselage drag coefficient at 0° AoA
fuse.CDs = vhcl.fuse.sideDragCoeff.Value;           %   Fuselage drag coefficient at 90° AoA
fuse.L = vhcl.fuse.length.Value;                    %   m - Length of fuselage 
fuse.D = vhcl.fuse.diameter.Value;                  %   m - Fuselage diameter 

turb.D = vhcl.turb1.diameter.Value;                 %   m - Turbine diameter 
turb.CD = vhcl.turb1.dragCoeff.Value;               %   Rotor drag coefficient 
turb.num = vhcl.numTurbines.Value;                  %   # of turbines 

Sys.m = vhcl.mass.Value;                            %   kg - vehicle mass
Sys.ma = vhcl.Ma6x6_LE.Value;                       %   kg - added mass matrix 
Sys.B = 1;                                          %   Buoyancy factor
Sys.LE = -vhcl.fuse.rNose_LE.Value;                 %   m - wing leading edge w/ respect to nose
Sys.xg = Sys.LE+vhcl.rCM_LE.Value;                  %   m - Center of gravity w/ respect to nose
Sys.xb = Sys.LE+vhcl.rCentOfBuoy_LE.Value;          %   m - Center of buoyancy location w/ respect to nose
Sys.xbr = Sys.LE+vhcl.thrAttchPts_B.posVec.Value;   %   m - Bridle location w/ respect to nose
Sys.xW = Sys.LE+wing.aeroCent;                      %   m - Wing aerodynamic center location w/ respect to nose
Sys.xH = Sys.LE+...                                 %   m - Horizontal stabilizer aerodynamic center location w/ respect to nose
    vhcl.hStab.rSurfLE_WingLEBdy.Value+...
    hStab.aeroCent;
Sys.xV = Sys.LE+...                                 %   m - Vertical stabilizer aerodynamic center location w/ respect to nose
    vhcl.vStab.rSurfLE_WingLEBdy.Value+...
    vStab.aeroCent;
Sys.f = Sys.LE+vhcl.fuseMomentArm.Value;            %   m - Fuselage aerodynamic center w/ respect to nose
Sys.xT = Sys.LE;

CM.xg = Sys.xg-Sys.xg;      CM.xb = Sys.xb-Sys.xg;
CM.xbr = Sys.xbr-Sys.xg;    CM.xW = Sys.xW-Sys.xg;
CM.xH = Sys.xH-Sys.xg;      CM.xV = Sys.xV-Sys.xg;
CM.xf = Sys.f-Sys.xg;       CM.xT = Sys.xT-Sys.xg;

BR.xg = Sys.xg-Sys.xbr;     BR.xb = Sys.xb-Sys.xbr;
BR.xbr = Sys.xbr-Sys.xbr;   BR.xW = Sys.xW-Sys.xbr;
BR.xH = Sys.xH-Sys.xbr;     BR.xV = Sys.xV-Sys.xbr;
BR.xf = Sys.f-Sys.xbr;      BR.xT = Sys.xT-Sys.xbr;

LE.xg = Sys.xg-Sys.LE;      LE.xb = Sys.xb-Sys.LE;
LE.xbr = Sys.xbr-Sys.LE;    LE.xW = Sys.xW-Sys.LE;
LE.xH = Sys.xH-Sys.LE;      LE.xV = Sys.xV-Sys.LE;
LE.xf = Sys.f-Sys.LE;       LE.xT = Sys.xT-Sys.LE;

Sys.vKite = [0 0 0]';                               %   m/s - Kite velocity 
Env.vFlow = [1.646 0 0]';                             %   m/s - Flow speed 
Env.rho = 1000;                                     %   kg/m^3 - density of seawater
Env.g = 9.81;                                       %   m/s^2 - gravitational acceleration 
%%
% [Ixx_opt,Fthk,Mtot,Wingdim] = runStructOpt(vhcl,wing,hStab,vStab,fuse,Env);
%%  Position and Orientation Angles 
Ang.elevation = 80;                                     %   deg - Elevation angle
Ang.zenith = 90-Ang.elevation;                          %   deg - Zenith angle 
Ang.azimuth = 0;                                        %   deg - Azimuth angle 
Ang.roll = 0;                                           %   deg - Roll angle 
Ang.pitch = 0;%-10:.1:10;                                          %   deg - Pitch angle 
Ang.yaw = 0;                                            %   deg - Yaw angle 
Ang.heading = 0;                                        %   deg - Heading on the sphere; 0 = south; 90 = east; etc.
% Ang.tanPitch = Ang.pitch-90+Ang.elevation;              %   deg - Tangent pitch angle
%%  Analyze Stability 
pitchM = zeros(numel(Ang.pitch),1);
pitchMa = zeros(numel(Ang.pitch),1);
lift = zeros(numel(Ang.pitch),1);
alphaRef = -10:.01:10;
CLh = interp1(hStab.alpha,hStab.CL,alphaRef);
for i = 1:numel(Ang.pitch)
    Ang.tanPitch = Ang.pitch(i)-90+Ang.elevation;              %   deg - Tangent pitch angle
    [MCM,MBR(i),MLE,F(i),CLCM,CLBR,CLLE,CD,Theta0] = staticAnalysis(Sys,Env,wing,hStab,vStab,fuse,turb,Ang,CM,LE,BR);
    pitchM(i) = MBR(i).tot(2);
    pitchMa(i) = MBR(i).totMa(2);
    if Ang.pitch(i) < -1.9
        lift(i) = -sqrt(sum((F(i).liftBw+F(i).liftBw).^2));
    else
        lift(i) = sqrt(sum((F(i).liftBw+F(i).liftBw).^2));
    end
    hReq = CLBR.hReq;
    if numel(Ang.pitch) == 1 && Ang.pitch(i) == 0
        idx = find(abs(CLh-hReq) <= .0005);
        incidence = alphaRef(idx)  
        CLhN = CLh(idx)
    end
end
if numel(Ang.pitch) > 1
    mL = (lift(end)-lift(end-1))/(Ang.pitch(end)-Ang.pitch(end-1));
    mL1 = diff(lift)./diff(Ang.pitch');
    mM = (pitchM(end)-pitchM(end-1))/(Ang.pitch(end)-Ang.pitch(end-1));
    mM1 = diff(pitchM)./diff(Ang.pitch');
    mMa = (pitchMa(end)-pitchMa(end-1))/(Ang.pitch(end)-Ang.pitch(end-1));
    mMa1 = diff(pitchMa)./diff(Ang.pitch');
    hStatic = mM/mL;
    hStatica = mMa/mL;
    hS = pitchM./lift;
    hSa = pitchMa./lift;
    hS1 = mM1./mL1;
    hSa1 = mMa1./mL1;
end
%%  Plotting 
if numel(Ang.pitch) > 1
    figure; %subplot(2,1,1); 
    hold on; grid on;
    plot(Ang.pitch,pitchM,'b-');  xlabel('$\theta$ [deg]');  ylabel('Pitch Moment [Nm]')
    plot(Ang.pitch,pitchMa,'r-');  xlabel('$\theta$ [deg]');  ylabel('Pitch Moment [Nm]')
    legend('w/o $\mathrm{M_{add}}$','w/ $\mathrm{M_{add}}$')
    %     subplot(2,1,2); hold on; grid on;
    %     plot(Ang.pitch,lift,'b-');  xlabel('$\theta$ [deg]');  ylabel('Lift [N]')
    
    figure; subplot(1,2,1); hold on; grid on;
    plot(Ang.pitch,pitchMa,'b-');  xlabel('$\alpha$ [deg]');  ylabel('Pitch Moment [Nm]')
    subplot(1,2,2); hold on; grid on;
    plot(Ang.pitch(2:end),hSa1,'b-');  xlabel('$\alpha$ [deg]');  ylabel('Stability [m]')
end
% figure; hold on; grid on
% plot(hStab.alpha,hStab.CL,'b-');  xlabel('$\theta$ [deg]');  ylabel('CLh')

%%

