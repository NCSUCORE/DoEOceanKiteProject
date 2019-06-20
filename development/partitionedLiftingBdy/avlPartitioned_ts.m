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

dsgnTest_1.reference_point = [0.5;0;0];

dsgnTest_1.wing_chord = 1;
dsgnTest_1.wing_AR = 10;
dsgnTest_1.wing_sweep = 5;
dsgnTest_1.wing_dihedral = 2;
dsgnTest_1.wing_TR = 0.8;
dsgnTest_1.wing_incidence_angle = 0;
dsgnTest_1.wing_naca_airfoil = '2412';
dsgnTest_1.wing_airfoil_ClLimits = [-1.7 1.7];

dsgnTest_1.wing_Nspanwise = 20;
dsgnTest_1.wing_Nchordwise = 5;

dsgnTest_1.h_stab_LE = 6*dsgnTest_1.wing_chord;
dsgnTest_1.h_stab_chord = 0.5*dsgnTest_1.wing_chord;
dsgnTest_1.h_stab_AR = 8;
dsgnTest_1.h_stab_sweep = 10;
dsgnTest_1.h_stab_dihedral = 0;
dsgnTest_1.h_stab_TR = 0.8;
dsgnTest_1.h_stab_naca_airfoil = '0015';
dsgnTest_1.h_stab_airfoil_ClLimits = [-1.7 1.7];

dsgnTest_1.v_stab_LE = dsgnTest_1.h_stab_LE;
dsgnTest_1.v_stab_chord = dsgnTest_1.h_stab_chord;
dsgnTest_1.v_stab_AR = 0.6*dsgnTest_1.h_stab_AR;
dsgnTest_1.v_stab_sweep = 15;
dsgnTest_1.v_stab_TR = 0.8;
dsgnTest_1.v_stab_naca_airfoil = '0015';
dsgnTest_1.v_stab_airfoil_ClLimits = [-1.7 1.7];

%% create three input files
avlPartitioned(dsgnTest_1,[-40 40],31)

%% plot polars
plotPartitionedPolars(dsgnTest_1.lookup_table_file_name)


