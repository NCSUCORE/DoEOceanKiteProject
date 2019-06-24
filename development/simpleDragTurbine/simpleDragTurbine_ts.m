clear
clc
format compact

%% start
% turbine struct
turbine(1).Rturb_cm = [0;10;0];
turbine(1).powerCoeff = 0.5;
turbine(1).dragCoeff = 0.8;
turbine(1).diameter = 1;

turbine(2).Rturb_cm = [0;10;0];
turbine(2).powerCoeff = 0.5;
turbine(2).dragCoeff = 0.8;
turbine(2).diameter = 1;

turbine = reshape(turbine,1,[]);

% other params
V_flow = [1;0;0];
Vbody = [0;0;0];
euler = [0;0;0];

rho_fluid = 1;

% sim('simpleDragTurbine_th')





