% u = .99; df_b = 0.04;
% 
%       ARx = linspace(0,12,25);
%       [CD0,AR] = meshgrid([.0076 .01 .015 .02 .025],ARx);
%       e = oswaldfactor(AR,0,'shevell',CD0,df_b,u);
%       plot(ARx,e); axis([0 12 .6 1]); grid on
%       xlabel('Aspect Ratio'); ylabel('Oswald efficiency factor, e')
%       legend('.0076', '$C_{D,0}$ = 0.01','0.015','0.02','0.025')
%       text(8.5,.63,'u = 0.99    s = 0.975')
% 
%       sweepx = linspace(0,40,41);
%       [AR,sweep] = meshgrid([4;8;12],sweepx*pi/180);
%       e = oswaldfactor(AR,sweep,'shevell',0,df_b,u)./...
%           oswaldfactor(AR,  0  ,'shevell',0,df_b,u);
%       axes('pos',[0.25 0.25 0.3 0.25]);
%       plot(sweepx,e); axis([0 40 .9 1.02]); grid on
%       xlabel('Sweep, $\Lambda$ (deg)'); ylabel('e$_\Lambda$/e$_\Lambda=0$')
%       legend('AR = 4','8','12','Location','SouthWest')
%%

CL_alfa = pi*10/(1+sqrt(1+10^2/4));
CL_alfa2 = 2*pi*10/12;

%%
AR = 10;

airfoil = load('GOE655.dat');
alfa = airfoil(:,1);
cl = airfoil(:,2)*(AR/(AR+2));%High AR correction (above AR~7)
cd = airfoil(:,3);

cd0 = 0.012;%EPP552:0.0077, ClarkY:0.0088,GOE655:0.012,EPP1098:0.0103,EPPLER856:0.0095,NACA2412:0.0093

e = 0.9;%From Oswald factor function ~cd0~0.0076
CD_induced = cl.^2/(pi*e*AR);
CD = cd0+CD_induced;

% figure (2)
% hold on
% plot(alfa,CD,'b')
% plot(alfa,cd,'r')
% plot(alfa,CD_induced,'m')
% xlim([-5 25])
% 
% figure (3)
% hold on
% plot(alfa,cl,'b')
% xlim([-5 25])

% CL3 = (cl.^3);
% CD2 = CD.^2;
% CL3_CD2 = CL3./CD2;
% CL_CD = cl./CD;
% figure (3)
% hold on
% plot(alfa,CL3_CD2,'r')
% plot(alfa,CL_CD,'r')
% xlim([-10 30])
% xlabel('AoA [deg]','Fontsize',18);ylabel('Cl^3/CD^2','Fontsize',18);

alfa_c =alfa;
CD_c = CD;
cl_c =cl;

save('GOE655_corrected.mat','alfa_c','cl_c','CD_c');











