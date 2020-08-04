% function that creates input file
function avlCreateInputFilePart_v2LE(obj)

% simplify variable names
c_r_w = obj.wingRootChord.Value;
sw_w =  obj.wingSweep.Value;
di_w = obj.wingDihedral.Value;
tr_w = obj.wingTR.Value;
w_inc_angle = obj.wingIncidence.Value;
w_afile =  obj.wingAirfoil.Value;
b_w = 2 * obj.portWing.halfSpan.Value;
S_w = 2* obj.portWing.planformArea.Value;
c_t_w = c_r_w*tr_w; % tip chord
w_Ns = 50;
w_Nc = 10;

c_r_hs = obj.hStab.rootChord.Value;
sw_hs = obj.hStab.sweep.Value;
di_hs = obj.hStab.dihedral.Value;
tr_hs = obj.hStab.TR.Value;
hs_inc_angle = obj.hStab.incidence.Value;
hs_afile =  obj.hStab.Airfoil.Value;
b_hs = 2 * obj.hStab.halfSpan.Value;
c_t_hs = c_r_hs*tr_hs; % tip chord

c_r_vs = obj.vStab.rootChord.Value;
b_vs = obj.vStab.halfSpan.Value;
sw_vs = obj.vStab.sweep.Value;
tr_vs = obj.vStab.TR.Value;
vs_afile =  obj.vStab.Airfoil.Value;
c_t_vs = c_r_vs*tr_vs; % tip chord

% cm cordinates
R_ref = obj.rCM_LE.Value;

%% calculations
% wing and reference calculations %%%%%%%%%%%%%%%%%%
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
fileID = fopen(fullfile(fileparts(which('avl.exe')),'wing'),'w');

% design name % Plane Vanilla
% des_Name = 'Plane Vanilla test';
fprintf(fileID,'%s\n','wing');

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

fprintf(fileID,'#\n#\n#end