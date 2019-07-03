% function that creates input file
function avlCreateInputFilePart(obj)

% simplify variable names
c_r_w = obj.wing_chord;
AR_w = obj.wing_AR;
sw_w =  obj.wing_sweep;
di_w = obj.wing_dihedral;
tr_w = obj.wing_TR;
w_inc_angle = obj.wing_incidence_angle;
w_afile =  obj.wing_naca_airfoil;
w_Ns = obj.wing_Nspanwise;
w_Nc = obj.wing_Nchordwise;

c_r_hs = obj.h_stab_chord;
AR_hs = obj.h_stab_AR;
sw_hs = obj.h_stab_sweep;
di_hs = obj.h_stab_dihedral;
tr_hs = obj.h_stab_TR;
hs_afile =  obj.h_stab_naca_airfoil;

c_r_vs = obj.v_stab_chord;
AR_vs = obj.v_stab_AR;
sw_vs = obj.v_stab_sweep;
tr_vs = obj.v_stab_TR;
vs_afile =  obj.v_stab_naca_airfoil;

% cm cordinates
R_ref = obj.reference_point;

%% calculations
% wing and reference calculations %%%%%%%%%%%%%%%%%%
% span
b_w = c_r_w*AR_w;
% planform area
S_w = c_r_w*b_w;
% tip chord
c_t_w = c_r_w*tr_w;
% wing tip coordinates
x_t_w = (b_w/2)*tand(sw_w);
y_t_w = (b_w/2);
z_t_w = (b_w/2)*tand(di_w);

% spacing parameters
N_b_w = w_Ns;
N_c_w = w_Nc;

% error messages
if mod(N_c_w,1) ~= 0 || N_c_w <= 0
    error('The calculated values of number of chordwise elements of wing will lead to errors in AVL')
end
if mod(N_b_w,1) ~= 0 || N_b_w <= 0
    error('The calculated values of number of span elements of wing will lead to errors in AVL')
end

% horizonatal stbilizer calculations %%%%%%%%%%%%%
% span
b_hs = c_r_hs*AR_hs;
% tip chord
c_t_hs = c_r_hs*tr_hs;
% HS tip cordinates
x_t_hs = (b_hs/2)*tand(sw_hs);
y_t_hs = (b_hs/2);
z_t_hs = (b_hs/2)*tand(di_hs);

% spacing parameters
N_b_hs = w_Ns;
N_c_hs = w_Nc;

% error messages
if mod(N_c_hs,1) ~= 0 || N_c_hs <= 0
    error('The calculated values of number of chordwise elements in HS will lead to errors in AVL')
end
if mod(N_b_hs,1) ~= 0 || N_b_hs <= 0
    error('The calculated values of number of span elements in HS will lead to errors in AVL')
end

% vertical stabilizer calculations
% "span"
b_vs = c_r_vs*AR_vs;
% tip chord
c_t_vs = c_r_vs*tr_vs;
% HS tip cordinates
x_t_vs = b_vs*tand(sw_vs);
y_t_vs = 0;
z_t_vs = b_vs;

% spacing parameters
N_b_vs = w_Ns;
N_c_vs = w_Nc;

% error messages
if mod(N_c_vs,1) ~= 0 || N_c_vs <= 0
    error('The calculated values of number of chordwise elements in VS will lead to errors in AVL')
end
if mod(N_b_vs,1) ~= 0 || N_b_vs <= 0
    error('The calculated values of number of span elements in VS will lead to errors in AVL')
end


%% AVL input file WING
fileID = fopen(fullfile(fileparts(which('avl.exe')),obj.wing_ip_file_name),'w');

% design name % Plane Vanilla
% des_Name = 'Plane Vanilla test';
fprintf(fileID,'%s\n',obj.wing_ip_file_name);

% Mach
Mach = 0.0;
fprintf(fileID,'#Mach\n');
fprintf(fileID,'%0.2f\n',Mach);

% IYsym   IZsym   Zsym
m_IYsym = 0;
m_IZsym = 0;
m_IXsym = 0;
fprintf(fileID,'#IYsym   IZsym   Zsym\n');
fprintf(fileID,'%d \t\t %d\t\t %d\n',m_IYsym,m_IZsym,m_IXsym);

