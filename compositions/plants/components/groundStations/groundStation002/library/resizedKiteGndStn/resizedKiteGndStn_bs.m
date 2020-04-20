clear
clc
format compact

loadComponent('fullScale1Thr')

gndStn = vhcl;

vhcl.scale(20,1);
GROUNDSTATION         = 'groundStation002';

%% save file in its respective directory
saveBuildFile('gndStn',mfilename,'variant','GROUNDSTATION');



