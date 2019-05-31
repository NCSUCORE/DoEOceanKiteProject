function appendAVLRunCase(fid,caseNum,alpha,beta,flap,aileron,elevator,rudder)
% create run file
fprintf(fid,'\n');
fprintf(fid,' ---------------------------------------------\n');
fprintf(fid,' Run case  %d:   -unnamed-                              \n',caseNum);
fprintf(fid,'\n');

% parameters
fprintf(fid,' alpha        ->  alpha       =   %0.5f    \n',alpha);
fprintf(fid,' beta         ->  beta        =   %0.5f    \n',beta);
fprintf(fid,' pb/2V        ->  pb/2V       =   0.00000    \n');
fprintf(fid,' qc/2V        ->  qc/2V       =   0.00000    \n');
fprintf(fid,' rb/2V        ->  rb/2V       =   0.00000    \n');
fprintf(fid,' flap         ->  flap        =   %0.5f    \n',flap);
fprintf(fid,' aileron      ->  aileron     =   %0.5f    \n',aileron);
fprintf(fid,' elevator     ->  elevator    =   %0.5f    \n',elevator);
fprintf(fid,' rudder       ->  rudder      =   %0.5f    \n',rudder);
fprintf(fid,'\n');

% copy paste stuff
fprintf(fid,' alpha     =   0.00000     deg                             \n');
fprintf(fid,' beta      =   0.00000     deg                             \n');
fprintf(fid,' pb/2V     =   0.00000                                     \n');
fprintf(fid,' qc/2V     =   0.00000                                     \n');
fprintf(fid,' rb/2V     =   0.00000                                     \n');
fprintf(fid,' CL        =   0.00000                                     \n');
fprintf(fid,' CDo       =   0.00000                                     \n');
fprintf(fid,' bank      =   0.00000     deg                             \n');
fprintf(fid,' elevation =   0.00000     deg                             \n');
fprintf(fid,' heading   =   0.00000     deg                             \n');
fprintf(fid,' Mach      =   0.00000                                     \n');
fprintf(fid,' velocity  =   0.00000     Lunit/Tunit                     \n');
fprintf(fid,' density   =   1.00000     Munit/Lunit^3                   \n');
fprintf(fid,' grav.acc. =   1.00000     Lunit/Tunit^2                   \n');
fprintf(fid,' turn_rad. =   0.00000     Lunit                           \n');
fprintf(fid,' load_fac. =   0.00000                                     \n');
fprintf(fid,' X_cg      =  0.500000     Lunit                           \n');
fprintf(fid,' Y_cg      =   0.00000     Lunit                           \n');
fprintf(fid,' Z_cg      =   0.00000     Lunit                           \n');
fprintf(fid,' mass      =   1.00000     Munit                           \n');
fprintf(fid,' Ixx       =   1.00000     Munit-Lunit^2                   \n');
fprintf(fid,' Iyy       =   1.00000     Munit-Lunit^2                   \n');
fprintf(fid,' Izz       =   1.00000     Munit-Lunit^2                   \n');
fprintf(fid,' Ixy       =   0.00000     Munit-Lunit^2                   \n');
fprintf(fid,' Iyz       =   0.00000     Munit-Lunit^2                   \n');
fprintf(fid,' Izx       =   0.00000     Munit-Lunit^2                   \n');
fprintf(fid,' visc CL_a =   0.00000                                     \n');
fprintf(fid,' visc CL_u =   0.00000                                     \n');
fprintf(fid,' visc CM_a =   0.00000                                     \n');
fprintf(fid,' visc CM_u =   0.00000                                     \n');
end