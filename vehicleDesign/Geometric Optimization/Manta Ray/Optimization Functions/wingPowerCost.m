function [J,Flift,CL,CD] = wingPowerCost(u,wing,hStab,vStab,fuse,Env)

ARw = u(1); 
alpha = u(2);

Sw = wing.b^2/ARw;
Sh = hStab.S;
Sv = vStab.S;
Sf = fuse.D^2*pi/4*cosd(alpha)+(fuse.D^2*pi/4+fuse.D*fuse.L)*(1-cosd(alpha));

CLw =         interp1(wing.alpha,wing.CL,alpha,'linear','extrap');
CLh = (Sh/Sw)*interp1(hStab.alpha,hStab.CL,alpha,'linear','extrap');

CDw =         interp1(wing.alpha,wing.CD,alpha,'linear','extrap');
CDh = (Sh/Sw)*interp1(hStab.alpha,hStab.CD,alpha,'linear','extrap');
CDv = (Sv/Sw)*interp1(vStab.alpha,vStab.CD,alpha,'linear','extrap');
CDf = (Sf/Sw)*(fuse.CD0*cosd(alpha)+(1-cosd(alpha)*fuse.CDs));

CL = CLw + CLh;
CD = CDw + CDh + CDv + CDf;

vApp = (CL/CD*Env.vFlow(1));
vApp = 2;

Flift = 1/2*Env.rho*vApp^2*CL*Sw;

J = -2/27*Env.rho*Env.vFlow(1)^3*CL^3/CD^2*Sw;

end 