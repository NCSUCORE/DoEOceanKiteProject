clear
clc
format compact

loadComponent('pathFollowingVhclForComp')

gndStn = vhcl;

vhcl.scale(20,1);
GROUNDSTATION         = 'groundStation002';

%% save file in its respective directory
saveBuildFile('gndStn',mfilename,'variant','GROUNDSTATION');



