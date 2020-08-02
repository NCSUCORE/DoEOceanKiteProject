function [x,us_eq, ls_eq] = airfoil_data()
% clc; clear all;
Lscale = 1;
% AirfoilData = readtable('seligdatfile.txt'); 
AirfoilData = readtable('aftools2412_12per.txt'); 
Airfoil = table2array(AirfoilData);

PositiveY = find(Airfoil(:,2)>0);
NegativeY = find(Airfoil(:,2)<=0);

x = linspace(0,1,101); 

% Upper surface 
us = Airfoil(PositiveY,:); 
us_x = us(:,1); 
us_y = us(:,2); 
options = fitoptions('poly9', 'Robust', 'Bisquare');
fitus = fit(us_x,us_y,'poly9',options); 

% Equation for upper surface
us_eq = fitus.p1.*x.^9 + fitus.p2.*x.^8 + fitus.p3.*x.^7 + fitus.p4.*x.^6 + fitus.p5.*x.^5 ...
    + fitus.p6.*x.^4 + fitus.p7.*x.^3 + fitus.p8.*x.^2 + fitus.p9.*x + fitus.p10 ; 


% Lower surface 
ls = Airfoil(NegativeY,:); 
ls_x = ls(:,1); 
ls_y = ls(:,2); 
options = fitoptions('poly9', 'Robust', 'Bisquare');
fitls = fit(ls_x,ls_y,'poly9',options); 

% Equation for lower surface
ls_eq = fitls.p1.*x.^9 + fitls.p2.*x.^8 + fitls.p3.*x.^7 + fitls.p4.*x.^6 + fitls.p5.*x.^5 ...
    + fitls.p6.*x.^4 + fitls.p7.*x.^3 + fitls.p8.*x.^2 + fitls.p9.*x + fitls.p10 ; 

% Plot (sanity check) 
% figure(1); 
% plot(x,us_eq); hold on; 
% plot(x,ls_eq);
% plot(x*Lscale,us_eq*Lscale); 
% plot(x*Lscale,ls_eq*Lscale);
% 
% ylim([-0.5 0.5]) ;
% xlim([-0.1 2.1]) ;



end

