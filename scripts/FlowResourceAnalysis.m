%%  Flow Resource Analysis 
T20 = load('C:\Users\John Jr\Desktop\Manta Ray\Model 9_28\output\Tmax Study\TmaxStudy_20kN.mat');
%%
depth = [300 250 200];
Odepth = [500 450 350];

plotFixedDepthNew(depth,Odepth,T20.flwSpd,T20.R.Pmax*T20.eff,T20.altitude,[0 2])
% plotFixedDepth(depth,Odepth,T38.flwSpd,T38.R.Pmax*T38.eff,T38.altitude,[0 2])
% plotFixedDepth(depth,Odepth,T80.flwSpd,T80.R.Pmax*T80.eff,T80.altitude,[0 2])
%%
plotVariableDepthNew(Odepth,T20.flwSpd,T20.R.Pmax*T20.eff,T20.altitude)
% plotVariableDepth(Odepth,T38.flwSpd,T38.R.Pmax*T38.eff,T38.altitude)
% plotVariableDepth(Odepth,T80.flwSpd,T80.R.Pmax*T80.eff,T80.altitude)

%%
M1 = ENV.Manta(1);   M2 = ENV.Manta(2);   M3 = ENV.Manta(3);   M4 = ENV.Manta(4);
M5 = ENV.Manta(5);   M6 = ENV.Manta(6);   M7 = ENV.Manta(7);   M8 = ENV.Manta(8);
M9 = ENV.Manta(9);   M10 = ENV.Manta(10); M11 = ENV.Manta(11); M12 = ENV.Manta(12);
