function [AR, Span, Ixx_lim, Ixx_flag] = steadyFlightOpt(wing,hStab,vStab,fuse,Sys,Env)

AR = 0;Span = 0; Ixx_lim = 0;

while ~Ixx_flag && AR_ul > AR_ll
    U = [(AR_ll+AR_ul)/2.0 8]';
    options = optimoptions('fmincon','Display',...
        'iter','Algorithm','sqp','MaxIterations',1e6,...
        'MaxFunctionEvaluations',1e6);
    J = @(U_0)wingVolumeCost(U_0,Lscale);
    C = @(U_0)powRatedConst(U_0,Lscale,Df,Lf,gammaw,eLw,Clw0,xg,h,Cdw_ind,Cfe,ClHStall,Prated,vf,eta,Cdh_ovrall,Cd0h);
    lb = [AR_ll 7]';
    ub = [AR_ul 10]'; %Get u(2) upper bound from examining min value of Lamda
    [uopt,~,conv_flag] = fmincon(J,U,[],[],[],[],lb,ub,C,options);
    [Ixx] = airfoil_grid_func(uopt(1),uopt(2));
    
    [~,~,Fz] = powRatedConst(uopt,Lscale,Df,Lf,gammaw,eLw,Clw0,xg,h,Cdw_ind,Cfe,ClHStall,Prated,vf,eta,Cdh_ovrall,Cd0h);
    
    S = uopt(2)/2.0;
    delx = defper*S/100.0;
    Ixx_req = 5*Fz*(S^3)/(48*E*delx);
    
    if (Ixx_req*(39.37^4) < Ixx && conv_flag == 1)
       Ixx_flag = true;
       AR = uopt(1);
       Span = uopt(2);
       Ixx_lim = Ixx;
       break;
    else
        AR_ul = AR_ul - 1.0;
    end
end
end
