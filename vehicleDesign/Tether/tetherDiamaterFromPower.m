
clc
clear
clear('all')

%Code computes the porperties of a Center-Strength-Member tether

%Structural Member Properties
Bool_structure = 1;
D_structureMin = .004; %avg .0075 m
D_structureMax = .006;
rho_structure = 975;
E_structure = 100*10^9;

%Conductor Wire Properties
Bool_wire = 1;
numWires = 9;
D_wireMin = .001; %avg.0018
D_wireMax = .0015;
rho_wire = 8960;
E_wire = 128*10^9;
rho_electrical = 1.68*10^-8;

%Insulation Properties
Bool_insulation = 0;
rho_insulation = 1000;
E_insulation = 0;
thick_insulation = .000325;

%Fiber Optic Properties
Bool_fiberOptic = 0;
D_fiberOptic = .0005;
rho_fiberOptic = 1500;
E_fiberOptic = 0;
numFiberOptic = 3;

%Fiber Optic Sheath Properties
Bool_fiberOpticSheath = 0;
thick_fiberOpticSheath = .0003;
rho_fiberOpticSheath = 8050;
E_fiberOpticSheath = 0;

%External Sheath Properties
Bool_extSheath = 1;
thick_extSheath = .001;
rho_extSheath = 1000;
E_extSheath = 10000;

%Bedding Properties
Bool_bedding = 0;
rho_bedding = 1000;
E_bedding = 0;

%Electrical total Properties
current = 10;
tension = 30000; %Tension
power = 1000;  %Power

%enviormental constants
rho_water = 1000;
rho_kite = rho_water;
l = 400;
g = 9.81;
V_kite = 1.02;
M_kite = rho_kite*V_kite;

%Graphing number of lines
N = 5;

