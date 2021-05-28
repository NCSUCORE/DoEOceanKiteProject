
clear
close 'All'

loadComponent('Manta2RotXFoil_AR8_b8')

set(groot,'defaulttextinterpreter','latex');
set(groot, 'defaultAxesTickLabelInterpreter','latex');
set(groot, 'defaultLegendInterpreter','latex');

reeledOutLength = 50;
totalLength     = 400;
tetherDiameter  = .012;
tetherDensity   = 2226;
desiredFlow     = .25;
CM_SearchVector          =  linspace(-.32,-.31,2000);

pitchVector = 0;%-20:5:20;
flwSpdVector = [.001,.1,.25,.5,.75,1];
elevatorTrim = 0;%[-30,0,30];

runMunkTable = 0;
% fun this if pitch or flow vector is changed!!
if runMunkTable == 1
    MunkMomentAnalysisManta(pitchVector,flwSpdVector)
end

%% Vectors from Kite

% Rotation matrix from surface to body frame
B_c_S = vhcl.stbdWing.RSurf2Bdy.Value;

% Vector from Center of Mass to Wing Leading Edge
body_r_LE_CM      = -vhcl.rCM_LE.Value;
% Vector from wing leading edge to h-Stab leading edge
body_r_hStabLE_LE = vhcl.hStab.rSurfLE_WingLEBdy.Value;
% Vector from Hor Stab Leading Edge to horizontal stabilizer aero center
surface_r_hStabAeroCenter_hStabLE = vhcl.hStab.rAeroCent_SurfLE.Value;
body_r_hStabAeroCenter_hStabLE    = B_c_S*surface_r_hStabAeroCenter_hStabLE;
% Vector form wing leading edge to tether attachment
body_r_tethAttach_LE = vhcl.rBridle_LE.Value;
% Vector from wing leading edge to wing aerodynamic center
surface_r_wingAero_LE = vhcl.stbdWing.rAeroCent_SurfLE.Value;
body_r_wingAero_LE    = B_c_S*surface_r_wingAero_LE;
% Vectro from center of mass to tether attachmet point
body_r_tethAttach_CM = body_r_tethAttach_LE + body_r_LE_CM;
% Vector from tether attachmet point to center of mass
body_r_CM_tethAttach = -body_r_tethAttach_CM;
% Vector from center of mass to turbine attachment in body frame (LE wing)
body_r_turbineAttach_CM = -body_r_tethAttach_LE + body_r_tethAttach_CM;

% Vector from center of mass to center of boyancy
body_r_CenterBoyancy_CM   = -vhcl.rCM_B.Value;
% Vector from center of mass to h-stab aero center
body_r_hStabAeroCenter_CM = body_r_LE_CM + body_r_hStabLE_LE + body_r_hStabAeroCenter_hStabLE;
% Vector from center of mass to wing aerodynamic center
body_r_wingAero_CM        = body_r_LE_CM + body_r_wingAero_LE;

%% Vectors required for sum of moments at tether attachment point

% (Weight)  Vector from tether attachment point to center of mass
body_r_CM_tetherAttach = body_r_CM_tethAttach;
% (Boyancy) Vector from tether attachment point to center of boyancy
% (-body_r_tethAttach_CM) 
body_r_CenterBoyancy_tetherAttach = body_r_CenterBoyancy_CM + body_r_CM_tethAttach;
% (Wing)    Vector from tether attachment point to wing aerodynamic center
body_r_wingAero_tetherAttach = body_r_wingAero_CM + body_r_CM_tethAttach;
% (H-Stab)  Vector from tether attachment point to h-stab aero center
body_r_hStabAeroCenter_tetherAttach = body_r_hStabAeroCenter_CM + body_r_CM_tethAttach;
% (Tether)  Vector from tether attachment point to wing aerodynamic center
body_r_tetherAttach_tetherAttach = [0;0;0];
% (Turbine) Vector from tether attachment to turbine attachment in body frame
body_r_turbineAttach_tetherAttach = body_r_turbineAttach_CM + body_r_CM_tethAttach;

%% Vectors to check kite body
% Vector from leading edge to front of kite
body_r_front_LE = vhcl.fuse.rNose_LE.Value;
% Vector from tether attach to front of kite
body_r_front_tetherAttach = body_r_front_LE + body_r_LE_CM + body_r_CM_tethAttach;
% Vector from leading edge to back of kite
body_r_back_LE   = vhcl.fuse.rEnd_LE.Value ;
% Vector from tether attach to back of kite
body_r_back_tetherAttach = body_r_back_LE + body_r_LE_CM + body_r_CM_tethAttach;

