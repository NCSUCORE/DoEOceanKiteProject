% post processing
% close all
set(groot,'defaulttextinterpreter','latex');  
set(groot, 'defaultAxesTickLabelInterpreter','latex');  
set(groot, 'defaultLegendInterpreter','latex');

%% colors and linewidth
red = 1/255*[228,26,28];
black = 1/255*[0,0,0];
line_wd = 1;

% % % parse the logged data signals
parseLogsout

%% Scale factors
Lscale = lengthScaleFactor;
Dscale = densityScaleFactor;

% % % extract the important variables into dummy variables
time = tsc.positionVec.Time.*(1/Lscale^0.5);
sol_Rcm_o = squeeze(tsc.positionVec.Data).*(1/Lscale);
sol_Vcmo = squeeze(tsc.velocityVec.Data).*(1/Lscale^0.5);
sol_euler = squeeze(tsc.eulerAngles.Data);
sol_OwB = squeeze(tsc.angularVel.Data).*(Lscale^0.5);

%% plot states
plotProps{1} = 'rgb';
if Lscale == 1 && Dscale == 1
    plotProps{2} = '-';
elseif Lscale ~= 1 && Dscale == 1
    plotProps{2} = '--';
elseif Lscale == 1 && Dscale ~= 1
    plotProps{2} = ':';
elseif Lscale ~= 1 && Dscale ~= 1
    plotProps{2} = '.-';
end

ss = get(0,'ScreenSize');
ss = [ss(3) ss(4)];
fig_wid = 1.5*560;
fig_hgt = 1.5*420;
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
locs = repmat(locs,5,1);

% % % cm position and set points
fn = 1;
figure(fn);
set(gcf,'Position',locs(fn,:))
vectorPlotter(time,sol_Rcm_o,plotProps,...
    {'$x_{cm}$','$y_{cm}$','$z_{cm}$'},'Position (m)','CM position');
% subplot(3,1,3)


% % % % cm velocity
% fn = fn+1;
% figure(fn)
% set(gcf,'Position',locs(fn,:))
% vectorPlotter(time,sol_Vcmo,plotProps,...
%     {'$V_{x}$','$V_{y}$','$V_{z}$'},'Velocity (m/s)','CM velocity');
% 
% % % euler angles
fn = fn+1;
figure(fn)
set(gcf,'Position',locs(fn,:))
vectorPlotter(time,sol_euler*180/pi,plotProps,...
    {'$\phi$','$\theta$','$\psi$'},'Angle (deg)','Euler Angles');
% % % setpoints
if Lscale == 1 && Dscale == 1
subplot(3,1,1)
plot(time,squeeze(tsc.rollSetpoint.Data),'k--',...
    'DisplayName','$\phi_{sp}$');
subplot(3,1,2)
plot(time,squeeze(tsc.pitchSetpoint.Data),'k--',...
    'DisplayName','$\theta_{sp}$');
subplot(3,1,3)
plot(time,squeeze(tsc.yawSetpoint.Data),'k--',...
    'DisplayName','$\theta_{sp}$');
