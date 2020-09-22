AR = 10;
gammaw = 0.9512;
eLw = 0.7019;
Clw0 = 0.16;
Cdw_visc = 0.0297;
Cdw_ind = 0.2697;

AoA = linspace(-55,55,100);

[CL,CD] = XFLRWingCalc(AoA,AR,gammaw,eLw,Clw0,Cdw_visc,Cdw_ind);


figure;
plot(AoA,CL)
figure;
plot(AoA,CD)

figure;
plot(AoA,CL./CD)