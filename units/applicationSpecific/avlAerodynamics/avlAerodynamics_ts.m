
clc
format compact

uAppBdy = [5 0 -1];
dynPress = 1;
flpDefl_deg = 0;
ailDefl_deg = 0;
elevDefl_deg = 0;
rudDefl_deg = 0;

refArea = 1;

sim('avlAerodynamics_th')
fprintf('\nThis should be zero:\n')
dot(uAppBdy,FLift.Data)
fprintf('\nThis should be [0 1 0]\n')
cross(FLift.Data,uAppBdy)./norm(cross(FLift.Data,uAppBdy))