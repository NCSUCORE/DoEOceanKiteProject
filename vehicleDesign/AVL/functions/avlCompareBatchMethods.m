close all;clear;clc
% create sample design
dsgn_test = avlDesignGeometryClass;
dsgn_test.input_file_name        = 'dsgn1.avl'; % File name for .avl file
dsgn_test.run_file_name          = 'dsgn1.run';
dsgn_test.design_name            = 'dsgn1Name'; % String at top of input file defining the name
dsgn_test.result_file_name       = 'dsgn1Results';
dsgn_test.lookup_table_file_name = 'dsgn1Lookup';
dsgn_test.exe_file_name          = 'dsgn1Exe';

dsgn_test.sweepCase.alpha      = [-10 10];
dsgn_test.sweepCase.beta       = [-10 10];
dsgn_test.sweepCase.flap       = [-10 10];
dsgn_test.sweepCase.aileron    = [-10 10];
dsgn_test.sweepCase.elevator   = [-10 10];
dsgn_test.sweepCase.rudder     = [-10 10];

dsgn_test.writeInputFile

tic
avlProcess(dsgn_test,'sweep','Parallel',false)
toc

