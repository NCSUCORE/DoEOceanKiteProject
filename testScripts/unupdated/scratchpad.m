phi = linspace(0,2*pi,100);

A1 = 1+0.4*sin(phi)+0*sin(2*phi)+0*sin(4*phi);
A2 = 1+0*sin(phi)+0*sin(2*phi)+0*sin(4*phi);
x = A1.*sin(phi);
y = A2.*sin(2*phi);

plot(x,y)
