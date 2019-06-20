% close all;
clear;clc;format compact;fclose all;
set(groot,'defaulttextinterpreter','latex');
set(groot, 'defaultAxesTickLabelInterpreter','latex');
set(groot, 'defaultLegendInterpreter','latex');


% create sample design
dsgnTest_1 = avlDesignGeometryClass;

%% modify design
% wing parameters
% Input file names
dsgnTest_1.input_file_name        = 'dsgnTest_1.avl'; % File name for .avl file
dsgnTest_1.run_file_name          = 'testRunFile.run';
dsgnTest_1.exe_file_name          = 'exeFile';
% Output file names
dsgnTest_1.result_file_name       = 'dsgnTest_1_results';
dsgnTest_1.lookup_table_file_name = 'dsgnTest_1_lookupTables';

% Name for design in the input file
dsgnTest_1.design_name            = 'dsgnTest_1'; % String at top of input file defining the name

dsgnTest_1.reference_point = [0.0;0;0];

dsgnTest_1.wing_chord = 1;
dsgnTest_1.wing_AR = 10;
dsgnTest_1.wing_sweep = 5;
dsgnTest_1.wing_dihedral = 0;
dsgnTest_1.wing_TR = 0.8;
dsgnTest_1.wing_incidence_angle = 0;
dsgnTest_1.wing_naca_airfoil = '2412';
dsgnTest_1.wing_airfoil_ClLimits = [-1.7 1.7];

dsgnTest_1.wing_Nspanwise = 20;
dsgnTest_1.wing_Nchordwise = 5;

dsgnTest_1.h_stab_LE = 6*dsgnTest_1.wing_chord;
dsgnTest_1.h_stab_chord = 0.5*dsgnTest_1.wing_chord;
dsgnTest_1.h_stab_AR = 8;
dsgnTest_1.h_stab_sweep = 5;
dsgnTest_1.h_stab_dihedral = 0;
dsgnTest_1.h_stab_TR = 0.8;
dsgnTest_1.h_stab_naca_airfoil = '0015';
dsgnTest_1.h_stab_airfoil_ClLimits = [-1.7 1.7];

dsgnTest_1.v_stab_LE = dsgnTest_1.h_stab_LE;
dsgnTest_1.v_stab_chord = dsgnTest_1.h_stab_chord;
dsgnTest_1.v_stab_AR = 0.6*dsgnTest_1.h_stab_AR;
dsgnTest_1.v_stab_sweep = 10;
dsgnTest_1.v_stab_TR = 0.9;
dsgnTest_1.v_stab_naca_airfoil = '0015';
dsgnTest_1.v_stab_airfoil_ClLimits = [-1.7 1.7];


% dsgnTest_1.plot

%% create three inout files
avlCreateInputFilePart(dsgnTest_1);

dsgnTest_1.wing_ip_file_name
dsgnTest_1.hs_ip_file_name
dsgnTest_1.vs_ip_file_name

avlPartitioned(dsgnTest_1,[-40 40],31)

%% plot polars
load(dsgnTest_1.lookup_table_file_name)

figr = figure(1);
figr.Position =[102 92 3*560 2*420];
figr.Name ='Partitioned Aero Coeffs';

% left wing
ax1 = subplot(2,4,1);
plot(partitionedAero(1).alpha,partitionedAero(1).CLVals);
hCL_ax = gca;

xlabel('$\alpha$ [deg]')
ylabel('$C_{L}$')
title('Left Wing')
grid on
hold on

ax5 = subplot(2,4,5);
plot(partitionedAero(1).alpha,partitionedAero(1).CDVals);
xlabel('$\alpha$ [deg]')
ylabel('$C_{D}$')
grid on
hold on
hCD_ax = gca;

linkaxes([ax1,ax5],'x');

% right wing
ax2 = subplot(2,4,2);
plot(partitionedAero(2).alpha,partitionedAero(2).CLVals);

xlabel('$\alpha$ [deg]')
ylabel('$C_{L}$')
title('Right Wing')
grid on
hold on

ax6 = subplot(2,4,6);
plot(partitionedAero(2).alpha,partitionedAero(2).CDVals);
xlabel('$\alpha$ [deg]')
ylabel('$C_{D}$')
grid on
hold on

linkaxes([ax2,ax6],'x');

% HS
ax3 = subplot(2,4,3);
plot(partitionedAero(3).alpha,partitionedAero(3).CLVals);
xlabel('$\alpha$ [deg]')
ylabel('$C_{L}$')
title('H-stab')
grid on
hold on

ax7 = subplot(2,4,7);
plot(partitionedAero(3).alpha,partitionedAero(3).CDVals);
xlabel('$\alpha$ [deg]')
ylabel('$C_{D}$')
grid on
hold on

linkaxes([ax3,ax7],'x');

% VS
ax4 = subplot(2,4,4);
plot(partitionedAero(4).alpha,partitionedAero(4).CLVals);
xlabel('$\alpha$ [deg]')
ylabel('$C_{L}$')
title('V-stab')
grid on
hold on

ax8 = subplot(2,4,8);
plot(partitionedAero(4).alpha,partitionedAero(4).CDVals);
xlabel('$\alpha$ [deg]')
ylabel('$C_{D}$')
grid on
hold on

linkaxes([ax4,ax8],'x');

axis([ax1 ax2 ax3 ax4],[-inf inf hCL_ax.YLim(1) hCL_ax.YLim(2)]);
axis([ax5 ax6 ax7 ax8],[-inf inf hCD_ax.YLim(1) hCD_ax.YLim(2)]);


%% find aero center
%%%%%%%    ref point 1        %%%%%%%%%%%%
% dsgnTest_1.reference_point = [0.2;0;0];
% avlCreateInputFilePart(dsgnTest_1);
% 
% % test at alp 1
% alp1 = 0;
% dsgnTest_1.singleCase.alpha = alp1;
% 
% avlProcessPart(dsgnTest_1,dsgnTest_1.wing_ip_file_name,'single','Parallel',false);
% load('dsgnTest_1_results');
% 
% Cm1 = results{1}.FT.Cmtot
% 
% 
% 
% 
% % test at alp 2
% alp2 = 5;
% dsgnTest_1.singleCase.alpha = alp2;
% 
% avlProcessPart(dsgnTest_1,dsgnTest_1.wing_ip_file_name,'single','Parallel',false);
% load('dsgnTest_1_results');
% 
% Cm2 = results{1}.FT.Cmtot;
% 
% slp1 = (Cm2-Cm1)/(alp2 - alp1);
% 
% 
% %%%%%%%    ref point 2        %%%%%%%%%%%%
% dsgnTest_1.reference_point = [dsgnTest_1.wing_chord;dsgnTest_1.wing_span/4;0];
% avlCreateInputFilePart(dsgnTest_1);
% 
% % test at alp 1
% dsgnTest_1.singleCase.alpha = alp1;
% 
% avlProcessPart(dsgnTest_1,dsgnTest_1.wing_ip_file_name,'single','Parallel',false);
% load('dsgnTest_1_results');
% 
% Cm3 = results{1}.FT.Cmtot;
% 
% % test at alp 2
% dsgnTest_1.singleCase.alpha = alp2;
% 
% avlProcessPart(dsgnTest_1,dsgnTest_1.wing_ip_file_name,'single','Parallel',false);
% load('dsgnTest_1_results');
% 
% Cm4 = results{1}.FT.Cmtot;
% 
% slp2 = (Cm4-Cm3)/(alp2 - alp1);
% 
% 
% 
% 
