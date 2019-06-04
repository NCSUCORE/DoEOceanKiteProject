close all;clear;clc;format compact
% create sample design
dsgn_test = avlDesignGeometryClass;

dsgn_test.wing_sweep = 0;
dsgn_test.wing_dihedral = 0;
dsgn_test.wing_TR = 0.8;

dsgn_test.h_stab_sweep = 0;
dsgn_test.h_stab_TR = 1;

dsgn_test.v_stab_sweep = 0;
dsgn_test.v_stab_TR = 1;


dsgn_test.input_file_name        = 'dsgn1.avl'; % File name for .avl file
dsgn_test.run_file_name          = 'dsgn1.run';
dsgn_test.design_name            = 'dsgn1Name'; % String at top of input file defining the name
dsgn_test.result_file_name       = 'dsgn1Results';
dsgn_test.lookup_table_file_name = 'dsgn1Lookup';
dsgn_test.exe_file_name          = 'dsgn1Exe';

% dsgn_test.singleCase.alpha = 15;


dsgn_test.sweepCase.alpha      = -2;
dsgn_test.sweepCase.beta       = 0;
dsgn_test.sweepCase.flap       = 0;
dsgn_test.sweepCase.aileron    = 0;
dsgn_test.sweepCase.elevator   = 0;
dsgn_test.sweepCase.rudder     = 0;

dsgn_test.writeInputFile

tic
avlProcess(dsgn_test,'sweep','Parallel',false)
toc



