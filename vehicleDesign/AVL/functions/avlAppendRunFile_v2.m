function avlAppendRunFile_v2(fileID,runCaseNumber,...
    alpha,aileron)
% create run file
fprintf(fileID,'\n');
fprintf(fileID,' ---------------------------------------------\n');
fprintf(fileID,' Run case  %d:   -unnamed-                              \n',runCaseNumber);
fprintf(fileID,'\n');

% parameters
fprintf(fileID,' alpha        ->  alpha       =   %0.5f    \n',alpha);
fprintf(fileID,' beta         ->  beta        =   %0.5f    \n',0);
fprintf(fileID,' pb/2V        ->  pb/2V       =   0.00000    \n');
fprintf(fileID,' qc/2V        ->  qc/2V       =   0.00000    \n');
fprintf(fileID,' rb/2V        ->  rb/2V       =   0.00000    \n');
fprintf(fileID,' flap         ->  flap        =   %0.5f    \n',0);
fprintf(fileID,' aileron      ->  aileron     =   %0.5f    \n',aileron);
fprintf(fileID,' elevator     ->  elevator    =   %0.5f    \n',0);
fprintf(fileID,' rudder       ->  rudder      =   %0.5f    \n',0);
fprintf(fileID,'\n');

% copy paste stuff
fprintf(fileID,' alpha     =   0.00000     deg                             \n');
fprintf(fileID,' beta      =   0.00000     deg                             \n');
fprintf(fileID,' pb/2V     =   0.00000                                     \n');
fprintf(fileID,' qc/2V     =   0.00000                                     \n');
fprintf(fileID,' rb/2V     =   0.00000                                     \n');
fprintf(fileID,' CL        =   0.00000                                     \n');
fprintf(fileID,' CDo       =   0.00000                                     \n');
fprintf(fileID,' bank      =   0.00000     deg                             \n');
fprintf(fileID,' elevation =   0.00000     deg                             \n');
fprintf(fileID,' heading   =   0.00000     deg                             \n');
fprintf(fileID,' Mach      =   0.00000                                     \n');
fprintf(fileID,' velocity  =   0.00000     Lunit/Tunit                     \n');
fprintf(fileID,' density   =   1.00000     Munit/Lunit^3                   \n');
fprintf(fileID,' grav.acc. =   1.00000     Lunit/Tunit^2                   \n');
fprintf(fileID,' turn_rad. =   0.00000     Lunit                           \n');
fprintf(fileID,' load_fac. =   0.00000                                     \n');
fprintf(fileID,' X_cg      =  0.500000     Lunit                           \n');
fprintf(fileID,' Y_cg      =   0.00000     Lunit                           \n');
fprintf(fileID,' Z_cg      =   0.00000     Lunit                           \n');
fprintf(fileID,' mass      =   1.00000     Munit                           \n');
fprintf(fileID,' Ixx       =   1.00000     Munit-Lunit^2                   \n');
fprintf(fileID,' Iyy       =   1.00000     Munit-Lunit^2                   \n');
fprintf(fileID,' Izz       =   1.00000     Munit-Lunit^2                   \n');
fprintf(fileID,' Ixy       =   0.00000     Munit-Lunit^2                   \n');
fprintf(fileID,' Iyz       =   0.00000     Munit-Lunit^2                   \n');
fprintf(fileID,' Izx       =   0.00000     Munit-Lunit^2                   \n');
fprintf(fileID,' visc CL_a =   0.00000                                     \n');
fprintf(fileID,' visc CL_u =   0.00000                                     \n');
fprintf(fileID,' visc CM_a =   0.00000                                     \n');
fprintf(fileID,' visc CM_u =   0.00000                                     \n');
end