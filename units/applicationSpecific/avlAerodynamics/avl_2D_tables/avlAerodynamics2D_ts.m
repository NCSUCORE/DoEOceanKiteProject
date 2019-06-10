close all;clear;clc;format compact;fclose all;
set(groot,'defaulttextinterpreter','latex');
set(groot, 'defaultAxesTickLabelInterpreter','latex');
set(groot, 'defaultLegendInterpreter','latex');


% create sample design
dsgn_test = avlDesignGeometryClass;

%% modify design
% wing parameters
dsgn_test.wing_chord = 6;
dsgn_test.wing_AR = 6;
dsgn_test.wing_sweep = 15;
dsgn_test.wing_dihedral = 0;
dsgn_test.wing_TR = 0.8;
dsgn_test.wing_naca_airfoil = '0015';
dsgn_test.wing_airfoil_ClLimits = [-1.68 1.68];


dsgn_test.wing_Nspanwise = 32;
dsgn_test.wing_Nchordwise = 2;

% horizontal stabilizer
dsgn_test.h_stab_LE = 4*dsgn_test.wing_chord;
dsgn_test.h_stab_chord = 0.25*dsgn_test.wing_chord;
dsgn_test.h_stab_AR = 6;
dsgn_test.h_stab_sweep = 15;
dsgn_test.h_stab_TR = 0.8;
dsgn_test.h_stab_naca_airfoil = '0015';
dsgn_test.h_stab_airfoil_ClLimits = [-1.68 1.68];


dsgn_test.h_stab_Nspanwise = 8;
dsgn_test.h_stab_Nchordwise = 1;

% vertical stabilizer
dsgn_test.v_stab_LE = 4*dsgn_test.wing_chord;
dsgn_test.v_stab_chord = dsgn_test.h_stab_chord;
dsgn_test.v_stab_sweep = 15;
dsgn_test.v_stab_TR = 0.75;

dsgn_test.v_stab_Nspanwise = 5;
dsgn_test.v_stab_Nchordwise = 1;

% dsgn_test.plot

%% file names
dsgn_test.input_file_name        = 'dsgnAyaz1.avl'; % File name for .avl file
dsgn_test.run_file_name          = 'dsgnAyaz1.run';
dsgn_test.design_name            = 'dsgnAyaz1Name'; % String at top of input file defining the name
dsgn_test.result_file_name       = 'dsgnAyaz1Results';
dsgn_test.lookup_table_file_name = 'dsgnAyaz1_2D_Lookup';
dsgn_test.exe_file_name          = 'dsgnAyaz1Exe';

%% sweep cases
n_alpha = 31;
n_beta = 31;

dsgn_test.sweepCase.alpha      = linspace(-25,25,n_alpha);
dsgn_test.sweepCase.beta       = linspace(-20,20,n_beta);
dsgn_test.sweepCase.flap       = 0;
dsgn_test.sweepCase.aileron    = 0;
dsgn_test.sweepCase.elevator   = 0;
dsgn_test.sweepCase.rudder     = 0;

dsgn_test.writeInputFile

% estimate run time
n_case = n_alpha*n_beta;

estRunTime = n_case*11.5/(64*60*60);
fprintf('\nEstimated runtime %0.3f hours\n',estRunTime)

%% run the thing and post process
tic
avlProcess(dsgn_test,'sweep','Parallel',true)
toc

%% load result file
load(dsgn_test.result_file_name);

% build lookup tables based on 2 inouts
avlBuild_2D_LookupTable(dsgn_test.lookup_table_file_name,results)

% plot polars based on 2 inouts
avlPlot_2D_Polars(dsgn_test.lookup_table_file_name);

%% previously used data
pcl_mw = [0.0000   -0.0001   -0.0000    0.1217    0.0008];
pcd_mw = [0.0000   -0.0000   -0.0000    0.0000    0.0089];
alp_n = linspace(-25,25,100);
pcl_n = 0.8*polyval(pcl_mw,alp_n);
pcd_n = polyval(pcd_mw,alp_n) + (pcl_n.^2)/(pi*dsgn_test.wing_AR);

figure(2);
subplot(2,1,1)
hold on
plot(alp_n,pcl_n,'r','linewidth',1);

subplot(2,1,2)
hold on
plot(alp_n,pcd_n,'r','linewidth',1);


%% calculate the gains due to control surface deflection
nom_a = 0;
nom_b = 0;

df = 1;
da = 1;
de = 1;
dr = 1;

k_CS_gain = calculate_2D_gains(dsgn_test,nom_a,nom_b,df,da,de,dr);

saveFileName = fullfile(fileparts(which('avl.exe')),'designLibrary',dsgn_test.lookup_table_file_name);
save(saveFileName,'CLtot_2D_Tbl','CDtot_2D_Tbl','Cltot_2D_Tbl','Cmtot_2D_Tbl','Cntot_2D_Tbl','k_CS_gain');

%%
clc
format compact

uAppBdy = [5 0 1];
dynPress = 1;
flpDefl_deg = 10;
ailDefl_deg = 0;
elevDefl_deg = 0;
rudDefl_deg = 0;

refArea = 1;

% sim('avlAerodynamics2D_th')