%  Sref    Cref    Bref
Sref =  S_w;
Cref = (c_r_w + c_t_w)/2;
Bref = b_w;
fprintf(fileID,'#Sref    Cref    Bref\n');
fprintf(fileID,'%0.2f \t %0.2f \t %0.2f\n',Sref,Cref,Bref);

% Xref    Yref    Zref
Xref = R_ref(1);
Yref = R_ref(2);
Zref = R_ref(3);

fprintf(fileID,'#Xref    Yref    Zref\n');
fprintf(fileID,'%0.2f \t %0.2f \t %0.2f\n',Xref,Yref,Zref);

fprintf(fileID,'#\n#\n#====================================================================\n');

%% define wing: contains one section
fprintf(fileID,'SURFACE\n');    % initialize surface
fprintf(fileID,'Wing\n');       % initialize surface wing

% Nchordwise  Cspace   Nspanwise   Sspace
Nchordwise_w = N_c_w;
Cspace_w = 1;
Nspanwise_w = N_b_w;
Sspace_w = 1;
fprintf(fileID,'#Nchordwise  Cspace   Nspanwise   Sspace\n');
fprintf(fileID,'%d \t\t\t %0.2f \t\t %d \t\t %0.2f\n',...
    Nchordwise_w,Cspace_w,Nspanwise_w,Sspace_w);

% ANGLE
fprintf(fileID,'ANGLE\n'); % permanent incident angle
angle_w = w_inc_angle;

fprintf(fileID,'%0.1f\n',angle_w);
fprintf(fileID,'#-------------------------------------------------------------\n');
% SECTION 1
fprintf(fileID,'SECTION\n'); % SECTION

% Xle    Yle    Zle     Chord   Ainc  Nspanwise  Sspace
Xle_w_s1 = 0;
Yle_w_s1 = 0;
Zle_w_s1 = 0;
chord_w_s1 = c_r_w;
Ainc_w_s1 = 0;
Nspanwise_w_s1 = 0;
Sspace_w_s1 = 0;
fprintf(fileID,'#Xle \t Yle \t Zle \t Chord \t Ainc \t Nspanwise \t Sspace\n');
fprintf(fileID,'%0.2f \t %0.2f \t %0.2f \t %0.2f \t %0.2f \t %d \t %d\n',...
    Xle_w_s1, Yle_w_s1, Zle_w_s1, chord_w_s1, Ainc_w_s1, Nspanwise_w_s1,...
    Sspace_w_s1);

% airfoil name
fprintf(fileID,'\nNACA\n'); % AFILE
fprintf(fileID,'%s\n\n',w_afile); % filename

% flap and aileron
fprintf(fileID,'#Cname \t Cgain \t Xhinge \t HingeVec \t SgnDup\n');
fprintf(fileID,'CONTROL\n'); % CONTROL Section

% Cname   Cgain  Xhinge  HingeVec     SgnDup
Cgain_ail = 1;
Xhinge_ail = 0.75;
HingeVec_x_ail = 0;
HingeVec_y_ail = 0;
HingeVec_z_ail = 0;
SgnDup_ail = 1;

fprintf(fileID,'aileron %0.2f %0.2f %0.1f %0.1f %0.1f %0.1f\n\n',...
    Cgain_ail, Xhinge_ail, HingeVec_x_ail, HingeVec_y_ail, HingeVec_z_ail,...
    SgnDup_ail);

% CLAF
fprintf(fileID,'CLAF\n');
claf_w = 1;
fprintf(fileID,'%0.2f\n',claf_w);
fprintf(fileID,'#-------------------------------------------------------------\n');


% SECTION 2
fprintf(fileID,'SECTION\n'); % SECTION

