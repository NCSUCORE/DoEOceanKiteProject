function vFlow = flowDist(alt,z,v)

z0 = z(1);
zF = z(2);
zT = (zF+z0)/2;

v0 = v(1);
vF = v(2);
vT = (vF+v0)/2;

b1 = 2.2;
b2 = 0.4;

pred1 = v0+(vT-v0).*(alt>zT)+(vF-vT).*(alt>zF);
pred2 = (vT-v0).*((alt-z0)./(zT-z0)).^b1.*(alt>z0).*(alt<=zT);
pred3 = (vF-vT).*((alt-zT)./(zF-zT)).^b2.*(alt>zT).*(alt<=zF);

vFlow = pred1+pred2+pred3;
