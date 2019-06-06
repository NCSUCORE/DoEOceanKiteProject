close all;clear;clc;format compact;fclose all;

% create sample design
dsgn_test = avlDesignGeometryClass;

% wing parameters
dsgn_test.wing_chord = 2;
dsgn_test.wing_sweep = 15;
dsgn_test.wing_dihedral = 0;
dsgn_test.wing_TR = 0.8;
dsgn_test.wing_naca_airfoil = '0015';

% horizontal stabilizer
dsgn_test.h_stab_LE = 4*dsgn_test.wing_chord;
dsgn_test.h_stab_chord = 0.75;
dsgn_test.h_stab_AR = 8;
dsgn_test.h_stab_sweep = 15;
dsgn_test.h_stab_TR = 0.8;
dsgn_test.h_stab_naca_airfoil = '0015';

% vertical stabilizer
dsgn_test.v_stab_LE = 4*dsgn_test.wing_chord;
dsgn_test.v_stab_chord = dsgn_test.h_stab_chord;
dsgn_test.v_stab_sweep = 15;
dsgn_test.v_stab_TR = 0.75;

% dsgn_test.plot

dsgn_test.input_file_name        = 'dsgnAyaz1.avl'; % File name for .avl file
dsgn_test.run_file_name          = 'dsgnAyaz1.run';
dsgn_test.design_name            = 'dsgnAyaz1Name'; % String at top of input file defining the name
dsgn_test.result_file_name       = 'dsgnAyaz1Results';
dsgn_test.lookup_table_file_name = 'dsgnAyaz1Lookup';
dsgn_test.exe_file_name          = 'dsgnAyaz1Exe';

% dsgn_test.singleCase.alpha = 15;

dsgn_test.sweepCase.alpha      = linspace(-20,20,21);
dsgn_test.sweepCase.beta       = linspace(-20,20,21);
dsgn_test.sweepCase.flap       = linspace(0,10,5);
dsgn_test.sweepCase.aileron    = linspace(-15,15,5);
dsgn_test.sweepCase.elevator   = linspace(-15,15,5);
dsgn_test.sweepCase.rudder     = linspace(-1,10,5);

% dsgn_test.sweepCase.alpha      = linspace(-20,20,2);
% dsgn_test.sweepCase.beta       = linspace(-20,20,2);
% dsgn_test.sweepCase.flap       = linspace(0,10,2);
% dsgn_test.sweepCase.aileron    = linspace(-15,15,2);
% dsgn_test.sweepCase.elevator   = linspace(-15,15,2);
% dsgn_test.sweepCase.rudder     = linspace(-1,10,2);

dsgn_test.writeInputFile

% estimate run time
estRunTime = ...
    numel(dsgn_test.sweepCase.alpha)*...
    numel(dsgn_test.sweepCase.beta)*...
    numel(dsgn_test.sweepCase.flap)*...
    numel(dsgn_test.sweepCase.aileron)*...
    numel(dsgn_test.sweepCase.elevator)*...
    numel(dsgn_test.sweepCase.rudder)*11.5/(64*60*60);

fprintf('\nEstimated runtime %0.3f hours\n',estRunTime)

tic
avlProcess(dsgn_test,'sweep','Parallel',true)
toc

load(dsgn_test.result_file_name);

avlBuildLookupTable(dsgn_test.lookup_table_file_name,results)

avlPlotPolars(dsgn_test.lookup_table_file_name);