% Xle    Yle    Zle     Chord   Ainc  Nspanwise  Sspace
Xle_w_s2 = x_t_w;
Yle_w_s2 = y_t_w;
Zle_w_s2 = z_t_w;
chord_w_s2 = c_t_w;
Ainc_w_s2 = 0;
Nspanwise_w_s2 = 0;
Sspace_w_s2 = 0;
fprintf(fileID,'#Xle \t Yle \t Zle \t Chord \t Ainc \t Nspanwise \t Sspace\n');
fprintf(fileID,'%0.2f \t %0.2f \t %0.2f \t %0.2f \t %0.2f \t %d \t %d\n',...
    Xle_w_s2, Yle_w_s2, Zle_w_s2, chord_w_s2, Ainc_w_s2, Nspanwise_w_s2,...
    Sspace_w_s2);

% airfoil name
fprintf(fileID,'\nNACA\n'); % AFILE
fprintf(fileID,'%s\n',w_afile); % filename

% flap and aileron
fprintf(fileID,'\n#Cname \t Cgain \t Xhinge \t HingeVec \t SgnDup\n');
fprintf(fileID,'CONTROL\n'); % CONTROL Section
fprintf(fileID,'aileron %0.2f %0.2f %0.1f %0.1f %0.1f %0.1f\n\n',...
    Cgain_ail, Xhinge_ail, HingeVec_x_ail, HingeVec_y_ail, HingeVec_z_ail,...
    SgnDup_ail);

% CLAF
fprintf(fileID,'CLAF\n');
fprintf(fileID,'%0.2f\n',claf_w);
fprintf(fileID,'#====================================================================\n');

fclose(fileID);


%% AVL input file HS
fileID = fopen(fullfile(fileparts(which('avl.exe')),obj.hs_ip_file_name),'w');

% design name % Plane Vanilla
% des_Name = 'Plane Vanilla test';
fprintf(fileID,'%s\n',obj.hs_ip_file_name);

% Mach
fprintf(fileID,'#Mach\n');
fprintf(fileID,'%0.2f\n',Mach);

% IYsym   IZsym   Zsym
fprintf(fileID,'#IYsym   IZsym   Zsym\n');
fprintf(fileID,'%d \t\t %d\t\t %d\n',m_IYsym,m_IZsym,m_IXsym);

%  Sref    Cref    Bref
fprintf(fileID,'#Sref    Cref    Bref\n');
fprintf(fileID,'%0.2f \t %0.2f \t %0.2f\n',Sref,Cref,Bref);

% Xref    Yref    Zref
fprintf(fileID,'#Xref    Yref    Zref\n');
fprintf(fileID,'%0.2f \t %0.2f \t %0.2f\n',Xref,Yref,Zref);

fprintf(fileID,'#\n#\n#====================================================================\n');

% define HS: contains one section
fprintf(fileID,'SURFACE\n');    % initialize surface
fprintf(fileID,'H-stab\n');       % initialize surface wing

% Nchordwise  Cspace   Nspanwise   Sspace
Nchordwise_hs = N_c_hs;
Cspace_hs = 1;
Nspanwise_hs = N_b_hs;
Sspace_hs = 1;
fprintf(fileID,'#Nchordwise  Cspace   Nspanwise   Sspace\n');
fprintf(fileID,'%d \t %0.2f \t %d \t %0.2f\n',...
    Nchordwise_hs, Cspace_hs, Nspanwise_hs, Sspace_hs);

%
fprintf(fileID,'YDUPLICATE\n'); % toggle Y-duplicate

% YDUPLICATE
y_dup_hs = 0;
fprintf(fileID,'%0.1f\n',y_dup_hs);

% ANGLE
fprintf(fileID,'ANGLE\n'); % permanent incident angle
fprintf(fileID,'%0.1f\n',angle_w);
fprintf(fileID,'#-------------------------------------------------------------\n');

% SECTION 1
fprintf(fileID,'SECTION\n'); % SECTION

% Xle    Yle    Zle     Chord   Ainc  Nspanwise  Sspace
Xle_hs_s1 = 0;
Yle_hs_s1 = 0;
Zle_hs_s1 = 0;
chord_hs_s1 = c_r_hs;
Ainc_hs_s1 = 0;
Nspanwise_hs_s1 = 0;
Sspace_hs_s1 = 0;
fprintf(fileID,'#Xle    Yle    Zle     Chord   Ainc  Nspanwise  Sspace\n');
fprintf(fileID,'%0.2f %0.2f %0.2f %0.2f %0.2f %d %d\n',...
    Xle_hs_s1, Yle_hs_s1, Zle_hs_s1, chord_hs_s1, Ainc_hs_s1, Nspanwise_hs_s1,...
    Sspace_hs_s1);

