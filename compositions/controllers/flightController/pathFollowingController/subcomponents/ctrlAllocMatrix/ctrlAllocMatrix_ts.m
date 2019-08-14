close all
clear
clc

loadComponent('pathFollowingVhcl')

velCMBdy  = 2*[-2 0 -0.1];

% Reasonable range of angular velocites:
angVelBdy = [0 0 0]*pi/180;

velWndBdy = [0 0 0];
momDesBdy = [1e4 0 0];

sim('ctrlAllocMatrix_th')

fprintf('\nControl Surf Deflections\n')
defl.Data(:)
fprintf('\nDesired Moment\n')
momDesBdy(:)
fprintf('\nAchieved Moment\n')
moment.Data(:)
fprintf('\nAbsolute Error\n')
abs(momDesBdy(:)-moment.Data(:))
fprintf('\nPercent Error\n')
100*abs(momDesBdy(:)-moment.Data(:))./momDesBdy(:)