%Determining Propertie grids
D_wire = linspace(D_wireMin,D_wireMax,N);       %ii
D_structure = linspace(D_structureMin,D_structureMax,N); %jj
for ii = 1:length(D_wire)
    for jj = 1:length(D_structure)
        
        %Geometric Properties
        D_total(ii,jj) = D_structure(jj) + 2*D_wire(ii) + 4*thick_insulation + 2*thick_extSheath;
        A_total(ii,jj) = (pi/4)*(D_total(ii,jj)^2);
        A_structure(ii,jj) = (pi/4)*(D_structure(jj)^2);
        A_wire(ii,jj) = numWires*(pi/4)*D_wire(ii)^2;
        A_insulation(ii,jj) = numWires*(pi/4)*((D_wire(ii)+2*thick_insulation)^2-D_wire(ii)^2);
        A_fiberOptic(ii,jj) = (pi/4)*(D_fiberOptic^2);
        A_fiberOpticSheath(ii,jj) = numFiberOptic*(pi/4)*((D_fiberOptic+2*thick_fiberOpticSheath)^2-D_fiberOptic^2);
        A_extSheath(ii,jj) = (pi/4)*(D_total(ii,jj)^2-(D_structure(jj) + D_wire(ii) + 2*thick_insulation)^2);
        A_bedding(ii,jj) = A_total(ii,jj)-(A_structure(ii,jj)+A_wire(ii,jj)+A_insulation(ii,jj)+A_fiberOptic(ii,jj)+A_fiberOpticSheath(ii,jj)+A_extSheath(ii,jj));
        V_sturcture(ii,jj) = A_structure(ii,jj)*l;
        V_wire(ii,jj) = A_wire(ii,jj)*l;
        V_insulation(ii,jj) = A_insulation(ii,jj)*l;
        V_fiberOptic(ii,jj) = A_fiberOptic(ii,jj)*l;
        V_fiberOpticSheath(ii,jj) = A_fiberOpticSheath(ii,jj)*l;
        V_extSheath(ii,jj) = A_extSheath(ii,jj)*l;
        V_bedding(ii,jj) = A_bedding(ii,jj)*l;
        V_total(ii,jj) = A_total(ii,jj)*l;
        
        %Electrical Properties
        %D_min = sqrt(((current^2*rho_electrical*l)/(power))*(4/pi));
        V_in = power/current;
        wire_resistance(ii,jj) = rho_electrical*l/A_wire(ii,jj);
        %V_drop(ii,jj) = current*wire_resistance(ii,jj);
        V_drop(ii,jj) = current*wire_resistance(ii,jj);
        PowerLoss(ii,jj) = wire_resistance(ii,jj)*current^2;
        V_drop_percent(ii,jj) = (V_drop(ii,jj)/V_in)*100;
        V_out = V_in-V_drop;
        
        %Mechanical Properties
        k_structure(ii,jj) = Bool_structure*(E_structure*A_structure(ii,jj))/l;
        k_wire(ii,jj) = Bool_wire*(E_wire*A_wire(ii,jj))/l;
        k_insulation(ii,jj) = Bool_insulation*(E_insulation*A_insulation(ii,jj))/l;
        k_fiberOptic(ii,jj) = Bool_fiberOptic*(E_fiberOptic*A_fiberOptic(ii,jj))/l;
        k_fiberOpticSheath(ii,jj) = Bool_fiberOpticSheath*(E_fiberOpticSheath*A_fiberOpticSheath(ii,jj))/l;
        k_extSheath(ii,jj) = Bool_extSheath*(E_extSheath*A_extSheath(ii,jj))/l;
        k_bedding(ii,jj) = Bool_bedding*(E_bedding*A_bedding(ii,jj))/l;
        k_total(ii,jj) = k_structure(ii,jj)+k_wire(ii,jj)+k_insulation(ii,jj)+k_fiberOptic(ii,jj)+k_fiberOpticSheath(ii,jj)+k_extSheath(ii,jj)+k_bedding(ii,jj);
        Strain_total(ii,jj) = tension/k_total(ii,jj);
        strain_Percent(ii,jj) = (Strain_total(ii,jj)/l)*100;
        
        %Mass Properties
        M_structure(ii,jj) = V_sturcture(ii,jj)*rho_structure;
        M_wire(ii,jj) = V_wire(ii,jj)*rho_wire;
        M_insulation(ii,jj) = V_insulation(ii,jj)*rho_insulation;
        M_fiberOptic(ii,jj) = V_fiberOptic(ii,jj)*rho_fiberOptic;
        M_fiberOpticSheath(ii,jj) = V_fiberOpticSheath(ii,jj)*rho_fiberOpticSheath;
        M_extSheath(ii,jj) = V_extSheath(ii,jj)*rho_extSheath;
        M_bedding(ii,jj) = V_bedding(ii,jj)*rho_bedding;
        M_total(ii,jj) = M_structure(ii,jj)+M_wire(ii,jj)+M_insulation(ii,jj)+M_fiberOptic(ii,jj)+M_fiberOpticSheath(ii,jj)+M_extSheath(ii,jj)+M_bedding(ii,jj); 
        M_totalDisplaced(ii,jj) = V_total(ii,jj)*rho_water;

        %Support Force
        F_support = M_total(ii,jj)*g - M_totalDisplaced(ii,jj)*g;

        %Total Cable Density - 
        rho_total(ii,jj) = M_total(ii,jj)/V_total(ii,jj);      
        T_linearDensity(ii,jj) = M_total(ii,jj)/l;
      
    end
end
%%
% TotalDiameter = D_total(1,1)
% StrainPercent = strain_Percent
% KitePosBoy = (M_total(1,1)-M_totalDisplaced(1,1))/M_kite)*100


%%
TitleFontSize = 22;
LegendFontSize = 10;
AxisFontsSize = 12;

figure(1)
subplot(3,1,1)
hold on 
LegendString = cell(1,numel(D_wire));
for jj = 1:N %For all wire diameters (ii)
    plot(D_total(:,jj)*1000,PowerLoss(:,jj))%for each tether (jj :)
    LegendString{jj} = sprintf('Strength Memb Diameter = %2.2f mm',(D_structure(jj)*1000));
end
xlabel('Tether Diameter (mm)','Fontsize',AxisFontsSize)
ylabel('Power Loss (W)','Fontsize',AxisFontsSize)
%legend(LegendString,'Fontsize',LegendFontSize)
title(sprintf('Power Loss over %5.0f m Tether',l),'Fontsize',TitleFontSize)
hold off

subplot(3,1,2)
hold on 
LegendString = cell(1,numel(D_wire));
for jj = 1:N %For all strength members (jj)
    plot(D_total(:,jj)*1000,strain_Percent(:,jj))%for each tether (jj :)
    LegendString{jj} = sprintf('Strength Memb Diameter = %2.2f mm',(D_structure(jj)*1000));
