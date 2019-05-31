% test script to make input file
clear

ipFileName = 'ip_file.avl';
result_file_name = 'op_file';

% design parameters
reference_point = [1;0;0];

wing_chord = 2;
wing_AR = 5;
wing_sweep = 15;
wing_dihedral = 10;
wing_TR = 0.8;
wing_incidence_angle = 1;

h_stab_LE = 5*wing_chord;
h_stab_chord = 0.25*wing_chord;
h_stab_AR = wing_AR;
h_stab_sweep = 15;
h_stab_dihedral = 0;
h_stab_TR = 0.9;

v_stab_LE = h_stab_LE;
v_stab_chord = h_stab_chord;
v_stab_AR = wing_AR/2;
v_stab_sweep = 20;
v_stab_TR = 0.6;

% operating conditions
alpha = 5;
beta = 0;
flap = 0;
aileron = 0;
elevator = 0;
rudder = 0;

% create avl input file in designLibrary folder
avlCreateInputFile(ipFileName,reference_point,wing_chord,wing_AR,wing_sweep,wing_dihedral,wing_TR,wing_incidence_angle,...
    h_stab_LE,h_stab_chord,h_stab_AR,h_stab_sweep,h_stab_dihedral,h_stab_TR,...
    v_stab_LE,v_stab_chord,v_stab_AR,v_stab_sweep,v_stab_TR);

% run avl using the input and operating parameters and output results to
% desginLibrary folder
avlRunCase(ipFileName,result_file_name,alpha,beta,flap,aileron,elevator,rudder);

%% print
avlFilePath = fileparts(which('avl.exe'));
libFilePath = fullfile(avlFilePath,'designLibrary');

fprintf('Results stored in %s\n',libFilePath);







