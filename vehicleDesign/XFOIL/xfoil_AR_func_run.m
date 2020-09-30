% % % Sample run file for Simulation Surfaces
% Run in place of AVL or XFLR5
% If using Gains, note that they are 2D and would need to be scaled for
% what percent span the flap occupies 

xfoil_in.airfoil_geom = 'NACA2412_geom.dat';
xfoil_in.flap_loc     = 0.75;
xfoil_in.AR           = 7.0;
xfoil_in.cd0          = 0.0093;%EPP552:0.0077, ClarkY:0.0088,GOE655:0.012,EPP1098:0.0103,EPPLER856:0.0095,NACA2412:0.0093 NACA0015:0.0074
xfoil_in.oswald       = 0.87;
xfoil_in.Re           = 1.0e6;

xfoil_Wing = xfoil_AR_func(xfoil_in);


xfoil_in.airfoil_geom = 'NACA0015_geom.dat';
xfoil_in.flap_loc     = 0.75;
xfoil_in.AR           = 8.333;
xfoil_in.cd0          = 0.0093;
xfoil_in.oswald       = 0.9;
xfoil_in.Re           = 0.7e6;

xfoil_Hstab = xfoil_AR_func(xfoil_in);


xfoil_in.airfoil_geom = 'NACA0015_geom.dat';
xfoil_in.flap_loc     = 0.75;
xfoil_in.AR           = 4.166;
xfoil_in.cd0          = 0.0093;
xfoil_in.oswald       = 0.92;
xfoil_in.Re           = 0.7e6;

xfoil_Vstab = xfoil_AR_func(xfoil_in);