% horizontal stabilizer airfoil
fprintf(fileID,'\nNACA\n'); % AFILE
fprintf(fileID,'%s\n\n',hs_afile); % filename

% flap and aileron
fprintf(fileID,'#Cname \t Cgain \t Xhinge \t HingeVec \t SgnDup\n');
fprintf(fileID,'CONTROL\n'); % CONTROL Section

% Cname   Cgain  Xhinge  HingeVec     SgnDup
fprintf(fileID,'aileron %0.2f %0.2f %0.1f %0.1f %0.1f %0.1f\n\n',...
    Cgain_ail, Xhinge_ail, HingeVec_x_ail, HingeVec_y_ail, HingeVec_z_ail,...
    SgnDup_ail);

% CLAF
fprintf(fileID,'CLAF\n');
fprintf(fileID,'%0.2f\n',claf_w);
fprintf(fileID,'#-------------------------------------------------------------\n');


% SECTION 2
fprintf(fileID,'SECTION\n'); % SECTION
fprintf(fileID,'#Xle    Yle    Zle     Chord   Ainc  Nspanwise  Sspace\n');
% Xle    Yle    Zle     Chord   Ainc  Nspanwise  Sspace
Xle_hs_s2 = x_t_hs;
Yle_hs_s2 = y_t_hs;
Zle_hs_s2 = z_t_hs;
chord_hs_s2 = c_t_hs;
Ainc_hs_s2 = 0;
Nspanwise_hs_s2 = 0;
Sspace_hs_s2 = 0;

fprintf(fileID,'%0.2f %0.2f %0.2f %0.2f %0.2f %d %d\n',...
    Xle_hs_s2, Yle_hs_s2, Zle_hs_s2, chord_hs_s2, Ainc_hs_s2, Nspanwise_hs_s2,...
    Sspace_hs_s2);

% horizontal stabilizer airfoil
fprintf(fileID,'\nNACA\n'); % AFILE
fprintf(fileID,'%s\n\n',hs_afile); % filename

% aileron
fprintf(fileID,'\n#Cname \t Cgain \t Xhinge \t HingeVec \t SgnDup\n');
fprintf(fileID,'CONTROL\n'); % CONTROL Section
fprintf(fileID,'aileron %0.2f %0.2f %0.1f %0.1f %0.1f %0.1f\n\n',...
    Cgain_ail, Xhinge_ail, HingeVec_x_ail, HingeVec_y_ail, HingeVec_z_ail,...
    SgnDup_ail);

% CLAF
fprintf(fileID,'CLAF\n');
fprintf(fileID,'%0.2f\n',claf_w);
fprintf(fileID,'#====================================================================\n');

fclose(fileID);


%% AVL input file VS
fileID = fopen(fullfile(fileparts(which('avl.exe')),obj.vs_ip_file_name),'w');

% design name % Plane Vanilla
% des_Name = 'Plane Vanilla test';
fprintf(fileID,'%s\n',obj.vs_ip_file_name);

% Mach
fprintf(fileID,'#Mach\n');
fprintf(fileID,'%0.2f\n',Mach);

% IYsym   IZsym   Zsym
fprintf(fileID,'#IYsym   IZsym   Zsym\n');
fprintf(fileID,'%d \t\t %d\t\t %d\n',m_IYsym,m_IZsym,m_IXsym);

%  Sref    Cref    Bref
fprintf(fileID,'#Sref    Cref    Bref\n');
fprintf(fileID,'%0.2f \t %0.2f \t %0.2f\n',Sref,Cref,Bref);

% Xref    Yref    Zref
fprintf(fileID,'#Xref    Yref    Zref\n');
fprintf(fileID,'%0.2f \t %0.2f \t %0.2f\n',Xref,Yref,Zref);

fprintf(fileID,'#\n#\n#====================================================================\n');

%% define HS: contains one section
fprintf(fileID,'SURFACE\n');    % initialize surface
fprintf(fileID,'V-stab\n');       % initialize surface wing

