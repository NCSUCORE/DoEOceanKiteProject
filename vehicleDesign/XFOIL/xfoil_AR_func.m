function xfoil_out = xfoil_AR_func(xfoil_in)
% % % Required Inputs
% *.dat file Airfoil geometry
% gdes flap location in terms of 0 to 1 (1 = trailing edge)
% Aspect Ratio
% cd0 (zero lift uncorrected drag coefficient [parasitic drag])
% e   (oswald efficiency factor)
%% INPUTS if desired to write as a function::::
coord = load(xfoil_in.airfoil_geom);  %Load Airfoil geometry *.dat file 'NACA0015_geom.dat'
flap_loc = xfoil_in.flap_loc;
AR = xfoil_in.AR;%wing 11.1, hstab 6.84, vstab 4.17
cd0 = xfoil_in.cd0;%EPP552:0.0077, ClarkY:0.0088,GOE655:0.012,EPP1098:0.0103,EPPLER856:0.0095,NACA2412:0.0093 NACA0015:0.0074
e = xfoil_in.oswald;%From Oswald factor function ~cd0~0.0076
Re = xfoil_in.Re; % Reynolds number
%%
AoA = linspace(-20,20,81);          %Specify angle of attack array, note xfoil can't converge large AoA
% Run xfoil for airfoil: See xfoil.m for detailed notes
[pol,~] = xfoil(coord,AoA,Re,0.0,'panels n 200','oper iter 200','oper/vpar n 5','oper/vpar XTR 1.0 1.0');
% Run xfoil for airfoil with flap deflection
s1 = {'gdes flap '};s2 = {' 0 1 exec'};
flap_string = char(strcat(s1,{' '},num2str(flap_loc),s2));
[pol_flap,~] = xfoil(coord,AoA,Re,0.0,flap_string,'panels n 200','oper iter 200','oper/vpar n 5');
%% Resize vectors to match simulation requirements: Length 71
rangeval = (length(pol.CL));
rangevalf = (length(pol_flap.CL));
%
vvvv = linspace(1,rangeval,71);
xxxx = linspace(1,rangeval,rangeval);
pol.CL = interp1(xxxx,pol.CL,vvvv)';
pol.alpha = interp1(xxxx,pol.alpha,vvvv)';
pol.CD = interp1(xxxx,pol.CD,vvvv)';
%
vvvvf = linspace(1,rangevalf,71);
xxxxf = linspace(1,rangevalf,rangevalf);
pol_flap.CL = interp1(xxxxf,pol_flap.CL,vvvvf)';
pol_flap.alpha = interp1(xxxxf,pol_flap.alpha,vvvvf)';
pol_flap.CD = interp1(xxxxf,pol_flap.CD,vvvvf)';
%% Prandtl Lifting Line Theory Aspect Ratio (AR) Correction
alfa = pol.alpha; cl = pol.CL/(1+2/AR); cd = pol.CD;
CD_induced = cl.^2/(pi*e*AR);
CD = cd+CD_induced;
alfa_c =alfa;CD_c = CD;CL_c =cl;
% foil with flap
alfaf = pol_flap.alpha; clf = pol_flap.CL/(1+2/AR); cdf = pol_flap.CD;
CD_inducedf = clf.^2/(pi*e*AR);
CDf = cdf+CD_inducedf;
alfa_fc =alfaf;CD_fc = CDf;cl_fc =clf;

% Gain linear fit: Flap - No Flap for 1 Degree Flap Deflection
regval = 36;%Since we know what the middle roughly is as all arrays are length 71; this will only be for positive AoA
yy1_cl = cl_fc-CL_c;
P_cl = polyfit(alfa_c(regval:end),yy1_cl(regval:end),1);
% yfit_cl = P_cl(1)*alfa_c(regval:end)+P_cl(2);

yy1_cd = CD_fc-CD_c;
P_cd = polyfit(alfa_c(regval:end),yy1_cd(regval:end),1);
% yfit_cd = P_cd(1)*alfa_c(regval:end)+P_cd(2);

CL_gain = [0,P_cl(2),P_cl(1)];%Format to match sim quadratic fit method
CD_gain = [0,P_cd(2),P_cd(1)];
% % % *********************************************************************
xfoil_out.alfa_c = alfa_c;
xfoil_out.CL_c = CL_c;
xfoil_out.CD_c = CD_c;
xfoil_out.CL_gain = CL_gain;
xfoil_out.CD_gain = CD_gain;
end