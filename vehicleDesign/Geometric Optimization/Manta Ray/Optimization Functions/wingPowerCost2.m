function [J,Flift,CL,CD] = wingPowerCost2(u,wing,hStab,vStab,fuse,Env)

ARw = u(1); 
alpha = u(2)*pi/180;

Sw = wing.b^2/ARw;
Sh = hStab.S;
Sv = vStab.S;
Sf = fuse.D^2*pi/4*cos(alpha)+(fuse.D^2*pi/4+fuse.D*fuse.L)*(1-cos(alpha));

CLw =         interp1(wing.alpha*pi/180,wing.CL,alpha,'linear','extrap');
CLh = (Sh/Sw)*interp1(hStab.alpha*pi/180,hStab.CL,alpha,'linear','extrap');

CDw =         interp1(wing.alpha*pi/180,wing.CD,alpha,'linear','extrap');
CDh = (Sh/Sw)*interp1(hStab.alpha*pi/180,hStab.CD,alpha,'linear','extrap');
CDv = (Sv/Sw)*interp1(vStab.alpha*pi/180,vStab.CD,alpha,'linear','extrap');
CDf = (Sf/Sw)*(fuse.CD0*cos(alpha)+(1-cos(alpha)*fuse.CDs));

CL = CLw + CLh;
CD = CDw + CDh + CDv + CDf;

% vApp = (CL/CD*Env.vFlow(1));
vApp = 4;

Flift = 1/2*Env.rho*vApp^2*CL*Sw;

J = -2/27*Env.rho*Env.vFlow(1)^3*CL^3/CD^2*Sw;

end 