end
% %% other angles
% % elevation angle
% elevAngle = (180/pi)*atan2(sol_Rcm_o(3,:),sqrt(sum(sol_Rcm_o(1:2,:).^2,1)));
% fn = fn+1;
% figure(fn)
% set(gcf,'Position',locs(fn,:))
% 
% % azimuth angle
% azimuthAngle = (180/pi)*atan2(sol_Rcm_o(2,:),sol_Rcm_o(1,:));
% 
% vectorPlotter(time,[elevAngle;azimuthAngle],plotProps,...
%     {'Elevation','Azimuth'},'Angle (deg)','Other angles');
% % 
% % % % % angular velocities
% % fn = fn+1;
% % figure(fn)
% % set(gcf,'Position',locs(fn,:))
% % vectorPlotter(time,sol_OwB,plotProps,...
% %     {'$\omega_{x}$','$\omega_{y}$','$\omega_{z}$'},'Ang vel (rad/s)','Angular velocities');
% 
% 
% %% plot control signals
% fn = fn+1;
% figure(fn)
% set(gcf,'Position',locs(fn,:))
% vectorPlotter(time,tsc.thrReleaseSpeeds.Data'.*(1/Lscale^0.5),plotProps,...
%     {'$u_{port}$','$u_{aft}$','$u_{stbd}$'},'Speed (m/s)','Tether release speeds');
% 
% 
% fn = fn+1;
% figure(fn)
% set(gcf,'Position',locs(fn,:))
% vectorPlotter(time,squeeze(tsc.tetherLengths.Data).*(1/Lscale),plotProps,...
%     {'$L_{port}$','$L_{aft}$','$L_{stbd}$'},'Length (m)','Tether lengths');
% % 
% 
% fn = fn+1;
% figure(fn)
% set(gcf,'Position',locs(fn,:))
% vectorPlotter(time,tsc.ctrlSurfDeflection.Data',plotProps,...
%     {'$\delta_{port-alrn}$','$\delta_{stbd-alrn}$','$\delta_{elevator}$','$\delta_{rudder}$'},...
%     'Angle (deg)','Control surface defelctions');



%% local forces
% % % angle of attack
% fn = fn+1;
% figure(fn)
% set(gcf,'Position',locs(fn,:))
% vectorPlotter(time,squeeze(tsc.alphaLocal.Data),plotProps,...
%     {'Port wing','Stbd wing','H-stab','V-stab'},...
%     'Angle (deg)','Angle of attack');
% 
% fn = fn+1;
% figure(fn)
% set(gcf,'Position',locs(fn,:))
% vectorPlotter(time,squeeze(tsc.CL.Data),plotProps,...
%     {'Port wing','Stbd wing','H-stab','V-stab'},...
%     'CL','Lift coefficient');
% 
% fn = fn+1;
% figure(fn)
% set(gcf,'Position',locs(fn,:))
% vectorPlotter(time,squeeze(tsc.CD.Data),plotProps,...
%     {'Port wing','Stbd wing','H-stab','V-stab'},...
%     'CD','Drag coefficient');
% 
    
%% plot forces
% % % % fluid forces
% fn = fn+1;
% figure(fn)
% set(gcf,'Position',locs(fn,:))
% vectorPlotter(time,squeeze(tsc.FFluidBdy.Data).*(1/Lscale^3),plotProps,...
%     {'$F_{x}$','$F_{y}$','$F_{z}$'},'Force (N)','Fluid forces');
% 
% % % % gravity forces
% fn = fn+1;
% figure(fn)
% set(gcf,'Position',locs(fn,:))
% vectorPlotter(time,squeeze(tsc.FGravBdy.Data).*(1/Lscale^3),plotProps,...
%     {'$F_{x}$','$F_{y}$','$F_{z}$'},'Force (N)','Gravity forces');
% 
% % % % buoyancy forces
% fn = fn+1;
% figure(fn)
% set(gcf,'Position',locs(fn,:))
% vectorPlotter(time,squeeze(tsc.FBuoyBdy.Data).*(1/Lscale^3),plotProps,...
%     {'$F_{x}$','$F_{y}$','$F_{z}$'},'Force (N)','Buoyancy forces');
% 
% % % % tether forces
% fn = fn+1;
% figure(fn)
% set(gcf,'Position',locs(fn,:))
% vectorPlotter(time,squeeze(tsc.FThrNetBdy.Data).*(1/Lscale^3),plotProps,...
%     {'$F_{x}$','$F_{y}$','$F_{z}$'},'Force (N)','Tether forces');
% 
% % % % total forces
% fn = fn+1;
% figure(fn)
% set(gcf,'Position',locs(fn,:))
% vectorPlotter(time,squeeze(tsc.FNetBdy.Data).*(1/Lscale^3),plotProps,...
%     {'$F_{x}$','$F_{y}$','$F_{z}$'},'Force (N)','Total forces');




