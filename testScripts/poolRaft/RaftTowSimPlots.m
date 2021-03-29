% CORE LAB
% Plots 2 versions of simlulation data against each other
% @author Zachary Leonard
close all
clear
clc

%% Load data from simulations
tsc1 = load('tsc05flowAddedMassOn.mat');
tsc2 = load('tsc05towAddedMassOn.mat');
speed = "0.5";
tsc1label = 'flow with added mass';
tsc2label = 'tow with added mass';

%% Plot data from simulation
% Plot azi and elevation of kite from GS

% Compute kite position from ground station
kitePosViaGS1 = zeros(3,tsc1.tsc.gndStnPositionVec.Length);
for i=1:tsc1.tsc.gndStnPositionVec.Length
    for j=1:3
        kitePosViaGS1(j,i) = -tsc1.tsc.gndStnPositionVec.Data(j,1,i)...
                              + tsc1.tsc.positionVec.Data(j,1,i);
    end
end

kitePosViaGS2 = zeros(3,tsc2.tsc.gndStnPositionVec.Length);
for i=1:tsc2.tsc.gndStnPositionVec.Length
    for j=1:3
        kitePosViaGS2(j,i) = -tsc2.tsc.gndStnPositionVec.Data(j,1,i)...
                              + tsc2.tsc.positionVec.Data(j,1,i);
    end
end

% Compute kite azimuth and elevation from ground station
kitePosViaGSazi1 = zeros(1,tsc1.tsc.gndStnPositionVec.Length);
kitePosViaGSel1 = zeros(1,tsc1.tsc.gndStnPositionVec.Length);
for i=1:tsc1.tsc.gndStnPositionVec.Length
    kitePosViaGSazi1(1,i) = atan( kitePosViaGS1(2,i) / -kitePosViaGS1(1,i) );
    kitePosViaGSel1(1,i) = atan( -kitePosViaGS1(3,i)...
                  / ( kitePosViaGS1(1,i)^2 + kitePosViaGS1(2,i)^2 )^(1/2) );
end

kitePosViaGSazi2 = zeros(1,tsc2.tsc.gndStnPositionVec.Length);
kitePosViaGSel2 = zeros(1,tsc2.tsc.gndStnPositionVec.Length);
for i=1:tsc2.tsc.gndStnPositionVec.Length
    kitePosViaGSazi2(1,i) = atan( kitePosViaGS2(2,i) / -kitePosViaGS2(1,i) );
    kitePosViaGSel2(1,i) = atan( -kitePosViaGS2(3,i)...
                  / ( kitePosViaGS2(1,i)^2 + kitePosViaGS2(2,i)^2 )^(1/2) );
end

% Plot Kite Elevation Angle
figure
plot(tsc1.tsc.gndStnPositionVec.Time, kitePosViaGSel1*180/pi)
hold on
plot(tsc2.tsc.gndStnPositionVec.Time, kitePosViaGSel2*180/pi)
legend(tsc1label, tsc2label')
ylabel('Elevation Angle [deg]')
xlabel('Time [s]')
title(char(strcat("Kite Elevation Angle from GS for ",speed," m/s")))

% Plot Kite Azimuth Angle
figure
plot(tsc1.tsc.gndStnPositionVec.Time, kitePosViaGSazi1*180/pi)
hold on
plot(tsc2.tsc.gndStnPositionVec.Time, kitePosViaGSazi2*180/pi)
legend(tsc1label, tsc2label')
ylabel('Azimuth Angle [deg]')
xlabel('Time [s]')
title(char(strcat("Kite Azimuth Angle from GS for ",speed," m/s")))

% Plot Raft Sway
figure
plot(tsc1.tsc.raft_sway*100)
hold on
plot(tsc2.tsc.raft_sway*100)
legend(tsc1label, tsc2label')
ylabel('Raft Sway, y(t) [cm]')
xlabel('Time [s]')
title(char(strcat("GS Sway for ",speed," m/s")))


% Plot Tether Tension
figure
tension1 = zeros(1,length(tsc1.tsc.gndNodeTenVecs.Data(1,:)));
for i=1:length(tsc1.tsc.gndNodeTenVecs.Data(1,:))
    tension1(i) = norm([tsc1.tsc.gndNodeTenVecs.Data(1,i) ...
                       tsc1.tsc.gndNodeTenVecs.Data(2,i) ...
                       tsc1.tsc.gndNodeTenVecs.Data(3,i)]);
end
tension2 = zeros(1,length(tsc2.tsc.gndNodeTenVecs.Data(1,:)));
for i=1:length(tsc2.tsc.gndNodeTenVecs.Data(1,:))
    tension2(i) = norm([tsc2.tsc.gndNodeTenVecs.Data(1,i) ...
                       tsc2.tsc.gndNodeTenVecs.Data(2,i) ...
                       tsc2.tsc.gndNodeTenVecs.Data(3,i)]);
end
plot(tsc1.tsc.gndNodeTenVecs.Time, tension1)
hold on
plot(tsc2.tsc.gndNodeTenVecs.Time, tension2)
legend(tsc1label, tsc2label')
ylabel('Tension [N]')
xlabel('Time [s]')
title(char(strcat("Tether Tension for ",speed," m/s")))

