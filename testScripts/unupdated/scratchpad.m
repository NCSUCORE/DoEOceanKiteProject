
z0 = -2;
z = linspace(z0,0);
z1 = 0;
FStar = 1e6*9.8;
zStar = -0.05;
A = (FStar+1)*sin(0.5*pi*(zStar-z0)./(z1-z0));
F = @(z) (A./sin(0.5*pi*(z-z0)./(z1-z0)))-1;
plot(z,F(z))
F(zStar) == FStar
% ylim([0 10])