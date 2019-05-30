% write vehicle design input files and run them in AVL
clear
clc

%% AVL input file
fileName = 'test.avl';
filePath = fileparts(which('avl.exe'));
fileID = fopen(fullfile(filePath,'designLibrary',fileName),'w');

% design name % Plane Vanilla
des_Name = 'Plane Vanilla test';
fprintf(fileID,'%s\n',des_Name);

% Mach
Mach = 0.0;
fprintf(fileID,'#Mach\n',Mach);
fprintf(fileID,'%0.2f\n',Mach);

% IYsym   IZsym   Zsym
m_IYsym = 0;
m_IZsym = 0;
m_IXsym = 0;
fprintf(fileID,'#IYsym   IZsym   Zsym\n');
fprintf(fileID,'%d \t\t %d\t\t %d\n',m_IYsym,m_IZsym,m_IXsym);

%  Sref    Cref    Bref
Sref =  9.0;
Cref = 0.9;
Bref = 10.0;
fprintf(fileID,'#Sref    Cref    Bref\n');
str_scb_ref = fprintf(fileID,'%0.2f \t %0.2f \t %0.2f\n',Sref,Cref,Bref);

% Xref    Yref    Zref
Xref = 0.50;
Yref = 0.0;
Zref = 0.0;

fprintf(fileID,'#Xref    Yref    Zref\n');
fprintf(fileID,'%0.2f \t %0.2f \t %0.2f\n',Xref,Yref,Zref);

fprintf(fileID,'#\n#\n#====================================================================\n');

%% define wing: contains one section
fprintf(fileID,'SURFACE\n');    % initialize surface
fprintf(fileID,'Wing\n');       % initialize surface wing

% Nchordwise  Cspace   Nspanwise   Sspace
Nchordwise_w = 8;
Cspace_w = 1;
Nspanwise_w = 12;
Sspace_w = 1;
fprintf(fileID,'#Nchordwise  Cspace   Nspanwise   Sspace\n');
fprintf(fileID,'%d \t\t\t %0.2f \t\t %d \t\t %0.2f\n',...
    Nchordwise_w,Cspace_w,Nspanwise_w,Sspace_w);

%
fprintf(fileID,'YDUPLICATE\n'); % toggle Y-duplicate

% YDUPLICATE
y_dup_w = 0;
fprintf(fileID,'%0.1f\n',y_dup_w);

% ANGLE
fprintf(fileID,'ANGLE\n'); % permanent incident angle
angle_w = 2;
fprintf(fileID,'%0.1f\n',angle_w);
fprintf(fileID,'#-------------------------------------------------------------\n');
% SECTION 1
fprintf(fileID,'SECTION\n'); % SECTION

% Xle    Yle    Zle     Chord   Ainc  Nspanwise  Sspace
Xle_w_s1 = 0;
Yle_w_s1 = 0;
Zle_w_s1 = 0;
chord_w_s1 = 1;
Ainc_w_s1 = 0;
Nspanwise_w_s1 = 0;
Sspace_w_s1 = 0;
fprintf(fileID,'Xle \t Yle \t Zle \t Chord \t Ainc \t Nspanwise \t Sspace\n');
fprintf(fileID,'%0.2f \t %0.2f \t %0.2f \t %0.2f \t %0.2f \t %d \t %d\n',...
    Xle_w_s1, Yle_w_s1, Zle_w_s1, chord_w_s1, Ainc_w_s1, Nspanwise_w_s1,...
    Sspace_w_s1);

% airfoil name
fprintf(fileID,'\nAFILE\n'); % AFILE
fprintf(fileID,'sd7037.dat\n\n'); % filename

% flap and aileron
fprintf(fileID,'Cname \t Cgain \t Xhinge \t HingeVec \t SgnDup\n');
fprintf(fileID,'CONTROL\n'); % CONTROL Section

