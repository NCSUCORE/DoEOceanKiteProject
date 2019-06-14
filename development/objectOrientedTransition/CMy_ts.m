close all
clear
clc
load('dsgnAyaz1_2D_Lookup.mat')

alphaDeg = 5;
betaDeg  = 0;

val    = Cmtot_2D_Tbl.Table.Value;
alphas = Cmtot_2D_Tbl.Breakpoints(1).Value;
betas  = 1.1*Cmtot_2D_Tbl.Breakpoints(2).Value;

sim('CMy_th')

simout.Data

simout1.Data

% avlBuild_2D_LookupTable(saveFileName,aeroResults)
% Cmtot_2D_Tbl.Breakpoints(1).Value = Cmtot_2D_Tbl.Breakpoints(1).Value*1.1
interp2(Cmtot_2D_Tbl.Breakpoints(1).Value,Cmtot_2D_Tbl.Breakpoints(2).Value,Cmtot_2D_Tbl.Table.Value',alphaDeg,betaDeg)
