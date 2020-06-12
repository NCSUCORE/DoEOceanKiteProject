%   Matlab help: https://www.mathworks.com/help/matlab/network-common-data-form.html
ncdisp('region2km_2017010100_t001_Navatek_wvel.nc')                         %   Displays contents of the NetCDF file
x = ncinfo('region2km_2017010100_t001_Navatek_wvel.nc')                         %   Displays contents of the NetCDF file
depth = ncread('region2km_2017010100_t001_Navatek_uvel.nc','depth');        %   Should be the same for each velocity component
uvel = ncread('region2km_2017010100_t001_Navatek_uvel.nc','water_uvel');    %   u-velocity
vvel = ncread('region2km_2017010100_t001_Navatek_vvel.nc','water_vvel');    %   v-velocity
wvel = ncread('region2km_2017010100_t001_Navatek_wvel.nc','water_wvel');    %   w-velocity