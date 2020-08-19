function [AR_opt,Span_opt,Volwing,Ixx_lim,Ixx_req,Fz_out,Power_out]=App_SFOT(Df_in,Lf_in)



global Df Lf Fz
global E defper
global AR_llim AR_ulim
global Skmax Sp1max Sp2max Sp3max
global Power


Df = Df_in;
Lf = Lf_in;

% AR limits
AR_ll = AR_llim;
AR_ul = AR_ulim;

Span_ll = AR_llim;
Span_ul = AR_ulim;

AR_opt = 0;Span_opt = 0; Ixx_lim = 0; Ixx_req1=0;
Ixx_flag = false;

while ~Ixx_flag && AR_ul > AR_ll
    u0 = [(AR_ll+AR_ul)/2.0 (Span_ll+Span_ul)/2]';
    options = optimoptions('fmincon','Display','iter','Algorithm','sqp','MaxFunctionEvaluations',1e6,'MaxIterations',1e6);

    lb = [AR_ll Span_ll]';
    ub = [AR_ul Span_ul]'; %Get u(2) upper bound from examining min value of Lamda
    [uopt Jopt conv_flag] = fmincon(@SFT_cost,u0,[],[],[],[],lb,ub,@SFT_constraint,options);
%     [Ixx_calc] = airfoil_grid_func(uopt(1),uopt(2));

    [Ixx_calc, A_skin, A_spar1,A_spar2,A_spar3]= App_Wing_MoICalc(uopt(2)/uopt(1), Skmax, Sp1max, Sp2max, Sp3max);
    Ixx_calc = Ixx_calc*(39.37^4);
    
    % Required MoI calculation
    S = uopt(2)/2.0;
    delx = defper*S/100.0;
    Ixx_req = (39.37^4)*5*(0.9)*Fz*(S^3)/(48*E*delx);
    
    % Factor by which we reduce AR
    AR_fac = 1.0;
    
    % Factor of safety between Ixx and Ixx_req (inch^4)
    fos_Ixx = 10.0;
    
    %How to approach required Ixx
    if Ixx_calc < Ixx_req
        AR_ul = AR_ul - AR_fac;
    end
    if (Ixx_calc - fos_Ixx > Ixx_req)
        AR_fac = 0.1;
        AR_ul = AR_ul + AR_fac;
    end
    
    if Ixx_calc - fos_Ixx < Ixx_req && Ixx_calc > Ixx_req && conv_flag == 1
        Ixx_flag = true;
        AR_opt = uopt(1);
        Span_opt = uopt(2)
        Ixx_lim = Ixx_calc
        Ixx_req1 = Ixx_req
        Volwing = Jopt
        AR_ul
        AR_opt
        Ixx_calc
        Ixx_req
        Fz_out = Fz
        break;
    end
        AR_ul
        AR_opt
        Ixx_calc
        Ixx_req1
        Fz_out = Fz
        Power_out = Power
    
    
end

end
function J = SFT_cost(u)

global Lscale ChrdT
 
Span = u(2)*Lscale; 

J = ChrdT*Span^3/u(1)^2 ;

end 


function [c_ineq, c_eq] = SFT_constraint(u)

global Fz Df Lf Lscale Lscale gammaw eLw Clw0 x_g h_sm Cdw_visc Cdw_ind Cfuse ClHStall
global eta netaV Cdh_ovrall Cd0_h rho Preq vin
global Power
Cd0w = 0.00015.*u(1) + 0.0053;

Len = Lf*Lscale; 
Dia = Df*Lscale; 
lamda = Len/Dia;
L = Len*0.7; 

% Angle of atack 
AoA = -12.5:0.5:12;                                                         % upto stall angles (User defined) 
AoA = AoA.*(pi/180); 

% u(1) = AR 
% u(2) = X (Len Wing-Teth/Len HStab-Teth)

% Areas  
% Sh = 2;                 %(for AR 8)
Span = u(2)*Lscale; 
Sw = (Span^2)/u(1); 
Swet = pi*Len*Dia*((1 - (2/lamda))^(2/3))*(1 + 1/(lamda^2)); 

% Wing 
slopeW = ((2*pi*gammaw)./(1+((2.*pi.*gammaw)./(pi.*eLw.*u(1)))));
Clw = Clw0 + slopeW.*AoA ; 

ClwD0 = 0.0026.*u(1); 
Cd0w = (0.00015.*u(1) + 0.0053);
Cd0w = ones(1,numel(AoA)).*Cd0w; 
Cdw = (Cdw_ind./u(1)+0.0334).*(Clw-ClwD0).^2 + Cd0w;  

% HStab 
Sh = ((x_g-h_sm)/(L+h_sm-x_g))*Sw;                                                  % Area gotten by satisfying stability margins 
xeta = (ClHStall*Sh)/((Sw*max(Clw)) + (ClHStall*Sh));                       % maximizing lift from H.Stabilizer 
Clh = (Sw*Clw*xeta)./(Sh*(1-xeta));                                         % Lift of H.Stabilizer 
Cdh = Cdh_ovrall.*((Clh*(Sh/Sw)).^2) + Cd0_h; 

% Fuselage 
CD_fuse = Cfuse*(Swet/Sw); 

% Net Lift 
CL = Clw + (Clh*(Sh/Sw)); 

% Net Drag 
CD = Cdw + (Cdh*(Sh/Sw)) + CD_fuse; 

% Performance metric 1: Finding optimal AoA 
Perf_1 = max((CL.^3./CD.^2));


Power = (2/27)*eta*Perf_1*Sw*(vin^3); 
% Calculating tensions/Lifts  
splSpeed = vin/3; 
Fz = 0.5*Power/splSpeed*(10^3);


ineq1 = Preq - Power; 

c_ineq = ineq1;
c_eq = []; 

end 
