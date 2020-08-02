function [J,Flift] = wingPowerCost2(u,wing,hStab,vStab,fuse,Env)

ARw = u(1); 
alpha = u(2);

Sw = wing.bw^2/ARw;
Sh = hStab.Sh;
Sv = vStab.Sv;
Sf = fuse.D^2*pi/4*cos(alpha)+(fuse.D^2*pi/4+fuse.D*fuse.L)*(1-cos(alpha));

CLw =         interp1(wing.alphaw*pi/180,wing.CLw,alpha,'linear','extrap');
CLh = (Sh/Sw)*interp1(hStab.alphah*pi/180,hStab.CLh,alpha,'linear','extrap');

CDw =         interp1(wing.alphaw*pi/180,wing.CDw,alpha,'linear','extrap');
CDh = (Sh/Sw)*interp1(hStab.alphah*pi/180,hStab.CDh,alpha,'linear','extrap');
CDv = (Sv/Sw)*interp1(vStab.alphav*pi/180,vStab.CDv,alpha,'linear','extrap');
CDf = (Sf/Sw)*(fuse.CD0f*cos(alpha)+(1-cos(alpha)*fuse.CD9f));

CL = CLw + CLh;
CD = CDw + CDh + CDv + CDf;

Flift = 1/2*Env.rho*(CL/CD*Env.vFlow)^2*CL*Sw;

J = -2/27*Env.rho*Env.vFlow^3*CL^3/CD^2*Sw;

end 