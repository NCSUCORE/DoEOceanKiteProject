% Re = 4595; (water at 20 C)
%% For naca2412

load('ayaz_xfoil.mat')

a1 = n2412(:,1); 
Cl1 = n2412(:,2);
Cd1 = n2412(:,3);
Cdp1 = n2412(:,4);
Cdf1 = Cd1 - Cdp1; 
ld1 = Cl1./Cd1; 
% plotting 
figure
plot(a1, Cl1)
xlabel('alfa in degrees') 
ylabel('C_l Lift coefficient') 
title('Lift coefficient vs Anlge of Attack NACA2412')
grid on 

figure
plot(a1, Cd1)
xlabel('alfa in degrees') 
ylabel('C_d Drag coefficient') 
title('Drag coefficient vs Anlge of Attack NACA2412')
grid on 

figure
plot(a1, ld1)
xlabel('alfa in degrees') 
ylabel('L/D') 
title('Lift to Drag ratio vs Anlge of Attack NACA2412')
grid on 

figure
plot(a1, Cdp1)
hold on 
plot(a1, Cdf1,'--')
xlabel('alfa in degrees') 
ylabel('Drag coefficients') 
title('Drag coefficients vs Anlge of Attack NACA2412')
legend('Pressure drag','Friction drag')
grid on 

%% For naca0015

a2 = n0015(:,1); 
Cl2 = n0015(:,2);
Cd2 = n0015(:,3);
Cdp2 = n0015(:,4);
Cdf2 = Cd2 - Cdp2; 
ld2 = Cl2./Cd2; 
% plotting 
figure
plot(a2, Cl2)
xlabel('alfa in degrees') 
ylabel('C_l Lift coefficient') 
title('Lift coefficient vs Anlge of Attack NACA0015')
grid on 

figure
plot(a2, Cd2)
xlabel('alfa in degrees') 
ylabel('C_d Drag coefficient') 
title('Drag coefficient vs Anlge of Attack NACA0015')
grid on 

figure
plot(a2, Cd2)
xlabel('alfa in degrees') 
ylabel('L/D') 
title('Lift to Drag ratio vs Anlge of Attack NACA0015')
grid on 

figure
plot(a2, Cdp2)
hold on 
plot(a2, Cdf2,'--')
xlabel('alfa in degrees') 
ylabel('Drag coefficients') 
title('Drag coefficients vs Anlge of Attack NACA0015')
legend('Pressure drag','Friction drag')
grid on 

%% For naca0015

a3 = n0018(:,1); 
Cl3 = n0018(:,2);
Cd3 = n0018(:,3);
Cdp3 = n0018(:,4);
Cdf3 = Cd3 - Cdp3; 
ld3 = Cl3./Cd3; 
% plotting 
figure
plot(a3, Cl3)
xlabel('alfa in degrees') 
ylabel('C_l Lift coefficient') 
title('Lift coefficient vs Anlge of Attack NACA0018')
grid on 

figure
plot(a3, Cd3)
xlabel('alfa in degrees') 
ylabel('C_d Drag coefficient') 
title('Drag coefficient vs Anlge of Attack NACA0018')
grid on 

figure
plot(a3, Cd3)
xlabel('alfa in degrees') 
ylabel('L/D') 
title('Lift to Drag ratio vs Anlge of Attack NACA0018')
grid on 

figure
plot(a3, Cdp3)
hold on 
plot(a3, Cdf3,'--')
xlabel('alfa in degrees') 
ylabel('Drag coefficients') 
title('Drag coefficients vs Anlge of Attack NACA0018')
legend('Pressure drag','Friction drag')
grid on 