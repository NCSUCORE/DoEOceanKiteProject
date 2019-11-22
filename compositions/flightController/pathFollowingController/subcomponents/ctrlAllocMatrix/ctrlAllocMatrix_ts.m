
close all;clear;clc;format compact

% Load the aerodynamics that we need
loadComponent('pathFollowingVhcl')

%% Test 1: zero ang vel, different apparent winds
% Set velocity in the body frame
velCMBdy  = [0 0 0];

% Set the angular velocity
angVelBdy = [0 0 0]*pi/180;

% Set the velocity of the wind in the body frame
% a = linspace(-10,10,10)*pi/180;
a = 0;
% b = linspace(-10,10,10)*pi/180;
b = 0;
% v = linspace(2,10,5);
v = 10;
windVec = [];
for ii = 1:numel(a)
    for jj = 1:numel(b)
        for kk = 1:numel(v)
           vx = v(kk)*cos(a(ii))*cos(b(jj));
           vz = -v(kk)*tan(a(ii));
           vy = v(kk)*sin(b(jj));
           windVec = [windVec;vx vy vz];
        end
    end
end
% x = zeros([size(windVec,1),1]);
% quiver3(x,x,x,windVec(:,1),windVec(:,2),windVec(:,3))
% daspect([1 1 1])
% xlabel('x')
% ylabel('y')

% Set the desired moment vector (points on spheres)
r = linspace(1000,1e6,5); % Radius
% r = 1e4;
theta = linspace(-pi,pi,9); % Azimuth
% theta = -pi/4;
theta = theta(1:end-1);
% phi = pi/2;
phi   = linspace(0,pi,5); % Zenith

momVec = [];
for ii = 1:numel(r)
    for jj = 1:numel(theta)
        for kk = 1:numel(phi)
            momVec = [momVec;...
                r(ii)*cos(theta(jj))*sin(phi(kk))...
                r(ii)*sin(theta(jj))*sin(phi(kk))...
                r(ii)*cos(phi(kk))];
        end
    end
end

% Squish the z moment down to account for the fact that we can't really
% generate more than about 3600 Nm in yaw
momVec(:,3) = momVec(:,3).*(3600./max(momVec(:,3)));

data=[];
for ii = 1:size(momVec,1)
    data = [data; repmat(momVec(ii,:),[size(windVec,1) 1]) windVec(:,:)];
end

momVec = data(:,1:3);
windVec = data(:,4:end);
timeVec = 0:1:size(momVec,1)-1;

momVec = timeseries(momVec,timeVec);
windVec = timeseries(windVec,timeVec);

vhcl.portWing.MaxCtrlDeflDn.setValue(-inf,'deg')
vhcl.portWing.MaxCtrlDeflUp.setValue(inf,'deg')
vhcl.stbdWing.MaxCtrlDeflDn.setValue(-inf,'deg')
vhcl.stbdWing.MaxCtrlDeflUp.setValue(inf,'deg')
vhcl.hStab.MaxCtrlDeflDn.setValue(-inf,'deg')
vhcl.hStab.MaxCtrlDeflUp.setValue(inf,'deg')
vhcl.vStab.MaxCtrlDeflDn.setValue(-inf,'deg')
vhcl.vStab.MaxCtrlDeflUp.setValue(inf,'deg')

% Run the simulation
sim('ctrlAllocMatrix_th')
%% Plot results
figure('Position',[0.0005    0.0380    0.4990    0.8833])
subplot(3,1,1)
loglog(e1Mag.Data)
subplot(3,1,2)
loglog(e2Mag.Data)
subplot(3,1,3)
loglog(e3Mag.Data)
linkaxes(findall(gcf,'Type','axes'),'xy')


figure('Position',[0.5005    0.0380    0.4990    0.8833])
subplot(3,1,1)
plot(squeeze(e1Rel.Data(1,:,:)))
subplot(3,1,2)
plot(squeeze(e1Rel.Data(2,:,:)))
subplot(3,1,3)
plot(squeeze(e1Rel.Data(3,:,:)))
linkaxes(findall(gcf,'Type','axes'),'xy')

figure('Position',[1.0005    0.0380    0.4990    0.8833])
subplot(3,1,1)
plot(squeeze(e2Rel.Data(1,:,:)))
subplot(3,1,2)
plot(squeeze(e2Rel.Data(2,:,:)))
subplot(3,1,3)
plot(squeeze(e2Rel.Data(3,:,:)))
linkaxes(findall(gcf,'Type','axes'),'xy')

figure('Position',[1.5005    0.0380    0.4990    0.8833])
subplot(3,1,1)
plot(squeeze(e3Rel.Data(1,:,:)))
subplot(3,1,2)
plot(squeeze(e3Rel.Data(2,:,:)))
subplot(3,1,3)
plot(squeeze(e3Rel.Data(3,:,:)))
linkaxes(findall(gcf,'Type','axes'),'xy')

%%
idx = 163;
fprintf('\n-----Wind Vector-----\n')
windVec.Data(idx,:)
fprintf('\n-----Desired M-----\n')
momVec.Data(idx,:)
fprintf('\n-----Method 1 d, M-----\n')
d1.Data(idx,:)
m1.Data(idx,:)
fprintf('Method 2 d, M\n')
d2.Data(idx,:)
m2.Data(idx,:)
fprintf('Method 3 d, M\n')
d3.Data(idx,:)
m3.Data(idx,:)
fprintf('Method 4 d, M\n')
d4.Data(idx,:)
m4.Data(idx,:)