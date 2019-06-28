% function that creates input file
function avlCreateInputFilePart(obj,avlFileName)

% Rotate all the corner points so that they lie along the starboard wing
% direction so that alpha works for the vertical stabilizer
xUnitVec = obj.chordUnitVec.Value;
yUnitVec = obj.spanUnitVec.Value;
zUnitVec = cross(xUnitVec,yUnitVec);

corners = obj.cornerPoints.Value;
corners = corners - repmat(corners(:,1),[1 4]);
corners = [xUnitVec(:)'; yUnitVec(:)'; zUnitVec(:)']*corners;

p1 = corners(:,1);
p2 = corners(:,2);
p3 = corners(:,3);
p4 = corners(:,4);

% simplify variable names
c_r_w = norm(p4-p1);
w_inc_angle = obj.incidenceAngle.Value;
w_afile =  obj.airfoil;
w_Ns = obj.numSpanwise.Value;
w_Nc = obj.numChordwise.Value;


Cgain_ail = 1;
Xhinge_ail = 0.75;
HingeVec_x_ail = 0;
HingeVec_y_ail = 1;
HingeVec_z_ail = 0;
SgnDup_ail = 1;

% cm cordinates
R_ref = obj.aeroRefPoint.Value;

%% calculations
% wing and reference calculations %%%%%%%%%%%%%%%%%%
% span
b_w = obj.span.Value;
% planform area
S_w = obj.refArea.Value;
% tip chord
c_t_w = obj.tipChord.Value;
% wing tip coordinates
x_t_w = p2(1);
y_t_w = p2(2);
z_t_w = p2(3);

% spacing parameters
N_b_w = w_Ns;
N_c_w = w_Nc;

% error messages
if mod(N_c_w,1) ~= 0 || N_c_w <= 0
    error('The calculated values of number of chordwise elements will lead to errors in AVL')
end
if mod(N_b_w,1) ~= 0 || N_b_w <= 0
    error('The calculated values of number of span elements will lead to errors in AVL')
end

fileID = fopen(avlFileName,'w');

fprintf(fileID,'%s\n','aeroSurf');

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
Cref = obj.meanChord.Value;
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
Xle_w_s1 = p1(1);
Yle_w_s1 = p1(2);
Zle_w_s1 = p1(3);
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

end