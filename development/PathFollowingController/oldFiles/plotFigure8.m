

%% path and shape generation
aB = 1; %a booth
bB = 2; %b booth 
s = linspace(0,2*pi, 150);%path paramitrization 

lambda_g = (aB.*sin(s))./(1 + ((aB/bB)^2).*(cos(s).^2)); %path longitude
phi_g  = (((aB/bB)^2).*sin(s).*cos(s))./(1 + ((aB/bB)^2).*(cos(s).^2)); %path latitude

path = [ cos(lambda_g).*cos(phi_g);
         sin(lambda_g).*cos(phi_g);
         sin(phi_g);]; % figure 8 parameter
     
     


% plot figure 8 
scatter3(path(1,:),path(2,:), path(3,:))
hold on 

%plot sphere
theta = linspace(0, 2*pi);
phi = linspace(-pi/2 , pi/2); 
[theta, phi] = meshgrid(theta, phi); 
rho = 1; 

[x,y,z] = sph2cart(theta, phi, rho);
surf(x,y,z)
%% tangent to path 

%differential step in S
deltaS = diff(s);

%pathDeriv
pathDeriv = [diff(path(1,:))./deltaS;
    diff(path(2,:))./deltaS;
    diff(path(3,:))./deltaS;];

%-------------------------
for i = 1:149
k=i; % point number 98
tang =(s-s(k)).*pathDeriv(:,k)+path(:,k);

%scatter3(path(1,:),path(2,:), path(3,:))

%scatter3(path(1,k),path(2,k), path(3,k))
scatter3(tang(1,:), tang(2,:), tang(3,:))
end
%hold off

phi1 = linspace(0,2*pi,150);
lambda1 = linspace(0,2*pi,150);

%basis vector for tangential plane (REAL DEAL)
V = [-sin(phi1).*cos(lambda1), -sin(lambda1);
     -sin(phi1).*sin(lambda1), cos(lambda1);
     cos(phi1), zeros(1,150);];
% your location in wind Frame
pgw = [1,1,1];

%your velocity vector in the wind frame
vkW = [1,1,1];





