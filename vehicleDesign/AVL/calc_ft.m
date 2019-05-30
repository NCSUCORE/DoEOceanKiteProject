function calc_ft(ip_file_name,result_file_name,alpha,beta,flap,aileron,elevator,rudder)

%% file name
fileName_run = 'RunFile';
fileID_run = fopen(fileName_run,'w');

% create run file
fprintf(fileID_run,'\n');
fprintf(fileID_run,' ---------------------------------------------\n');
fprintf(fileID_run,' Run case  1:   -unnamed-                              \n');
fprintf(fileID_run,'\n');

% parameters
fprintf(fileID_run,' alpha        ->  alpha       =   %0.5f    \n',alpha);
fprintf(fileID_run,' beta         ->  beta        =   %0.5f    \n',beta);
fprintf(fileID_run,' pb/2V        ->  pb/2V       =   0.00000    \n');
fprintf(fileID_run,' qc/2V        ->  qc/2V       =   0.00000    \n');
fprintf(fileID_run,' rb/2V        ->  rb/2V       =   0.00000    \n');
fprintf(fileID_run,' flap         ->  flap        =   %0.5f    \n',flap);
fprintf(fileID_run,' aileron      ->  aileron     =   %0.5f    \n',aileron);
fprintf(fileID_run,' elevator     ->  elevator    =   %0.5f    \n',elevator);
fprintf(fileID_run,' rudder       ->  rudder      =   %0.5f    \n',rudder);
fprintf(fileID_run,'\n');

% copy paste stuff
fprintf(fileID_run,' alpha     =   0.00000     deg                             \n');
fprintf(fileID_run,' beta      =   0.00000     deg                             \n');
fprintf(fileID_run,' pb/2V     =   0.00000                                     \n');
fprintf(fileID_run,' qc/2V     =   0.00000                                     \n');
fprintf(fileID_run,' rb/2V     =   0.00000                                     \n');
fprintf(fileID_run,' CL        =   0.00000                                     \n');
fprintf(fileID_run,' CDo       =   0.00000                                     \n');
fprintf(fileID_run,' bank      =   0.00000     deg                             \n');
fprintf(fileID_run,' elevation =   0.00000     deg                             \n');
fprintf(fileID_run,' heading   =   0.00000     deg                             \n');
fprintf(fileID_run,' Mach      =   0.00000                                     \n');
fprintf(fileID_run,' velocity  =   0.00000     Lunit/Tunit                     \n');
fprintf(fileID_run,' density   =   1.00000     Munit/Lunit^3                   \n');
fprintf(fileID_run,' grav.acc. =   1.00000     Lunit/Tunit^2                   \n');
fprintf(fileID_run,' turn_rad. =   0.00000     Lunit                           \n');
fprintf(fileID_run,' load_fac. =   0.00000                                     \n');
fprintf(fileID_run,' X_cg      =  0.500000     Lunit                           \n');
fprintf(fileID_run,' Y_cg      =   0.00000     Lunit                           \n');
fprintf(fileID_run,' Z_cg      =   0.00000     Lunit                           \n');
fprintf(fileID_run,' mass      =   1.00000     Munit                           \n');
fprintf(fileID_run,' Ixx       =   1.00000     Munit-Lunit^2                   \n');
fprintf(fileID_run,' Iyy       =   1.00000     Munit-Lunit^2                   \n');
fprintf(fileID_run,' Izz       =   1.00000     Munit-Lunit^2                   \n');
fprintf(fileID_run,' Ixy       =   0.00000     Munit-Lunit^2                   \n');
fprintf(fileID_run,' Iyz       =   0.00000     Munit-Lunit^2                   \n');
fprintf(fileID_run,' Izx       =   0.00000     Munit-Lunit^2                   \n');
fprintf(fileID_run,' visc CL_a =   0.00000                                     \n');
fprintf(fileID_run,' visc CL_u =   0.00000                                     \n');
fprintf(fileID_run,' visc CM_a =   0.00000                                     \n');
fprintf(fileID_run,' visc CM_u =   0.00000                                     \n');

fclose(fileID_run);

%% run avl and get results
fileName_exe = 'txt_exe';
filePath = which('avl.exe');

fileID_exe = fopen(fileName_exe,'w');

% load input file
fprintf(fileID_exe,'load %s\n',ip_file_name);

% load run file
fprintf(fileID_exe,'case %s\n',fileName_run);

% enter oper menu
fprintf(fileID_exe,'oper\n');

% run case
fprintf(fileID_exe,'x\n');

% get total force output
fprintf(fileID_exe,'ft\n');

% enter file name
fprintf(fileID_exe,'%s\n',result_file_name);

% check if the results file exists
if isfile(result_file_name)
fprintf(fileID_exe,'o\n');
end

% exit oper menu
fprintf(fileID_exe,'\n');

% quit avl
fprintf(fileID_exe,'quit\n');

% dos('load test &');

fclose(fileID_exe);
% 
cmd_str = strcat(filePath,'<',fileName_exe);

dos(cmd_str);

delete(fileName_exe);

end