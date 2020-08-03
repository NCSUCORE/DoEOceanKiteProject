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

% horizonatal stbilizer calculations %%%%%%%%%%%%%
% HS tip cordinates
x_t_hs = (b_hs/2)*tand(sw_hs);
y_t_hs = (b_hs/2);
z_t_hs = (b_hs/2)*tand(di_hs);

% vertical stabilizer calculations
% HS tip cordinates
x_t_vs = b_vs*tand(sw_vs);
y_t_vs = 0;
z_t_vs = b_vs;

%% AVL input file WING
fileID = fopen(fullfile(fileparts(which('avl.exe')),'wing'),'w');

% open file
printName(fileID,'Wing');

% Mach
Mach = 0.0;
setMachNumber(fileID,Mach);

% IYsym, IZsym, Zsym
setSymmetryProperties(fileID,0,0,0);

% Sref, Cref, Bref
Sref =  S_w;
Cref = (c_r_w + c_t_w)/2;
Bref = b_w;

setReferenceProperties(fileID,Sref,Cref,Bref,...
    R_ref(1),R_ref(2),R_ref(3))

sectionBreak(fileID);

%% define wing: contains one section
fprintf(fileID,'SURFACE\n');    % initialize surface
fprintf(fileID,'Wing\n');       % initialize surface wing

% Nchordwise, Cspace, Nspanwise, Sspace
setAvlAnalysisParameters(fileID,w_Nc,1,w_Ns,1);

% permanent incident angle
setIncidenceAngle(fileID,w_inc_angle);
sectionBreak(fileID);

% SECTION 1
fprintf(fileID,'SECTION\n'); 

% Xle, Yle, Zle, Chord, Ainc, Nspanwise, Sspace
defineSection(fileID,0,0,0,c_r_w,0,0,0);

% airfoil name
setAirfoil(fileID,w_afile)

% Cname, Cgain, Xhinge, HingeVec, SgnDup
Cgain_ail = 1;
Xhinge_ail = 0.75;
HingeVecAil = [0;0;0];
SgnDup_ail = 1;
claf_w = 1;

% aileron
defineCtrlSurface(fileID,'aileron',Cgain_ail,Xhinge_ail,...
    HingeVecAil,SgnDup_ail);

% CLAF
setClaf(fileID,claf_w);
sectionBreak(fileID);

% SECTION 2
fprintf(fileID,'SECTION\n'); 

% Xle, Yle, Zle, Chord, Ainc, Nspanwise, Sspace
defineSection(fileID,x_t_w,y_t_w,z_t_w,c_t_w,0,0,0);

% airfoil name
setAirfoil(fileID,w_afile)

% aileron
defineCtrlSurface(fileID,'aileron',Cgain_ail,Xhinge_ail,...
    HingeVecAil,SgnDup_ail);

% CLAF
setClaf(fileID,claf_w);
sectionBreak(fileID);

fclose(fileID);

%% AVL input file HS
fileID = fopen(fullfile(fileparts(which('avl.exe')),'H_stab'),'w');

% name
printName(fileID,'H_stab');

% Mach
setMachNumber(fileID,Mach);

% IYsym, IZsym, Zsym
setSymmetryProperties(fileID,0,0,0);

%  Sref, Cref, Bref, Xref, Yref, Zref
setReferenceProperties(fileID,Sref,Cref,Bref,R_ref(1),R_ref(2),R_ref(3));
sectionBreak(fileID);

% initialize surface: H-stab
fprintf(fileID,'SURFACE\n');    
fprintf(fileID,'H-stab\n');    

% Nchordwise, Cspace, Nspanwise, Sspace
setAvlAnalysisParameters(fileID,w_Nc,1,w_Ns,1);

% toggle Y-duplicate
fprintf(fileID,'YDUPLICATE\n');
fprintf(fileID,'%0.1f\n',0);

% permanent incident angle
setIncidenceAngle(fileID,hs_inc_angle);
sectionBreak(fileID);

% SECTION 1
fprintf(fileID,'SECTION\n'); 

% Xle, Yle, Zle, Chord, Ainc, Nspanwise, Sspace
defineSection(fileID,0,0,0,c_r_hs,0,0,0);

% horizontal stabilizer airfoil
setAirfoil(fileID,hs_afile);

% elevator (defined as aileron)
defineCtrlSurface(fileID,'aileron',Cgain_ail,Xhinge_ail,...
    HingeVecAil,SgnDup_ail);

% CLAF
setClaf(fileID,claf_w);
sectionBreak(fileID);

% SECTION 2
fprintf(fileID,'SECTION\n');

% Xle, Yle, Zle, Chord, Ainc, Nspanwise, Sspace
defineSection(fileID,x_t_hs,y_t_hs,z_t_hs,c_t_hs,0,0,0);

% horizontal stabilizer airfoil
setAirfoil(fileID,hs_afile);