% Cname   Cgain  Xhinge  HingeVec     SgnDup
Cgain_flap = 1;
Xhinge_flap = 0.75;
HingeVec_x_flap = 0;
HingeVec_y_flap = 0;
HingeVec_z_flap = 0;
SgnDup_flap = 1;

fprintf(fileID,'flap \t %0.2f \t %0.2f \t %0.1f \t %0.1f \t %0.1f \t %0.1f\n\n',...
    Cgain_flap, Xhinge_flap, HingeVec_x_flap, HingeVec_y_flap, HingeVec_z_flap,...
    SgnDup_flap);

fprintf(fileID,'CONTROL\n'); % CONTROL Section

% Cname   Cgain  Xhinge  HingeVec     SgnDup
Cgain_ail = -1;
Xhinge_ail = 0.75;
HingeVec_x_ail = 0;
HingeVec_y_ail = 0;
HingeVec_z_ail = 0;
SgnDup_ail = -1;

fprintf(fileID,'aileron %0.2f %0.2f %0.1f %0.1f %0.1f %0.1f\n\n',...
    Cgain_ail, Xhinge_ail, HingeVec_x_ail, HingeVec_y_ail, HingeVec_z_ail,...
    SgnDup_ail);

% CLAF
fprintf(fileID,'CLAF\n');
claf_w = 1;
fprintf(fileID,'%0.2f\n',claf_w);
fprintf(fileID,'#-------------------------------------------------------------\n');


% SECTION 1
fprintf(fileID,'SECTION\n'); % SECTION

% Xle    Yle    Zle     Chord   Ainc  Nspanwise  Sspace
Xle_w_s2 = 0.2;
Yle_w_s2 = 5;
Zle_w_s2 = 1;
chord_w_s2 = 0.6;
Ainc_w_s2 = 0;
Nspanwise_w_s2 = 0;
Sspace_w_s2 = 0;
fprintf(fileID,'Xle \t Yle \t Zle \t Chord \t Ainc \t Nspanwise \t Sspace\n');
fprintf(fileID,'%0.2f \t %0.2f \t %0.2f \t %0.2f \t %0.2f \t %d \t %d\n\n',...
    Xle_w_s2, Yle_w_s2, Zle_w_s2, chord_w_s2, Ainc_w_s2, Nspanwise_w_s2,...
    Sspace_w_s2);

% airfoil name
fprintf(fileID,'AFILE\n'); % AFILE
fprintf(fileID,'sd7037.dat\n\n'); % filename

% flap and aileron
fprintf(fileID,'\n#Cname \t Cgain \t Xhinge \t HingeVec \t SgnDup\n');
fprintf(fileID,'CONTROL\n'); % CONTROL Section
fprintf(fileID,'flap %0.2f %0.2f %0.1f %0.1f %0.1f %0.1f\n\n',...
    Cgain_flap, Xhinge_flap, HingeVec_x_flap, HingeVec_y_flap, HingeVec_z_flap,...
    SgnDup_flap);
fprintf(fileID,'CONTROL\n'); % CONTROL Section
fprintf(fileID,'aileron %0.2f %0.2f %0.1f %0.1f %0.1f %0.1f\n\n',...
    Cgain_ail, Xhinge_ail, HingeVec_x_ail, HingeVec_y_ail, HingeVec_z_ail,...
    SgnDup_ail);

% CLAF
fprintf(fileID,'CLAF\n');
fprintf(fileID,'%0.2f\n',claf_w);
fprintf(fileID,'#====================================================================\n');

%% Horizotal stabilizer
fprintf(fileID,'SURFACE\n');    % initialize surface
fprintf(fileID,'H-stab\n');       % initialize surface wing

% Nchordwise  Cspace   Nspanwise   Sspace
Nchordwise_hs = 6;
Cspace_hs = 1;
Nspanwise_hs = 6;
Sspace_hs = 1;
fprintf(fileID,'#Nchordwise  Cspace   Nspanwise   Sspace\n');
fprintf(fileID,'%d \t %0.2f \t %d \t %0.2f\n',...
    Nchordwise_hs, Cspace_hs, Nspanwise_hs, Sspace_hs);

