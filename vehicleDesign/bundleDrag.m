% Drag coefficient estimation for the VX Aero kite connector wires
% clear all
% close all
% Params
h = [61 195 265 255]*1e-3;     % Bundle height
w = [19 8 16 16]*1e-3;         % Bundle width
cg2fus = 31.8e-3;              % Distance from CG to fuselage shell
z = [0 h(1) 0 0] + h/2 + cg2fus; % Distance from fuselage to bundle AC
Cd = [1 1 1 1];          % Bundle drag coefficient
wake = [1 1 .5 .25];
% Reference area, etc.
% S = 0.4;     % Semispan
% c = 1125e-3; % Mean chord
rho = 1000;  % Water density
% Drag force
V = transpose(linspace(0,1,101));
for i = 1:4
    fDrag(:,i) = 1/2*rho*(V*wake(i)).^2*w(i)*h(i);
    mDrag(:,i) = fDrag(:,i).*z(i);
end
figure; hold on; grid on;
plot(V,fDrag)
plot(V,sum(fDrag,2),'r','LineWidth',1.5)
title 'Individual Bundle Drag'
xlabel 'Flow (m/s)'
ylabel 'Drag (N)'
legend('Bridle','Ascending Tether','Descending Tether','Servo','Total')

figure; hold on; grid on;
plot(V,mDrag)
plot(V,sum(mDrag,2),'r','LineWidth',1.5)
title 'Total Bundle Drag Pitching Moment'
xlabel 'Flow [m/s]'
ylabel 'Pitching Moment [N-m]'
legend('Bridle','Ascending Tether','Descending Tether','Servo','Total')