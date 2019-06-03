close all;clear;clc
% create sample design
dsgn_test = avlDesignGeometryClass;
dsgn_test.input_file_name        = 'dsgn1.avl'; % File name for .avl file
dsgn_test.run_file_name          = 'dsgn1.run';
dsgn_test.design_name            = 'dsgn1Name'; % String at top of input file defining the name
dsgn_test.result_file_name       = 'dsgn1Results';
dsgn_test.lookup_table_file_name = 'dsgn1Lookup';
dsgn_test.exe_file_name          = 'dsgn1Exe';

dsgn.sweep.alphas      = [-10 10];
dsgn.sweep.betas       = [-5 5];
dsgn.sweep.flaps       = [-1 1];
dsgn.sweep.ailerons    = [-1 1];
dsgn.sweep.elevators   = [-1 1];
dsgn.sweep.rudders     = [-1 1];

dsgn_test.writeInputFile

tic
dsgn_test.process('single')
toc

