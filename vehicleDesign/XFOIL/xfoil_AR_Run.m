% clearvars;
% clc;
% % % Required Inputs
% *.dat file Airfoil geometry
% gdes flap location in terms of 0 to 1 (1 = trailing edge)
% Aspect Ratio
% cd0 (zero lift uncorrected drag coefficient [parasitic drag])
% e   (oswald efficiency factor)
%% INPUTS if desired to write as a function::::
coord = load('NACA0015_geom.dat');  %Load Airfoil geometry *.dat file
flap_loc = 0.75;
AR = 4.166;%wing 11.1, hstab 6.84, vstab 4.17
cd0 = 0.0074;%EPP552:0.0077, ClarkY:0.0088,GOE655:0.012,EPP1098:0.0103,EPPLER856:0.0095,NACA2412:0.0093 NACA0015:0.0074
e = 0.87;%From Oswald factor function ~cd0~0.0076
H_stab_inc = 1.5;% Degree Offset
%%
AoA = linspace(-20,20,81);          %Specify angle of attack array, note xfoil can't converge large AoA
% Run xfoil for airfoil: See xfoil.m for detailed notes
   [pol,foil] = xfoil(coord,AoA,0.7e6,0.0,'panels n 200','oper iter 200','oper/vpar n 5','oper/vpar XTR 1.0 1.0');
% Run xfoil for airfoil with flap deflection
s1 = {'gdes flap '};s2 = {' 0 1 exec'};
flap_string = char(strcat(s1,{' '},num2str(flap_loc),s2));
   [pol_flap,foil_flap] = xfoil(coord,AoA,0.7e6,0.0,flap_string,'panels n 200','oper iter 200','oper/vpar n 5');
%% Hack for full -180 to 180 alpha polar from QBlade
% Full180 = load('NACA2412_full.dat');
% pol.alpha = Full180(:,1);
% pol.CL = Full180(:,2);
% pol.CD = Full180(:,3);
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
alfa_c =alfa;CD_c = CD;cl_c =cl;
% foil with flap
alfaf = pol_flap.alpha; clf = pol_flap.CL/(1+2/AR); cdf = pol_flap.CD;
CD_inducedf = clf.^2/(pi*e*AR);
CDf = cdf+CD_inducedf;
alfa_fc =alfa;CD_fc = CDf;cl_fc =clf;
% figure (1)
% hold on
% plot(pol.alpha,pol.CL,'-b')
% plot(Full180(:,1),Full180(:,2),'-r')


regval = 36;%Since we know what the middle roughly is as all arrays are length 71; this will only be for positive AoA
yy1_cl = cl_fc-cl_c;
P_cl = polyfit(alfa_c(regval:end),yy1_cl(regval:end),1);
yfit_cl = P_cl(1)*alfa_c(regval:end)+P_cl(2);
% scatter(alfa_c(regval:end),yy1_cl(regval:end),25,'b','*') 
% hold on
% plot(alfa_c(regval:end),yfit_cl,'r-.');

yy1_cd = CD_fc-CD_c;
    P_cd = polyfit(alfa_c(regval:end),yy1_cd(regval:end),1);
    yfit_cd = P_cd(1)*alfa_c(regval:end)+P_cd(2);

CL_gain = [P_cl,0];
CD_gain = [P_cd,0];
% ************************************************************ ONLY USE FOR HSTAB
% % % alfa_c = alfa_c - H_stab_inc;
% ************************************************************ ONLY USE FOR HSTAB

% decay = load('SG6040_50k_N9.dat');
figure;hold on;grid on;
% plot(decay(:,1),decay(:,2),'k-')
plot(alfa_c,pol.CL,'r-')
plot(alfa_c,cl_c,'b-');  xlabel('alpha [deg]');  ylabel('$\mathrm{CL}$');
set(gca,'XLim',[-20,20]);
% title('Stabilizer: NACA 0015 Lift Coefficient');
% print('Stab_XFOIL_CL_0015','-dpng','-r600')


figure;hold on;grid on;
plot(alfa_c,pol.CD,'b-')
plot(alfa_c,CD_c,'r-');  xlabel('alpha [deg]');  ylabel('$\mathrm{CD}$');  
% title('Stabilizers: NACA 0015 Drag Coefficient');
% print('Stab_XFOIL_CD_0015','-dpng','-r600')


% save('NACA0015_9_30_AR4_Vstab.mat','alfa_c','cl_c','CD_c','alfa_fc','cl_fc','CD_fc','CL_gain','CD_gain');%or Function output
fullpolar2 = [alfa_c, cl_c,CD_c];