% test script to make input file
clear

ipFileName = 'test_ip_func.avl';

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

avlCreateInputFile(ipFileName,reference_point,wing_chord,wing_AR,wing_sweep,wing_dihedral,wing_TR,wing_incidence_angle,...
    h_stab_LE,h_stab_chord,h_stab_AR,h_stab_sweep,h_stab_dihedral,h_stab_TR,...
    v_stab_LE,v_stab_chord,v_stab_AR,v_stab_sweep,v_stab_TR)

