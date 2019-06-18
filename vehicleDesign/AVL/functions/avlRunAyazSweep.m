close all;clear;clc;format compact;fclose all;
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

dsgnTest_1.reference_point = [0.6;0;0];

dsgnTest_1.wing_chord = 1;
dsgnTest_1.wing_AR = 10;
dsgnTest_1.wing_sweep = 5;
dsgnTest_1.wing_dihedral = 2;
dsgnTest_1.wing_TR = 0.8;
dsgnTest_1.wing_incidence_angle = 0;
dsgnTest_1.wing_naca_airfoil = '2412';
dsgnTest_1.wing_airfoil_ClLimits = [-1.7 1.7];

dsgnTest_1.wing_Nspanwise = 20;
dsgnTest_1.wing_Nchordwise = 2;

dsgnTest_1.h_stab_LE = 6*dsgnTest_1.wing_chord;
dsgnTest_1.h_stab_chord = 0.5*dsgnTest_1.wing_chord;
dsgnTest_1.h_stab_AR = 8;
dsgnTest_1.h_stab_sweep = 5;
dsgnTest_1.h_stab_dihedral = 0;
dsgnTest_1.h_stab_TR = 0.8;
dsgnTest_1.h_stab_naca_airfoil = '0015';
dsgnTest_1.h_stab_airfoil_ClLimits = [-1.7 1.7];

dsgnTest_1.h_stab_Nspanwise = dsgnTest_1.wing_Nspanwise*(dsgnTest_1.h_stab_chord/dsgnTest_1.wing_chord);
dsgnTest_1.h_stab_Nchordwise = 1;

dsgnTest_1.v_stab_LE = dsgnTest_1.h_stab_LE;
dsgnTest_1.v_stab_chord = dsgnTest_1.h_stab_chord;
dsgnTest_1.v_stab_AR = 0.6*dsgnTest_1.h_stab_AR;
dsgnTest_1.v_stab_sweep = 10;
dsgnTest_1.v_stab_TR = 0.9;
dsgnTest_1.v_stab_naca_airfoil = '0015';
dsgnTest_1.v_stab_airfoil_ClLimits = [-1.7 1.7];

dsgnTest_1.v_stab_Nspanwise = 5;
dsgnTest_1.v_stab_Nchordwise = 1;

dsgnTest_1.plot
% view(0,90)


%% sweep cases
n_alpha = 21;
n_beta = 21;

dsgnTest_1.sweepCase.alpha      = linspace(-25,25,n_alpha);
dsgnTest_1.sweepCase.beta       = linspace(-25,25,n_beta);
dsgnTest_1.sweepCase.flap       = 0;
dsgnTest_1.sweepCase.aileron    = 0;
dsgnTest_1.sweepCase.elevator   = 0;
dsgnTest_1.sweepCase.rudder     = 0;

dsgnTest_1.writeInputFile

% estimate run time
n_case = n_alpha*n_beta;

estRunTime = n_case*11.5/(64*60*60);
fprintf('\nEstimated runtime %0.3f hours\n',estRunTime)

%% run the thing and post process
tic
avlProcess(dsgnTest_1,'sweep','Parallel',true)
toc

%% load result file
load(dsgnTest_1.result_file_name);
% build lookup tables based on 2 inouts
avlBuild_2D_LookupTable(dsgnTest_1,results);

% plot polars based on 2 inouts
avlPlot_2D_Polars(dsgnTest_1.lookup_table_file_name);

%% calculate the gains due to control surface deflection
nom_a = 0;
nom_b = 0;

k_CS_gain = calculate_2D_gains2(dsgnTest_1,nom_a,nom_b);

% k_CS_gain = calculate_2D_gains(dsgnTest_1,nom_a,nom_b,df,da,de,dr);
% 
% saveFileName = fullfile(fileparts(which('avl.exe')),'designLibrary',dsgnTest_1.lookup_table_file_name);
% save(saveFileName,'k_CS_gain','-append')