%%
TIMER = 1/length(flwSpdVector)/length(reeledOutLength)/length(elevatorTrim)/length(CM_SearchVector);
OUT = 0;
densityWater = 1023;
for  ii = 1:length(flwSpdVector)
    for jj = 1:length(reeledOutLength)
        for kk = 1:length(elevatorTrim)
            for ll = 1:length(CM_SearchVector)
                
                %%
                CM_Correct = .011730865432716;
                vhcl.setRCM_LE([8.8444775e-01 + CM_Correct;...
                    0             ;...
                    3.1365427e-02 ],'m')
                vhcl.setRCentOfBuoy_LE(vhcl.rCM_LE.Value - [CM_Correct;0;0],'m');
                vhcl.setRB_LE(vhcl.rCentOfBuoy_LE.Value + [0;0;0],'m');
                vhcl.setRBridle_LE([vhcl.rB_LE.Value(1)-.3;0;-vhcl.fuse.diameter.Value/2],'m');
                
                %% define constants
                % flow speed
                flowSpeed           = flwSpdVector(ii);
                % kite speed
                kiteSpeedInX        = 0;
                % center of buoyancy
                centerOfBuoyXLoc    = -body_r_CenterBoyancy_tetherAttach(1);
                centerOfBuoyZLoc    = -body_r_CenterBoyancy_tetherAttach(3);
                % wing aero center
                wingAeroCenterXLoc  = -body_r_wingAero_tetherAttach(1);
                wingAeroCenterZLoc  = -body_r_wingAero_tetherAttach(3);
                % H-stab aero center
                hstabAeroCenterXLoc = -body_r_hStabAeroCenter_tetherAttach(1);
                hstabAeroCenterZLoc = -body_r_hStabAeroCenter_tetherAttach(3);
                % tether attachment location
                bridleXLoc          = -body_r_tetherAttach_tetherAttach(1);
                % center of mass location
                centerOfMassXLoc    = CM_SearchVector(ll);
                centerOfMassZLoc    = -body_r_CM_tetherAttach(3);
                % Trubine location
                turbineXLoc         = -body_r_turbineAttach_tetherAttach(1);
                turbineZLoc         = -body_r_turbineAttach_tetherAttach(3);
                % elevation angle (tether to ground)
                elevation           = (84.0638)*(pi/180); %set in code tan(L/D)
                % azimuth angle (rotation of tether)
                azimuth             = 0*(pi/180);
                % tangent pitch angle (pitch of kite)
                pitch               = 45*(pi/180);
                % heading angle (angle of kite)
                heading             = 0*(pi/180);
                % mass
                mass                = vhcl.mass.Value;
                % gravity
                gravAcc             = 9.81;
                % fluid density
                density             = 1e3;
                % factor of buoyancy (=1 is neutrally buoyant) (>1 Float) (<1 Sink)
                volumeKite   = vhcl.volume.Value       ;
                volumeWater  = volumeKite              ; 
                massWater    = densityWater*volumeWater;
                massKite     = 1023*volumeWater/1.0391 ;
                buoyFactor   = massWater/massKite      ;
                %buoyFactor          = 1.0391;%(mass+(tetherDensity*(totalLength)*(pi/4)*tetherDiameter^2))/mass;
                                      %(mass - ...
                                      %(tetherDensity*reeledOutLength(jj)*(pi/4)*tetherDiameter^2 - ...
                                      %tetherDensity*(totalLength      )*(pi/4)*tetherDiameter^2))/...
                                      %mass;
                
                % wing
                wing.span = 9;                  % span
                wing.aspectRatio = 10;           % aspect ratio
                wing.oswaldEff = 0.8;           % oswald efficient < 1
                wing.ZeroAoALift = 0.1;         % zero angle of attack lift
                wing.ZeroAoADrag = 0.01;        % zero angle of attack drag
                
                % horizontal stabilizer
                hstab.span = 4;                 % span
                hstab.aspectRatio = 8.0483;     % aspect ratio
                hstab.oswaldEff = 0.8;          % oswald efficient < 1
                hstab.ZeroAoALift = 0.0;        % zero angle of attack lift
                hstab.ZeroAoADrag = 0.01;       % zero angle of attack drag
                hstab.dcLbydElevator = 0.08;    % change in hstab CL per deg deflection of elevator (vhcl.hStab.gainCL)
                
                % elevator deflection in degrees (Elevator Trim)
                elevatorDeflection = elevatorTrim(kk);
                
                % test the function
                [op,PITCHOUT(ii,ll)] = pitchStatibilityAnalysisManta(flowSpeed,kiteSpeedInX,...
                    centerOfBuoyXLoc,centerOfBuoyZLoc,wingAeroCenterXLoc,wingAeroCenterZLoc,hstabAeroCenterXLoc,hstabAeroCenterZLoc,...
                    bridleXLoc,centerOfMassXLoc,centerOfMassZLoc,elevation,azimuth,pitch,heading,...
                    mass,gravAcc,density,buoyFactor,wing,hstab,...
                    elevatorDeflection,pitchVector,flwSpdVector);
                
                pitchMoment(ii,jj,kk) = op.sumPitchMoments;
                OUT = (OUT) + TIMER*100
            end
        end
    end
    OUT;
end


%% Plot

for jj = 1:size(PITCHOUT,1)
    [~,ix(jj)] = min( abs( PITCHOUT(jj,:)-0 ) );
end

find((CM_SearchVector(:)+body_r_CenterBoyancy_tetherAttach(1))==0)

title('Steady State Pitch vs CM Location')
xlabel('Distance of Center of Mass to Center of Boyancy (m)')
ylabel('Steady State Pitch (deg)')
hold on
%plot(linspace((CM_loc(end)+body_r_CenterBoyancy_tetherAttach(1)),(CM_loc(ix)+body_r_CenterBoyancy_tetherAttach(1)),100),zeros(1,100),'r')
plot(CM_SearchVector+body_r_CenterBoyancy_tetherAttach(1),PITCHOUT(1,:))
%plot((CM_loc(ix)+body_r_CenterBoyancy_tetherAttach(1))*ones(1,100),linspace(-90,0,100),'r')
hold off
ylim([-90,90])
hold on
for ii = 2:size(PITCHOUT,1)
    plot(CM_SearchVector+body_r_CenterBoyancy_tetherAttach(1),PITCHOUT(ii,:))
end
grid on
hold off
legend('Pitch Value (  .001 m/s Flow )',...
    'Pitch Value (  .1   m/s Flow )',...
    'Pitch Value (  .25  m/s Flow )',...
    'Pitch Value (  .5   m/s Flow )',...
    'Pitch Value (  .75  m/s Flow )',...
    'Pitch Value ( 1     m/s Flow )');

format long
CM_SearchVector(ix)'
CM_for_Zero = CM_SearchVector(ix)'+body_r_CenterBoyancy_tetherAttach(1)
format short