% Nchordwise  Cspace   Nspanwise   Sspace
Nchordwise_vs = N_c_vs;
Cspace_vs = 1;
Nspanwise_vs = N_b_vs;
Sspace_vs = 1;

fprintf(fileID,'%d %0.2f %d %0.2f\n',...
    Nchordwise_vs, Cspace_vs, Nspanwise_vs, Sspace_vs);

% ANGLE
fprintf(fileID,'ANGLE\n'); % permanent incident angle
fprintf(fileID,'%0.1f\n',angle_w);
fprintf(fileID,'#-------------------------------------------------------------\n');

% SECTION 1

fprintf(fileID,'SECTION\n'); % SECTION
fprintf(fileID,'#Xle    Yle    Zle     Chord   Ainc  Nspanwise  Sspace\n');
% Xle    Yle    Zle     Chord   Ainc  Nspanwise  Sspace
Xle_vs_s1 = 0;
Yle_vs_s1 = 0;
Zle_vs_s1 = 0;
chord_vs_s1 = c_r_vs;
Ainc_vs_s1 = 0;
Nspanwise_vs_s1 = 0;
Sspace_vs_s1 = 0;

fprintf(fileID,'%0.2f %0.2f %0.2f %0.2f %0.2f %d %d\n',...
    Xle_vs_s1, Yle_vs_s1, Zle_vs_s1, chord_vs_s1, Ainc_vs_s1, Nspanwise_vs_s1,...
    Sspace_vs_s1);

% vertical stabilizer airfoil
fprintf(fileID,'\nNACA\n'); % AFILE
fprintf(fileID,'%s\n\n',vs_afile); % filename

% aileron
fprintf(fileID,'#Cname \t Cgain \t Xhinge \t HingeVec \t SgnDup\n');
fprintf(fileID,'CONTROL\n'); % CONTROL Section

% Cname   Cgain  Xhinge  HingeVec     SgnDup
fprintf(fileID,'aileron %0.2f %0.2f %0.1f %0.1f %0.1f %0.1f\n\n',...
    Cgain_ail, Xhinge_ail, HingeVec_x_ail, HingeVec_y_ail, HingeVec_z_ail,...
    SgnDup_ail);

% CLAF
fprintf(fileID,'CLAF\n');
fprintf(fileID,'%0.2f\n',claf_w);
fprintf(fileID,'#-------------------------------------------------------------\n');


% SECTION 2
fprintf(fileID,'SECTION\n'); % SECTION
fprintf(fileID,'#Xle    Yle    Zle     Chord   Ainc  Nspanwise  Sspace\n');
% Xle    Yle    Zle     Chord   Ainc  Nspanwise  Sspace
Xle_vs_s2 = x_t_vs;
Yle_vs_s2 = z_t_vs;
Zle_vs_s2 = y_t_vs;
chord_vs_s2 = c_t_vs;
Ainc_vs_s2 = 0;
Nspanwise_vs_s2 = 0;
Sspace_vs_s2 = 0;

fprintf(fileID,'%0.2f %0.2f %0.2f %0.2f %0.2f %d %d\n',...
    Xle_vs_s2, Yle_vs_s2, Zle_vs_s2, chord_vs_s2, Ainc_vs_s2, Nspanwise_vs_s2,...
    Sspace_vs_s2);

% vertical stabilizer airfoil
fprintf(fileID,'\nNACA\n'); % AFILE
fprintf(fileID,'%s\n\n',vs_afile); % filename

% aileron
fprintf(fileID,'\n#Cname \t Cgain \t Xhinge \t HingeVec \t SgnDup\n');
fprintf(fileID,'CONTROL\n'); % CONTROL Section
fprintf(fileID,'aileron %0.2f %0.2f %0.1f %0.1f %0.1f %0.1f\n\n',...
    Cgain_ail, Xhinge_ail, HingeVec_x_ail, HingeVec_y_ail, HingeVec_z_ail,...
    SgnDup_ail);

% CLAF
fprintf(fileID,'CLAF\n');
fprintf(fileID,'%0.2f\n',claf_w);
fprintf(fileID,'#====================================================================\n');


fclose(fileID);

end