% elevator (defined as aileron)
defineCtrlSurface(fileID,'aileron',Cgain_ail,Xhinge_ail,...
    HingeVecAil,SgnDup_ail);

% CLAF
setClaf(fileID,claf_w);
sectionBreak(fileID);

% close file
fclose(fileID);


%% AVL input file VS
fileID = fopen(fullfile(fileparts(which('avl.exe')),'V_stab'),'w');

% name
printName(fileID,'V_stab');

% Mach
setMachNumber(fileID,Mach);

% IYsym, IZsym, Zsym
setSymmetryProperties(fileID,0,0,0);

%  Sref, Cref, Bref, Xref, Yref, Zref
setReferenceProperties(fileID,Sref,Cref,Bref,R_ref(1),R_ref(2),R_ref(3));
sectionBreak(fileID);

% define surface: V-stab
fprintf(fileID,'SURFACE\n');    
fprintf(fileID,'V-stab\n');       

% Nchordwise, Cspace, Nspanwise, Sspace
setAvlAnalysisParameters(fileID,w_Nc,1,w_Ns,1);

% permanent incident angle
setIncidenceAngle(fileID,w_inc_angle);
sectionBreak(fileID);

% SECTION 1
fprintf(fileID,'SECTION\n');

% Xle, Yle, Zle, Chord, Ainc, Nspanwise, Sspace
defineSection(fileID,0,0,0,c_r_vs,0,0,0);

% vertical stabilizer airfoil
setAirfoil(fileID,vs_afile);

% rudder (defined as aileron)
defineCtrlSurface(fileID,'aileron',Cgain_ail,Xhinge_ail,...
    HingeVecAil,SgnDup_ail);

% CLAF
setClaf(fileID,claf_w);
sectionBreak(fileID);

% SECTION 2
fprintf(fileID,'SECTION\n'); % SECTION
% Xle, Yle, Zle, Chord, Ainc, Nspanwise, Sspace
defineSection(fileID,x_t_vs,z_t_vs,y_t_vs,c_t_vs,0,0,0);

% vertical stabilizer airfoil
setAirfoil(fileID,vs_afile);

% rudder (defined as aileron)
defineCtrlSurface(fileID,'aileron',Cgain_ail,Xhinge_ail,...
    HingeVecAil,SgnDup_ail);

% CLAF
setClaf(fileID,claf_w);
sectionBreak(fileID)

fclose(fileID);

end

%% local functions

% check the airfoil name, look for dat file and set in the input file
function setAirfoil(fileID,airfoilName)

if startsWith(airfoilName,'NACA')
    fprintf(fileID,'\nNACA\n'); % AFILE
    fprintf(fileID,'%s\n\n',strtrim(erase(airfoilName,'NACA'))); % filename
