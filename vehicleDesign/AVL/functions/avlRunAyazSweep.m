close all;clear;clc;format compact
% create sample design
dsgn_test = avlDesignGeometryClass;

dsgn_test.wing_sweep = 15;
dsgn_test.wing_dihedral = 2;
dsgn_test.wing_TR = 0.8;

dsgn_test.h_stab_sweep = 15;
dsgn_test.h_stab_TR = 0.8;

dsgn_test.v_stab_sweep = 10;
dsgn_test.v_stab_TR = 0.8;

dsgn_test.input_file_name        = 'dsgn1.avl'; % File name for .avl file
dsgn_test.run_file_name          = 'dsgn1.run';
dsgn_test.design_name            = 'dsgn1Name'; % String at top of input file defining the name
dsgn_test.result_file_name       = 'dsgn1Results';
dsgn_test.lookup_table_file_name = 'dsgn1Lookup';
dsgn_test.exe_file_name          = 'dsgn1Exe';

% dsgn_test.singleCase.alpha = 15;

dsgn_test.sweepCase.alpha      = linspace(-20,20,31);
dsgn_test.sweepCase.beta       = linspace(-20,20,31);
dsgn_test.sweepCase.flap       = linspace(0,10,3);
dsgn_test.sweepCase.aileron    = linspace(-15,15,3);
dsgn_test.sweepCase.elevator   = linspace(-15,15,3);
dsgn_test.sweepCase.rudder     = linspace(-1,10,5);

dsgn_test.writeInputFile

% 11.5 for 64

estRunTime = ...
    numel(dsgn_test.sweepCase.alpha)*...
    numel(dsgn_test.sweepCase.beta)*...
    numel(dsgn_test.sweepCase.flap)*...
    numel(dsgn_test.sweepCase.aileron)*...
    numel(dsgn_test.sweepCase.elevator)*...
    numel(dsgn_test.sweepCase.rudder)*11.5/(64*60*60);

fprintf('\nEstimated runtime %0.3f hours\n',estRunTime)

% tic
% avlProcess(dsgn_test,'sweep','Parallel',true)
% toc


