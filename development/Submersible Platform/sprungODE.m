function D = sprungODE(t,x,system_param,T,Fol,Foh,T1,T2)

D = zeros(size(x));
k = system_param.k;
b = system_param.b;
lus = system_param.lus;
ms = system_param.ms;
g = system_param.g;
m = system_param.m;

grav = [0;0;-g];

R_s0 = x(1:3);
R_m0 = x(4:6);
V_s0 = x(7:9);
V_m0 = x(10:12);
R_sm = R_s0 - R_m0;
V_sm = V_s0 - V_m0;

D(1:3) = V_s0;
D(4:6) = V_m0;

Fspring = (k)*(norm(R_sm)-lus).*((R_sm)/norm(R_sm));
Fdamper = (b)*(V_sm).*((R_sm)/norm(R_sm));

D(7:9) = (1/ms)*(- Fspring - Fdamper + T + ms*grav) ;
D(10:12) = (1/m)*(Fol + Foh + T1 + T2 + Fspring + Fdamper) ;

end