%
fprintf(fileID,'YDUPLICATE\n'); % toggle Y-duplicate

% YDUPLICATE
y_dup_hs = 0;
fprintf(fileID,'%0.1f\n',y_dup_hs);

% Translate
fprintf(fileID,'TRANSLATE\n'); % move hs back
hs_x = 4;
hs_y = 0;
hs_z = 0;

fprintf(fileID,'%0.2f %0.2f %0.2f\n', hs_x, hs_y, hs_z);
fprintf(fileID,'#\n#-------------------------------------------------------------\n');
% SECTION 1
fprintf(fileID,'SECTION\n'); % SECTION

% Xle    Yle    Zle     Chord   Ainc  Nspanwise  Sspace
Xle_hs_s1 = 0;
Yle_hs_s1 = 0;
Zle_hs_s1 = 0;
chord_hs_s1 = 0.7;
Ainc_hs_s1 = 0;
Nspanwise_hs_s1 = 0;
Sspace_hs_s1 = 0;
fprintf(fileID,'Xle    Yle    Zle     Chord   Ainc  Nspanwise  Sspace\n');
fprintf(fileID,'%0.2f %0.2f %0.2f %0.2f %0.2f %d %d\n\n',...
    Xle_hs_s1, Yle_hs_s1, Zle_hs_s1, chord_hs_s1, Ainc_hs_s1, Nspanwise_hs_s1,...
    Sspace_hs_s1);

% elevator
fprintf(fileID,'#Cname   Cgain  Xhinge  HingeVec     SgnDup\n');
fprintf(fileID,'CONTROL\n'); % CONTROL Section

% Cname   Cgain  Xhinge  HingeVec     SgnDup
Cgain_elev = 1;
Xhinge_elev = 0.7;
HingeVec_x_elev = 0;
HingeVec_y_elev = 1;
HingeVec_z_elev = 0;
SgnDup_elev = 1;

fprintf(fileID,'elevator %0.1f %0.2f %0.1f %0.1f %0.1f %0.1f\n',...
    Cgain_elev, Xhinge_elev, HingeVec_x_elev, HingeVec_y_elev, HingeVec_z_elev,...
    SgnDup_elev);
fprintf(fileID,'#-------------------------------------------------------------\n');
% SECTION 2
fprintf(fileID,'SECTION\n'); % SECTION
fprintf(fileID,'#Xle    Yle    Zle     Chord   Ainc  Nspanwise  Sspace\n');
% Xle    Yle    Zle     Chord   Ainc  Nspanwise  Sspace
Xle_hs_s2 = 0.14;
Yle_hs_s2 = 1.25;
Zle_hs_s2 = 0;
chord_hs_s2 = 0.42;
Ainc_hs_s2 = 0;
Nspanwise_hs_s2 = 0;
Sspace_hs_s2 = 0;

fprintf(fileID,'%0.2f %0.2f %0.2f %0.2f %0.2f %d %d\n\n',...
    Xle_hs_s2, Yle_hs_s2, Zle_hs_s2, chord_hs_s2, Ainc_hs_s2, Nspanwise_hs_s2,...
    Sspace_hs_s2);

% elevator
fprintf(fileID,'#Cname   Cgain  Xhinge  HingeVec     SgnDup\n');
fprintf(fileID,'CONTROL\n'); % CONTROL Section
fprintf(fileID,'elevator %0.1f %0.2f %0.1f %0.1f %0.1f %0.1f\n',...
    Cgain_elev, Xhinge_elev, HingeVec_x_elev, HingeVec_y_elev, HingeVec_z_elev,...
    SgnDup_elev);
