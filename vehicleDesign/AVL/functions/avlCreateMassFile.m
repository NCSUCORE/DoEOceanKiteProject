function avlCreateMassFile(obj)

g = 9.81; % gravitational acceleration
rho = obj.fluidDensity.Value;

xCM = -obj.RwingLE_cm.Value(1);
yCM = obj.RwingLE_cm.Value(2);
zCM = obj.RwingLE_cm.Value(3);

mass = obj.mass.Value;

Ixx = obj.Ixx.Value;
Iyy = obj.Iyy.Value;
Izz = obj.Izz.Value;
Ixy = obj.Ixy.Value;
Ixz = obj.Ixz.Value;
Iyz = obj.Iyz.Value;

%% AVL input file WING
fileID = fopen(fullfile(fileparts(which('avl.exe')),'dsgnMassFile.mass'),'w');

%
fprintf(fileID,'#---------------------------------------------\n');
fprintf(fileID,'#  vehicle\n');
fprintf(fileID,'#  Dimensional unit and parameter data.\n');
fprintf(fileID,'#  Mass & Inertia breakdown.\n');
fprintf(fileID,'#---------------------------------------------\n\n');

fprintf(fileID,'#  Names and scalings for units to be used for trim and eigenmode calculations.\n');
fprintf(fileID,'#  The Lunit and Munit values scale the mass, xyz, and inertia table data below.\n');
fprintf(fileID,'#  Lunit value will also scale all lengths and areas in the AVL input file.\n');

fprintf(fileID,'Lunit = 1.000  m\n');
fprintf(fileID,'Munit = 1.0    kg\n');
fprintf(fileID,'Tunit = 1.0    s\n\n');

% grav and rho
fprintf(fileID,'#  Gravity and density to be used as default values in trim setup (saves runtime typing).\n');
fprintf(fileID,'#  Must be in the unit names given above (m,kg,s).\n');

fprintf(fileID,'g   = %0.2f\n',g);
fprintf(fileID,'rho = %0.3f\n\n',rho);

% inertia props
fprintf(fileID,'#---------------------------------------------\n');
fprintf(fileID,'#  Mass & Inertia breakdown.\n');
fprintf(fileID,'#  x y z  is location of items own CG.\n');
fprintf(fileID,'#  Ixx... are item inertias about items own CG.\n');
fprintf(fileID,'#  x,y,z system here must be exactly the same one used in the .avl input file\n');
fprintf(fileID,'#  (same orientation, same origin location, same length units)\n');


fprintf(fileID,'#  mass   x     y     z       Ixx   Iyy   Izz    Ixy  Ixz  Iyz\n');
fprintf(fileID,'   %0.2f %0.2f %0.2f %0.2f %0.2f %0.2f %0.2f %0.2f %0.2f %0.2f ! body\n',...
    mass,xCM,yCM,zCM,Ixx,Iyy,Izz,Ixy,Ixz,Iyz);

fclose(fileID);


end