end
xlabel('Tether Diameter (mm)','Fontsize',AxisFontsSize)
ylabel('Strain Percent %','Fontsize',AxisFontsSize)
legend(LegendString,'Fontsize',LegendFontSize)
title(sprintf('Steady State Strain at%5.0f kN Load',tension/1000),'Fontsize',TitleFontSize)
hold off

subplot(3,1,3)
hold on 
LegendString = cell(1,numel(D_wire));
for jj = 1:N %For all wires (ii)
    plot(D_total(:,jj)*1000,((M_total(:,jj)-M_totalDisplaced(:,jj))/M_kite)*100) %for each tether (jj :)
    LegendString{jj} = sprintf('Strength Memb Diameter = %2.2f mm',(D_structure(jj)*1000));
end
xlabel('Tether Diameter (mm)','Fontsize',AxisFontsSize)
ylabel('Kite Positive Boyancy Percent (%)','Fontsize',AxisFontsSize)
%legend(LegendString,'Fontsize',LegendFontSize)
title('Kite Positive Percent vs Tether Diameter for Different Wires','Fontsize',TitleFontSize)
hold off
%%
% figure(2)
% hold on 
% LegendString = cell(1,numel(D_wire));
% for jj = 1:N %For all wires (ii)
%     plot(D_total(:,jj)*1000,(T_linearDensity(:,jj))) %for each tether (jj :)
%     LegendString{jj} = sprintf('Strength Memb Diameter = %2.2f mm',(D_structure(jj)*1000));
% end
% xlabel('Tether Diameter (mm)','Fontsize',AxisFontsSize)
% ylabel('Cable linear density (kg/m)','Fontsize',AxisFontsSize)
% %legend(LegendString,'Fontsize',LegendFontSize)
% title('Cable Linear Density','Fontsize',TitleFontSize)
% hold off

%%
figure(3)
Centers  = [0,0;...             %Total
            0,0;...             %Total internl before sheath      
            0,0;...             %Strength Member
            EqualSpace(D_structure(1)/2+thick_insulation+D_wire(1)/2,0,0,numWires,0);... %Wires
            EqualSpace(D_structure(1)/2+thick_insulation+D_wire(1)/2,0,0,numWires,0);... %Wire Sheath
            EqualSpace(D_structure(1)/2+thick_fiberOpticSheath+D_fiberOptic(1)/2,0,0,numFiberOptic+1,((2*pi)/(numWires-1))/2,1);... %Fiber Optic
            EqualSpace(D_structure(1)/2+thick_fiberOpticSheath+D_fiberOptic(1)/2,0,0,numFiberOptic+1,((2*pi)/(numWires-1))/2,1)];   %Fiber Optic Shift
            
Radiuses = [D_total(1)/2                                                  ;...
            D_total(1)/2 - thick_extSheath                                ;...
            D_structure(1)/2                                              ;...
            D_wire(1)/2*ones(numWires,1)                                  ;...
            (D_wire(1)/2 + thick_insulation)*ones(numWires,1)             ;...
            D_fiberOptic/2*ones(1,1)                               ;...
            (D_fiberOptic(1)/2 + thick_fiberOpticSheath)*ones(1,1)];


%colors = {'k','k','b',};

hold on
for ii = 1:length(Radiuses)
    viscircles(Centers(ii,:),Radiuses(ii),'Color','k');
end
ylim([-max(D_total,[],'all')/2, max(D_total,[],'all')/2])
xlim([-max(D_total,[],'all')/2, max(D_total,[],'all')/2])
hold off


%%
function [Centers] = EqualSpace(r,xc,yc,np,Shift,numShow)
% xc and yc are the coordinates of the center of the circle
% r is the radius of the circle
% np is the number of dots printed along the circle
if nargin < 6
    numShow = np;
elseif nargin < 4
    np = 100;
elseif nargin < 3
    yc = 0;
elseif nargin < 2
    xc = 0;
end
ang = linspace(0+Shift,2*pi+Shift,np);
x = xc + r * cos(ang);
y = yc + r * sin(ang);
Centers = [x(1:numShow)',y(1:numShow)'];
end