fprintf(fileID,'#\n#====================================================================\n');
%% Vertical stabilizer
fprintf(fileID,'SURFACE\n');    % initialize surface
fprintf(fileID,'V-stab\n');       % initialize surface wing
fprintf(fileID,'#Nchordwise  Cspace    Nspanwise  Sspace\n');
% Nchordwise  Cspace   Nspanwise   Sspace
Nchordwise_vs = 6;
Cspace_vs = 1;
Nspanwise_vs = 5;
Sspace_vs = 1;

fprintf(fileID,'%d %0.2f %d %0.2f\n',...
    Nchordwise_vs, Cspace_vs, Nspanwise_vs, Sspace_vs);

% Translate
fprintf(fileID,'TRANSLATE\n'); % move hs back
vs_x = 4;
vs_y = 0;
vs_z = 0;

fprintf(fileID,'%0.2f %0.2f %0.2f\n', vs_x, vs_y, vs_z);
fprintf(fileID,'#-------------------------------------------------------------\n');
% SECTION 1
fprintf(fileID,'SECTION\n'); % SECTION
fprintf(fileID,'#Xle    Yle    Zle     Chord   Ainc  Nspanwise  Sspace\n');
% Xle    Yle    Zle     Chord   Ainc  Nspanwise  Sspace
Xle_vs_s1 = 0;
Yle_vs_s1 = 0;
Zle_vs_s1 = 0;
chord_vs_s1 = 0.7;
Ainc_vs_s1 = 0;
Nspanwise_vs_s1 = 0;
Sspace_vs_s1 = 0;

fprintf(fileID,'%0.2f %0.2f %0.2f %0.2f %0.2f %d %d\n\n',...
    Xle_vs_s1, Yle_vs_s1, Zle_vs_s1, chord_vs_s1, Ainc_vs_s1, Nspanwise_vs_s1,...
    Sspace_vs_s1);

% rudder
fprintf(fileID,'#Cname   Cgain  Xhinge  HingeVec     SgnDup\n');
fprintf(fileID,'CONTROL\n'); % CONTROL Section

% Cname   Cgain  Xhinge  HingeVec     SgnDup
Cgain_rud = 1;
Xhinge_rud = 0.5;
HingeVec_x_rud = 0;
HingeVec_y_rud = 0;
HingeVec_z_rud = 1;
SgnDup_rud = 1;

fprintf(fileID,'rudder %0.1f %0.2f %0.1f %0.1f %0.1f %0.1f\n',...
    Cgain_rud, Xhinge_rud, HingeVec_x_rud, HingeVec_y_rud, HingeVec_z_rud,...
    SgnDup_rud);
fprintf(fileID,'#-------------------------------------------------------------\n');
% SECTION 2
fprintf(fileID,'SECTION\n'); % SECTION
fprintf(fileID,'#Xle    Yle    Zle     Chord   Ainc  Nspanwise  Sspace\n');
% Xle    Yle    Zle     Chord   Ainc  Nspanwise  Sspace
Xle_vs_s2 = 0.14;
Yle_vs_s2 = 0;
Zle_vs_s2 = 1;
chord_vs_s2 = 0.42;
Ainc_vs_s2 = 0;
Nspanwise_vs_s2 = 0;
Sspace_vs_s2 = 0;

fprintf(fileID,'%0.2f %0.2f %0.2f %0.2f %0.2f %d %d\n\n',...
    Xle_vs_s2, Yle_vs_s2, Zle_vs_s2, chord_vs_s2, Ainc_vs_s2, Nspanwise_vs_s2,...
    Sspace_vs_s2);

% rudder
fprintf(fileID,'#Cname   Cgain  Xhinge  HingeVec     SgnDup\n');
fprintf(fileID,'CONTROL\n'); % CONTROL Section
fprintf(fileID,'rudder %0.1f %0.2f %0.1f %0.1f %0.1f %0.1f\n',...
    Cgain_rud, Xhinge_rud, HingeVec_x_rud, HingeVec_y_rud, HingeVec_z_rud,...
    SgnDup_rud);
fprintf(fileID,'#-------------------------------------------------------------\n');


fclose(fileID);
