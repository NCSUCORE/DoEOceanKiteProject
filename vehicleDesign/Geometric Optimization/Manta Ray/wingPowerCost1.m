function [J,Flift] = wingPowerCost1(u,wing,hStab,vStab,fuse,Env)

ARw = u(1); 
alpha = u(2);

Sw = wing.bw^2/ARw;
Sh = hStab.Sh;
Sv = vStab.Sv;
Sf = fuse.D^2*pi/4*cos(alpha)+(fuse.D^2*pi/4+fuse.D*fuse.L)*(1-cos(alpha));

idxw = find(wing.alphaw == 0,1,'first');
idxh = find(hStab.alphah == 0,1,'first');
idxv = find(vStab.alphav == 0,1,'first');

CLaw = 2*pi*wing.gammaw/(1+((2*pi*wing.gammaw)/(pi*wing.eLw*ARw)));
CLah = 2*pi*hStab.gammah/(1+((2*pi*hStab.gammah)/(pi*hStab.eLh*hStab.ARh)));

CLw =          CLaw*alpha + wing.CLw(idxw);
CLh = (Sh/Sw)*(CLah*alpha + hStab.CLh(idxh));

CDw =           wing.CDw(idxw) + CLw^2/(pi*wing.eDw*ARw);
CDh = (Sh/Sw)*(hStab.CDh(idxh) + CLh^2/(pi*hStab.eDh*hStab.ARh));
CDv = (Sv/Sw)*(vStab.CDv(idxv));
CDf = (Sf/Sw)*(fuse.CD0f*cos(alpha)+(1-cos(alpha)*fuse.CD9f));

CL = CLw + CLh;
CD = CDw + CDh + CDv + CDf;

Flift = 1/2*Env.rho*(CL/CD*Env.vFlow)^2*CL*Sw;

J = -2/27*Env.rho*Env.vFlow^3*CL^3/CD^2*Sw;

end 