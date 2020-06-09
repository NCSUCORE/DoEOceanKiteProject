close all;clear;clc

load('dsgnTest_1_lookupTables.mat')

alpha = 0;
beta  = 0;

defls = linspace(-30,30,10);

for ii = 1:length(defls)
    defl = defls(ii);
    
    sim('avlAerodynamics2D_th')
    scatter(defl,CMx.Data)
    hold on
    grid on
end

