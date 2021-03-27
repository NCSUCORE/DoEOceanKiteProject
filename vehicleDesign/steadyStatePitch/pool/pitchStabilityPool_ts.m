
clear
close 'All'

loadComponent('Manta2RotXFoil_AR8_b8')

% Scaling
LFactor = .08;      %Length Scale Factor 
DFactor = 1;        %Density Scale Factor 
vhcl.scale(LFactor,DFactor);


set(groot,'defaulttextinterpreter','latex');
set(groot, 'defaultAxesTickLabelInterpreter','latex');
set(groot, 'defaultLegendInterpreter','latex');

reeledOutLength = [50,310];
totalLength     = 400;
tetherDiameter  = .012;
tetherDensity   = 2226;
desiredFlow     = .25;

pitchVector = 0;%-90:10:90;
flwSpdVector = 0.001:0.01:1;
elevatorTrim = [-30,-20,-10,0,10,20,30];

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
TIMER = 1/length(flwSpdVector)/length(reeledOutLength)/length(elevatorTrim);
OUT = 0;
for  ii = 1:length(flwSpdVector)
    for jj = 1:length(reeledOutLength)
        for kk = 1:length(elevatorTrim)
            
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
            % center of mass location (-0.3165)
            centerOfMassXLoc    = (-0.359296482412060);%-body_r_CM_tetherAttach(1);
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
            buoyFactor          = 1.2;%(mass - ...
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
            elevatorDeflection = elevatorTrim(kk);
            
            % test the function
%             [op,PITCHOUT(ii,jj,kk),ELEVATIONOUT(ii,jj,kk)] = pitchStatibilityAnalysisManta(flowSpeed,kiteSpeedInX,...
%                 centerOfBuoyXLoc,centerOfBuoyZLoc,wingAeroCenterXLoc,wingAeroCenterZLoc,hstabAeroCenterXLoc,hstabAeroCenterZLoc,...
%                 bridleXLoc,centerOfMassXLoc,centerOfMassZLoc,elevation,azimuth,pitch,heading,...
%                 mass,gravAcc,density,buoyFactor,wing,hstab,...
%                 elevatorDeflection,pitchVector,flwSpdVector,turbineXLoc,turbineZLoc);
            
            [op,PITCHOUT(ii,jj,kk),ELEVATIONOUT(ii,jj,kk)] = pitchStatibilityAnalysisPool(flowSpeed,kiteSpeedInX,...
                centerOfBuoyXLoc,centerOfBuoyZLoc,wingAeroCenterXLoc,wingAeroCenterZLoc,hstabAeroCenterXLoc,hstabAeroCenterZLoc,...
                bridleXLoc,centerOfMassXLoc,centerOfMassZLoc,elevation,azimuth,pitch,heading,...
                mass,gravAcc,density,buoyFactor,wing,hstab,...
                elevatorDeflection,pitchVector,flwSpdVector,turbineXLoc,turbineZLoc);

            pitchMoment(ii,jj,kk) = op.sumPitchMoments;
            OUT = (OUT) + TIMER*100
        end
    end
    OUT;
end

%% Turbine force to balance
tetherIndex = 2;
fillPlot = false;
figure(1)
hold on
reactionForce = pitchMoment./turbineZLoc;
for ii = 1:length(elevatorTrim)
plot(flwSpdVector,reactionForce(:,tetherIndex,ii))
end
if fillPlot == true
    x1 = [flwSpdVector, fliplr(flwSpdVector)];
    inBetween = [squeeze(reactionForce(:,tetherIndex,2)); fliplr(squeeze(reactionForce(:,tetherIndex,3))')'];
    h1 = fill(x1, inBetween,'b'); 
    set(h1,'facealpha',.5)
end
xlabel('Flow Speed (m/s)')
ylabel('Turbine Force to Pitch to Zero (N)')
title(sprintf('Turbine Pitch vs Flow Speed (Tether Length = %dm)',reeledOutLength(tetherIndex)))
%legend('Elevator -30','Elevator  0 ','Elevator  30');
legend('-30','-20','-10','0','10','20','30')
hold off
xlim([0,.1])

%% Pitch Bounds Short Tether
figure(2)
hold on 
[~,ix] = min( abs( flwSpdVector-desiredFlow ) );
plot(flwSpdVector,squeeze(PITCHOUT(:,1,2)),'--')
x1 = [flwSpdVector, fliplr(flwSpdVector)];
inBetween = [squeeze(PITCHOUT(:,1,1)); fliplr(squeeze(PITCHOUT(:,1,end))')'];
h1 = fill(x1, inBetween,'b');  
set(h1,'facealpha',.5)
plot(desiredFlow*ones(100),linspace(PITCHOUT(ix,1,1),PITCHOUT(ix,1,end),100),'r')
plot(linspace(0,desiredFlow,100),PITCHOUT(ix,1,1)*ones(100),'r--')
plot(linspace(0,desiredFlow,100),PITCHOUT(ix,1,end)*ones(100),'r--')
legend('Zero Elevator Deflection','Pitch From Elevator Deflection Bounds')
grid on
ylim([-90,90])
title(sprintf('Attainable Pitch vs. Flow Speed for %dm of Tether',reeledOutLength(1)))
xlabel('Flow Speed (m/s)')
ylabel('Pitch (deg)')
hold off

%% Pitch Bounds Full Tether
figure(3)
hold on 
[~,ix] = min( abs( flwSpdVector-desiredFlow ) );
plot(flwSpdVector,squeeze(PITCHOUT(:,2,2)),'--')
x2 = [flwSpdVector, fliplr(flwSpdVector)];
inBetween = [squeeze(PITCHOUT(:,2,1)); fliplr(squeeze(PITCHOUT(:,2,end))')'];
h2 = fill(x2, inBetween,'g');  
set(h2,'facealpha',.5)
plot(desiredFlow*ones(100),linspace(PITCHOUT(ix,2,1),PITCHOUT(ix,2,end),100),'r')
plot(linspace(0,desiredFlow,100),PITCHOUT(ix,2,1)*ones(100),'r--')
plot(linspace(0,desiredFlow,100),PITCHOUT(ix,2,end)*ones(100),'r--')
legend('Zero Elevator Deflection','Pitch From Elevator Deflection Bounds')
ylim([-90,90])
title(sprintf('Attainable Pitch vs. Flow Speed for %dm of Tether',reeledOutLength(end)))
xlabel('Flow Speed (m/s)')
ylabel('Pitch (deg)')
hold off

%% Location Check
figure(4)
plot(centerOfBuoyXLoc,3,'*')
hold on
plot(centerOfMassXLoc,2,'*')
plot(wingAeroCenterXLoc,1,'*')
plot(hstabAeroCenterXLoc,0,'*')
plot(turbineXLoc,-1,'*')
xline(0)
legend('Center of Buoy','Center of Mass','Wing Aero Center','Hor Stab Aero Center','Turbine Location','Tether Attachment')
hold off
ylim([-2.5,5.5])
xlim([-10,4])

%% EXTRA
% 
% for ii = 1:size(pitchMoment,1)
%     [momentWithPitch(ii,1,:),Index(ii,:)] = min(abs(squeeze(pitchMoment(ii,:,:))-0));
%     ELEVATOR(ii,1,:) = ELEVATIONOUT(ii,Index(ii,:));
%     %momentWithPitch(ii,1,:) = pitchMoment(ii,Index(ii,:));
% end
% %figure(1)
% hold on
% kitePitch = [];
% for kk = 1:size(pitchMoment,3)
%     plot(pitchVector,pitchMoment(:,:,kk))
%     for ii = 1:size(pitchMoment,1)
%         %xline(pitchAngle(Index(ii,kk)))
%         yline(0)
%         kitePitch(ii,1,kk) = pitchVector(Index(ii,kk));
%     end
% end
% hold off
% xlabel('Pitch Angle (deg)')
% ylabel('Net Pitch Moment (Nm)')
% 
% %%
% % figure(2)
% plot(flwSpdVector,squeeze(kitePitch(:,1,:)))
% title('Pitch vs Flow for Different Elevator Trim Angles')
% ylabel('Pitch Angle for Zero Moment (deg)')
% xlabel('Flow Speed (m/s)')
% hold on 
% xline(.25)
% %legend('Elevator -30','Elevator -20','Elevator -10','Elevator  0 ',...
% %       'Elevator  10','Elevator  20','Elevator  30');
% yyaxis right
% yline(0,'--')
% plot(flwSpdVector,squeeze(momentWithPitch(:,1,:)))
% hold off
% legend('Elevator -30','Elevator  0 ','Elevator  30','Zero Moment','E (-30) Moment','E (0) Moment','E (30) Moment');
% 
% % %plot(flwSpdVector,squeeze(PITCHOUT(:,2,:)),'*')
% % x2 = [flwSpdVector, fliplr(flwSpdVector)];
% % inBetween = [squeeze(PITCHOUT(:,2,1)); fliplr(squeeze(PITCHOUT(:,2,end))')'];
% % h2 = fill(x2, inBetween, 'g');
% % set(h2,'facealpha',.5)
% % plot(.25*ones(100),linspace(PITCHOUT(ix,2,1),PITCHOUT(ix,2,end),100))
% % 
% % %plot(flwSpdVector,squeeze(PITCHOUT(:,3,:)),'*')
% % x3 = [flwSpdVector, fliplr(flwSpdVector)];
% % inBetween = [squeeze(PITCHOUT(:,3,1)); fliplr(squeeze(PITCHOUT(:,3,end)')')];
% % h3 = fill(x3, inBetween, 'b');
% % set(h3,'facealpha',.5)
% % plot(.25*ones(100),linspace(PITCHOUT(ix,3,1),PITCHOUT(ix,3,end),100))
% 
% 


