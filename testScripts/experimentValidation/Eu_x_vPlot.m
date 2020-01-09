clear
clc
close all
format compact

load 'data_19_Nov_2019_19_08_19.mat' 
vfdReading = 20;
flowSpeed = vfdToFlowSpeed(vfdReading);


set(groot,'defaulttextinterpreter','latex');
set(groot, 'defaultAxesTickLabelInterpreter','latex');
set(groot, 'defaultLegendInterpreter','latex');

% define time to observe 
time = tsc.roll_rad.Time;
tStart = 100; %change to 0 if needed.
tEnd = numel(time);
% tEnd = 15001;
tPlot = tStart:tEnd;
% tend => end;  -- change if needed  

% pre-processing
locs = getFigLocations(1*560,1*420);
fn = 0;
pp{1} = 'rgb';
pp{2} = '-';
lwd = 1;


% % % % Euler angles  
%filter bad data
badData = find(tsc.yaw_rad.Data>100);
tsc.yaw_rad.Data(badData) = 0.5*(tsc.yaw_rad.Data(badData-1) + tsc.yaw_rad.Data(badData+1));

fn = fn + 1;
figure(fn)
set(gcf,'Position',locs(fn,:))

vectorPlotter(time(tPlot),(180/pi)*[tsc.roll_rad.Data(tPlot)';...
    tsc.pitch_rad.Data(tPlot)';...
    tsc.yaw_rad.Data(tPlot)'],pp,...
    {'$\phi$','$\theta$','$\psi$'},'Angle (deg)','');

subplot(3,1,1)
plot(time(tPlot),(180/pi)*tsc.RollSetpoint.Data(tPlot),'k--','linewidth',lwd)
legend('$\phi$','SP')
title('Euler angles')

subplot(3,1,2)
plot(time(tPlot),(180/pi)*tsc.PitchSetpoint.Data(tPlot),'k--','linewidth',lwd)
legend('$\theta$','SP')

% % % % CoM positions 
fn = fn + 1;
figure(fn)
set(gcf,'Position',locs(fn,:));
Rconfluence_o = [-10;0;0];

cmDat = Rconfluence_o + squeeze(tsc.CoMPosVec_cm.data);

vectorPlotter(time(tPlot),cmDat(:,tPlot)./100,pp,...
    {'$x_{cm}$','$y_{cm}$','$z_{cm}$'},'Position (m)','');

subplot(3,1,1)
title('CM position')

% % % % elevation and azimuth angle
elevAngle = (180/pi)*atan2(cmDat(3,:),sqrt(sum(cmDat(1:2,:).^2,1)));
fn = fn+1;
figure(fn)
set(gcf,'Position',locs(fn,:))

% azimuth angle
azimuthAngle = (180/pi)*atan(cmDat(2,:)./cmDat(1,:));

vectorPlotter(time(tPlot),[elevAngle(tPlot);azimuthAngle(tPlot)],pp,...
    {'Elevation','Azimuth'},'Angle (deg)','Other angles');


% % % % Velocity tracking  
Vx = diff(cmDat(1,:))./0.01; 
Vy = diff(cmDat(2,:))./0.01; 
Vz = diff(cmDat(3,:))./0.01; 

windowSize_vel = 20; 
b = (1/windowSize_vel)*ones(1,windowSize_vel);
a = 1;
Vz_f = filter(b,a,Vz);
Vx_f = filter(b,a,Vx);
Vy_f = filter(b,a,Vy);

Vcm = [Vx_f;Vy_f;Vz_f];

fn = fn + 1;
figure(fn)
set(gcf,'Position',locs(fn,:))

vectorPlotter(time(tPlot(1:end-2)),Vcm(:,tPlot(1:end-2))./100,pp,...
    {'$V_{x}$','$V_{y}$','$V_{z}$'},'Velocity (m/s)','');

subplot(3,1,1)
title('CM velocity')


% % % % angle of attack
numPoints = size(Vcm,2);
Vrel = [flowSpeed;0;0] - Vcm;
Vrel_Bdy = NaN*Vrel;
AoA = NaN(numPoints,1);

for ii = 1:numPoints
    [oCb,bCo] = rotation_sequence([tsc.roll_rad.Data(ii);tsc.pitch_rad.Data(ii);...
        tsc.yaw_rad.Data(ii)]);
    Vrel_Bdy(:,ii) = bCo*Vrel(:,ii);
    AoA(ii) = (180/pi)*atan2(Vrel_Bdy(3,ii),Vrel_Bdy(1,ii));
end

fn = fn + 1;
figure(fn)
set(gcf,'Position',locs(fn,:))

vectorPlotter(time(tPlot(1:end-2)),AoA(tPlot(1:end-2)),pp,...
    {'$\alpha$'},'Angle (deg)','Angle of attack');



%% functions

function flowSpeed = vfdToFlowSpeed(vfdHz)
flowSpeed = 0.017*vfdHz - 0.00934;
end

function locs = getFigLocations(figureWidth,figureHeight)
ss = get(0,'ScreenSize');
ss = [ss(3) ss(4)];
fig_wid = figureWidth;
fig_hgt = figureHeight;
max_horz = floor(ss(1)/fig_wid);
max_vert = floor(ss(2)/fig_hgt);
locs = zeros(max_horz*max_vert,4);
kk = 1;
for jj = 1:max_vert
    for ii = 1:max_horz
        locs(kk,:) = [(ii-1)*fig_wid  ss(2)-(1.2*fig_hgt*jj) fig_wid fig_hgt ];
        kk = kk+1;
    end
end
locs = repmat(locs,50,1);

end

function vectorPlotter(time,data,plotProperties,...
    legends,yAxisLabel,figTitle)

pp = plotProperties;

if strcmp(pp{1},'blk')
    colors = 1/255*zeros(8,3);
    
else
    colors = 1/255*[228,26,28
        55,126,184
        77,175,74
        152,78,163
        255,127,0
        255,255,51];
end

lwd = 1;

sdata = squeeze(data);
sz = size(sdata);

if any(sz==1)
    sz(1) = 1;
    sdata = reshape(sdata,1,[]);
end

for ii = 1:sz(1)
    subplot(sz(1),1,ii)
    plot(time,sdata(ii,:),pp{2},'linewidth',lwd,'color',colors(ii,:),...
        'DisplayName',legends{ii})
    if ii == 1
        subplot(sz(1),1,1)
        title(figTitle);
    end
    hold on
    grid on
    xlabel('Time (s)');
    ylabel(yAxisLabel);
    legend('off')
    legend('show')

end


end

function [oCb,bCo] = rotation_sequence(euler_angles)
% ROTATION_SEQUENCE creates the rotation matrices associated with the set
% of Euler angles in the input.  The input is assumed to be a three element
% vector where the first element represents the roll angle, in radians, the
% second element represents the pitch angle, in radians, and the third
% element represents the yaw angle, in radians.
%
%   [oCb,bCo] = ROTATION_SEQUENCE(euler_angles) returns two 3x3 rotation
%   matrices, oCb and bCo.
%
%   Output rotation matrices can be used to rotate a vector represented in
%   the o frame into the b frame, or vice versa.  For a vector, v,
%   represented in the b frame, oCb*v returns the vector represented in the o
%   frame.  For a vector v represented in the o frame, bCo*v returns the
%   vector represented in the b frame.  It is assumed that the b frame is
%   created from the o frame by the following sequence of rotations:
%   1) rotation by euler_angles(3) about z
%   2) rotation by euler_angles(2) about the new y
%   3) rotation by euler_angler(1) about the new z.

% Assign variable names
ph = euler_angles(1);
th = euler_angles(2);
ps = euler_angles(3);

% rotation about X
Rx = [1 0 0; 0 cos(ph) sin(ph); 0 -sin(ph) cos(ph)];

% rotation about Y
Ry = [cos(th) 0 -sin(th); 0 1 0; sin(th) 0 cos(th)];

% rotation about Z
Rz = [cos(ps) sin(ps) 0; -sin(ps) cos(ps) 0; 0 0 1];

bCo = Rx*Ry*Rz;
oCb = transpose(bCo);

end