elseif endsWith(airfoilName,'.dat')
    if isfile(strcat(fileparts(which('avl.exe')),'\',airfoilName))
        fprintf(fileID,'\nAFIL\n'); % AFILE
        fprintf(fileID,'%s\n\n',airfoilName); % filename
    else
        error([airfoilName,' not found in ',fileparts(which('avl.exe'))]);
    end
else
    error(['Please provide airfoil name property that either starts with ',...
        '"NACA" for NACA airfoils or ends with ".dat" to load airfoil ',...
        'from a dat file. eg. NACA0015 or afoil.dat']);
end

end

function defineSection(fileID,xLeadingEdge,yLeadingEdge,zLeadingEdge,...
    chord,incidenceAngle,spanwiseSections,sSpace)

% Xle,Yle,Zle =  airfoil's leading edge location
%   Chord       =  the airfoil's chord  (trailing edge is at Xle+Chord,Yle,Zle)
%   Ainc        =  incidence angle, taken as a rotation (+ by RH rule) about 
%                  the surface's spanwise axis projected onto the Y-Z plane.  
%   Nspan       =  number of spanwise vortices until the next section 
%   Sspace      =  controls the spanwise spacing of the vortices      
  
fprintf(fileID,'#Xle \t Yle \t Zle \t Chord \t Ainc \t Nspanwise \t Sspace\n');
fprintf(fileID,'%0.2f \t %0.2f \t %0.2f \t %0.2f \t %0.2f \t %d \t\t\t %d\n',...
    xLeadingEdge, yLeadingEdge, zLeadingEdge, chord, incidenceAngle,...
    spanwiseSections,sSpace);
end

function setSymmetryProperties(fileID,iYsym,iZsym,Zsym)
% iYsym =  1  case is symmetric about Y=0    , (X-Z plane is a solid wall)
%       = -1  case is antisymmetric about Y=0, (X-Z plane is at const. Cp)
%       =  0  no Y-symmetry is assumed
% 
% iZsym =  1  case is symmetric about Z=Zsym    , (X-Y plane is a solid wall)
%       = -1  case is antisymmetric about Z=Zsym, (X-Y plane is at const. Cp)
%       =  0  no Z-symmetry is assumed (Zsym ignored)

fprintf(fileID,'#IYsym   IZsym   Zsym\n');
fprintf(fileID,'%d \t\t %d\t\t %d\n',iYsym,iZsym,Zsym);
end

function setReferenceProperties(fileID,refArea,refChord,refSpan,...
    xRef,yRef,zRef)

% Sref  = reference area  used to define all coefficients (CL, CD, Cm, etc)
% Cref  = reference chord used to define pitching moment (Cm)
% Bref  = reference span  used to define roll,yaw moments (Cl,Cn)
% 
% X,Y,Zref = default location about which moments and rotation rates are defined
%              (if doing trim calculations, XYZref must be the CG location,
%               which can be imposed with the MSET command described later)

% Sref, Cref, Bref
fprintf(fileID,'#Sref    Cref    Bref\n');
fprintf(fileID,'%0.2f \t %0.2f \t %0.2f\n',refArea,refChord,refSpan);
% Xref, Yref, Zref
fprintf(fileID,'#Xref    Yref    Zref\n');
fprintf(fileID,'%0.2f \t %0.2f \t %0.2f\n',xRef,yRef,zRef);

end

function defineCtrlSurface(fileID,typeOfSurface,ctrlGain,normalizedHingeLoc,...
    hingeVec,signDuplication)
% The CONTROL keyword declares that a hinge deflection at this section
% is to be governed by one or more control variables.  An arbitrary number 
% of control variables can be used, limited only by the array limit NDMAX.
% 
% The data line quantities are...
% 
%  name     name of control variable
%  gain     control deflection gain, units:  degrees deflection / control variable
%  Xhinge   x/c location of hinge.  
%            If positive, control surface extent is Xhinge..1  (TE surface)
%            If negative, control surface extent is 0..-Xhinge (LE surface)
%  XYZhvec  vector giving hinge axis about which surface rotates 
%            + deflection is + rotation about hinge vector by righthand rule
%            Specifying XYZhvec = 0. 0. 0. puts the hinge vector along the hinge
%  SgnDup   sign of deflection for duplicated surface
%            An elevator would have SgnDup = +1
%            An aileron  would have SgnDup = -1       

fprintf(fileID,'CONTROL\n'); % CONTROL Section
fprintf(fileID,'#Cname \t\tCgain \tx/c \txHinge \tyHinge \tzHinge \tSgnDup\n');
fprintf(fileID,'%s \t%0.2f \t%0.2f \t%0.1f \t%0.1f \t%0.1f \t%0.1f\n\n',...
    typeOfSurface,ctrlGain,normalizedHingeLoc,hingeVec(1),hingeVec(2),...
    hingeVec(3),signDuplication);
end

function setClaf(fileID,claf)
% This scales the effective dcl/da of the section airfoil as follows:
%  dcl/da  =  2 pi CLaf
% The implementation is simply a chordwise shift of the control point
% relative to the bound vortex on each vortex element.
% 
% The intent is to better represent the lift characteristics 
% of thick airfoils, which typically have greater dcl/da values
% than thin airfoils.  A good estimate for CLaf from 2D potential
% flow theory is
% 
%   CLaf  =  1 + 0.77 t/c
% 
% where t/c is the airfoil's thickness/chord ratio.  In practice,
% viscous effects will reduce the 0.77 factor to something less.
% Wind tunnel airfoil data or viscous airfoil calculations should
% be consulted before choosing a suitable CLaf value.
% 
% If the CLAF keyword is absent for a section, CLaf defaults to 1.0, 
% giving the usual thin-airfoil lift slope  dcl/da = 2 pi.  
fprintf(fileID,'CLAF\n');
fprintf(fileID,'%0.2f\n',claf);
end

function setAvlAnalysisParameters(fileID,nChord,cSpace,nSpan,sSpace)
% Nchord =  number of chordwise horseshoe vortices placed on the surface
% Cspace =  chordwise vortex spacing parameter (described later)
% 
% Nspan  =  number of spanwise horseshoe vortices placed on the surface [optional]
% Sspace =  spanwise vortex spacing parameter (described later)         [optional]

fprintf(fileID,'#Nchord \tCspace \tNspan \tSspace\n');
fprintf(fileID,'%d \t\t\t%0.2f \t%d \t\t%0.2f\n',...
    nChord,cSpace,nSpan,sSpace);

end

function setIncidenceAngle(fileID,incidenceAngle)
fprintf(fileID,'\nANGLE\n');
fprintf(fileID,'%0.1f\n',incidenceAngle);
end

function setMachNumber(fileID,machNumber)
%   Mach  = default freestream Mach number for Prandtl-Glauert correction
fprintf(fileID,'#Mach\n');
fprintf(fileID,'%0.2f\n',machNumber);
end

function printName(fileID,name)
fprintf(fileID,'%s\n',name);
end

function sectionBreak(fileID)
fprintf(fileID,'#-------------------------------------------------------------\n');
end