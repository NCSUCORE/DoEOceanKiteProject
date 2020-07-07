clear; clc;
format compact;
set(groot,'defaulttextinterpreter','latex');  
set(groot, 'defaultAxesTickLabelInterpreter','latex');  
set(groot, 'defaultLegendInterpreter','latex');

%% initialize some values
% lift by drag ratio
LbyD = 10;
gamma = atan(1/LbyD);

% flow speed
vf = 2;
  
% calculate vk for kite going upwind (see derivation)
vkEqnUpwind = @(vf,phi,gamma) vf*sin(0.5*pi - phi - gamma)/sin(gamma);

% calculate vk for kite going downwind (see derivation)
vkEqnDownwind = @(vf,phi,gamma) vf*((cos(phi)/tan(gamma)) + sin(phi));


%% loop through azimuth angles
% azimuth
% phi = 0*pi/180;
phi = (pi/180)*linspace(0,90,100);

vkUpwind = NaN*phi;
vkDownwind = NaN*phi;

for ii = 1:length(phi)
        
% evaluate vk/vf
vkUpwind(ii) = vkEqnUpwind(vf,phi(ii),gamma)/vf;
vkDownwind(ii) = vkEqnDownwind(vf,phi(ii),gamma)/vf;

end
%% plots
figure(1)
figProps = gcf;
set(gcf,'Position',[figProps.Position(1:2).*[1 0.25] 560*2 420])

ax1 = subplot(1,2,1);
plot(phi*180/pi,vkUpwind,'linewidth',1)
grid on
hold on
xlabel('Azimuth angle (deg)')
ylabel('$V_{k}/V_{f}$')
title('Upwind')
legend

ax2 = subplot(1,2,2);
plot(phi*180/pi,vkDownwind,'linewidth',1)
grid on
hold on
xlabel('Azimuth angle (deg)')
ylabel('$V_{k}/V_{f}$')
title('Downwind')
legend

linkaxes([ax1,ax2],'xy');

set(findobj('-property','FontSize'),'FontSize',11)



