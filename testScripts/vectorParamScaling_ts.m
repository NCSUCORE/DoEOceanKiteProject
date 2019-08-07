% Script to test if scaling of vector-valued parameters works when the
% elements of the vector have different units
clc
sf = 0.1; % Scale factor
x = SIM.parameter('Value',[1 2 3],'Unit','[m s m/s]');
x.scale(sf,1)

fprintf('Automatically calculated value:\n')
x.Value
fprintf('Hand calculated value:\n')
[1*sf 2*sqrt(sf) 3*sqrt(sf)]