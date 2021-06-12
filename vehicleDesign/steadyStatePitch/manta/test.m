
clear
%close 'All'

loadComponent('Manta2RotXFoil_AR8_b8')

% Scaling
% LFactor = 1;      %Length Scale Factor 
% DFactor = 1;      %Density Scale Factor 
% vhcl.scale(LFactor,DFactor);


set(groot,'defaulttextinterpreter','latex');
set(groot, 'defaultAxesTickLabelInterpreter','latex');
set(groot, 'defaultLegendInterpreter','latex');

totalLength     = 400;
tetherDiameter  = .012;
tetherDensity   = 2226;
desiredFlow     = .25;
reeledOutLength = totalLength;

pitchVector = -90:1:90;
flwSpdVector = .000001;
elevatorTrim = [0];

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
% Vector from center of mass to turbine attachment in body frame
body_r_turbineAttach_CM = vhcl.turb1.attachPtVec.Value;

% Vector from center of mass to center of boyancy
body_r_CenterBoyancy_CM         = -vhcl.rCM_B.Value;
% Vector from center of mass to h-stab aero center
body_r_hStabAeroCenter_CM = body_r_LE_CM + body_r_hStabLE_LE + body_r_hStabAeroCenter_hStabLE;
% Vector from center of mass to wing aerodynamic center
body_r_wingAero_CM        = body_r_LE_CM + body_r_wingAero_LE;

%% Vectors required for sum of moments at tether attachment point

% (Weight)  Vector from tether attachment point to center of mass
body_r_CM_tetherAttach = body_r_CM_tethAttach;
% (Boyancy) Vector from tether attachment point to center of boyancy
body_r_CenterBoyancy_tetherAttach = -body_r_tethAttach_CM;%body_r_CenterBoyancy_CM + body_r_CM_tethAttach;
% (Wing)    Vector from tether attachment point to wing aerodynamic center
body_r_wingAero_tetherAttach = body_r_wingAero_CM + body_r_CM_tethAttach;
% (H-Stab)  Vector from tether attachment point to h-stab aero center
body_r_hStabAeroCenter_tetherAttach = body_r_hStabAeroCenter_CM + body_r_CM_tethAttach;
% (Tether)  Vector from tether attachment point to wing aerodynamic center
body_r_tetherAttach_tetherAttach = [0;0;0];
% (Turbine) Vector from tether attachment to turbine attachment in body frame
body_r_turbineAttach_tetherAttach = body_r_turbineAttach_CM + body_r_CM_tetherAttach;

%%
TIMER = 1/length(pitchVector);
OUT = 0;
densityWater = 1028;
for  ii = 1:length(pitchVector)
            
            %% define constants
            % flow speed
            flowSpeed           = flwSpdVector;
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
            % center of mass location (-0.3117)
            centerOfMassXLoc    = (-0.313);%-body_r_CM_tetherAttach(1);
            centerOfMassZLoc    = -body_r_CM_tetherAttach(3);
            % Trubine location
            turbineXLoc         = -body_r_turbineAttach_tetherAttach(1);
            turbineZLoc         = -body_r_turbineAttach_tetherAttach(3);
            % elevation angle (tether to ground)
            elevation           = (84.0638)*(pi/180); %set in code tan(L/D)
            % azimuth angle (rotation of tether)
            azimuth             = 0*(pi/180);
            % tangent pitch angle (pitch of kite)
            pitchIN             = pitchVector(ii)*(pi/180);
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
            wing.aspectRatio = 10;          % aspect ratio
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
            elevatorDeflection = elevatorTrim;

            [op,PITCHOUT(ii),ELEVATIONOUT(ii)] = pitchStatibilityAnalysisManta(flowSpeed,kiteSpeedInX,...
                centerOfBuoyXLoc,centerOfBuoyZLoc,wingAeroCenterXLoc,wingAeroCenterZLoc,hstabAeroCenterXLoc,hstabAeroCenterZLoc,...
                bridleXLoc,centerOfMassXLoc,centerOfMassZLoc,elevation,azimuth,pitchIN,heading,...
                mass,gravAcc,density,buoyFactor,wing,hstab,...
                elevatorDeflection,pitchVector,flwSpdVector,turbineXLoc,turbineZLoc);

            pitchMoment(ii) = op.sumPitchMoments;
            pitchDifference(ii) = op.weightPitchMoment + op.buoyPitchMoment; 
            OUT = (OUT) + TIMER*100
end

%% Turbine force to balance
tetherIndex = 1;
desiredPitch = 0;
figure(1)
hold on
reactionForce_1 = pitchDifference./turbineZLoc;
plot(pitchVector,reactionForce_1)

reactionForce_2 = pitchDifference./hstabAeroCenterXLoc;
plot(pitchVector,reactionForce_2)

[~,ix] = min( abs( pitchVector-0 ) );
plot(desiredPitch*ones(100),linspace(reactionForce_1(ix),0,100),'k')
plot(linspace(pitchVector(1),desiredPitch,100),reactionForce_1(ix)*ones(100),'k--')
plot(linspace(pitchVector(1),desiredPitch,100),reactionForce_2(ix)*ones(100),'k--')
legend(sprintf('Turbine Balance = %g (N)',reactionForce_1(ix)),sprintf('Tail Turbine Balance = %g (N)',reactionForce_2(ix)))
xlabel('Kite Pitch Angle (deg)')
ylabel('Force to Balance (N)')
title('Turbine Force vs Kite Pitch Angle')
grid on
hold off
xlim([pitchVector(1),pitchVector(end)])



