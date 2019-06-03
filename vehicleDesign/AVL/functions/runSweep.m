
% clear
clear
clc
close all

% create sample design
dsgn_test = avlDesignGeometryClass;
dsgn_test.input_file_name = 'desRun1';
dsgn_test.result_file_name = 'resRun1';
dsgn_test.lookup_table_file_name = 'lookupFinTable1';

% plot it
% dsgn_test.plot;

% create design avl input file
dsgn_test.writeInputFile;

% number of steps
n_alpha = 2;
n_beta = 2;
n_flap = 2;
n_aileron = 2;
n_elevator = 2;
n_rudder = 2;

nCases = n_alpha*n_beta*n_flap*n_aileron*n_elevator*n_rudder;

% operating conditions
sweepCase.alpha = linspace(-15,15,n_alpha);
sweepCase.beta = linspace(-20,20,n_beta);
sweepCase.flap = linspace(0,10,n_flap);
sweepCase.aileron = linspace(-20,20,n_aileron);
sweepCase.elevator = linspace(-20,20,n_elevator);
sweepCase.rudder = linspace(-20,20,n_rudder);

dsgn_test.sweepCase = sweepCase;

% build lookup table for cases in sweep case lookup table
dsgn_test.buildLookupTable

