
listInputVarsMT
%Code computes the porperties of a Center-Strength-Member tether
helix_Angle_wire = linspace(10,90,100);



for ii = 1:100
%% Structural Member Properties
rho_structure  = varMTinputs.Structure.rho;
E_structure    = varMTinputs.Structure.youngsMod;
Bool_structure = varMTinputs.Structure.boolSpring;
D_structure    = varMTinputs.Structure.Diameter.default;
fail_structureStrain =  varMTinputs.Structure.strainFailurePercent;

%% Conductor Wire Properties
rho_wire = varMTinputs.Wire.rho;
E_wire = varMTinputs.Wire.youngsMod;
Bool_wire = varMTinputs.Wire.boolSpring;
D_wire = varMTinputs.Wire.Diameter.default;
fail_wireStrain =  varMTinputs.Wire.strainFailurePercent;
numWires = varMTinputs.Wire.number;
rho_electrical = varMTinputs.Wire.rho_electrical;
poisson_ratio_wire = varMTinputs.Wire.Poisson;

%% Wire Insulation Properties
rho_insulation = varMTinputs.wireInsulation.rho;
E_insulation = varMTinputs.wireInsulation.youngsMod;
fail_insulationStrain =  varMTinputs.wireInsulation.strainFailurePercent;
Bool_insulation = varMTinputs.wireInsulation.boolSpring;
thick_insulation = varMTinputs.wireInsulation.thickness.default;

%% Fiber Optic Properties
rho_fiberOptic = varMTinputs.fiberOptic.rho;
E_fiberOptic = varMTinputs.fiberOptic.youngsMod;
Bool_fiberOptic = varMTinputs.fiberOptic.boolSpring;
D_fiberOptic = varMTinputs.fiberOptic.Diameter.default;
fail_fiberOpticStrain =  varMTinputs.fiberOptic.strainFailurePercent;
numFiberOptic = varMTinputs.fiberOptic.number;
helix_Angle_fiberOptic = varMTinputs.fiberOptic.helixAngle;

%% Fiber Optic Sheath Properties
rho_fiberOpticSheath = varMTinputs.fiberOpticSheath.rho;
E_fiberOpticSheath = varMTinputs.fiberOpticSheath.youngsMod;
Bool_fiberOpticSheath = varMTinputs.fiberOpticSheath.boolSpring;
thick_fiberOpticSheath = varMTinputs.fiberOpticSheath.thickness.default;
fail_fiberOpticSheathStrain =  varMTinputs.fiberOpticSheath.strainFailurePercent;

%% External Sheath Properties
rho_extSheath = varMTinputs.extSheath.rho;
E_extSheath = varMTinputs.extSheath.youngsMod;
Bool_extSheath = varMTinputs.extSheath.boolSpring;
thick_extSheath = varMTinputs.extSheath.thickness.default;
fail_extSheathStrain =  varMTinputs.extSheath.strainFailurePercent;

%% Bedding Properties
rho_bedding = varMTinputs.bedding.rho;
E_bedding = varMTinputs.bedding.youngsMod;
Bool_bedding = varMTinputs.bedding.boolSpring;
fail_beddingStrain =  varMTinputs.bedding.strainFailurePercent;

%% Generator Properties (P=VI)->(I=P/V)
power = varMTinputs.generator.power;
voltage = varMTinputs.generator.voltage;
current = power/voltage;

%% Tether Properties
tension = varMTinputs.tether.tension;
l = varMTinputs.tether.length;
l_wire = l*csc(helix_Angle_wire(ii)*(pi/180));
l_fiberOptic = l*csc(helix_Angle_fiberOptic*(pi/180));

%% Enviorment Properties
rho_water = varMTinputs.extProp.fluidRho;
g = varMTinputs.extProp.gravAcc;

%% Kite Properties
rho_kite = varMTinputs.kite.rho;
V_kite = varMTinputs.kite.volume;
M_kite = rho_kite*V_kite;

%% Geometric Properties
D_total = D_structure + 2*D_wire + 4*thick_insulation + 2*thick_extSheath;
A_total = (pi/4)*(D_total^2);
A_structure = (pi/4)*(D_structure^2);
A_wire = numWires*(pi/4)*D_wire^2;
A_insulation = numWires*(pi/4)*((D_wire+2*thick_insulation)^2-D_wire^2);
A_fiberOptic = (pi/4)*(D_fiberOptic^2);
A_fiberOpticSheath = numFiberOptic*(pi/4)*((D_fiberOptic+2*thick_fiberOpticSheath)^2-D_fiberOptic^2);
A_extSheath = (pi/4)*(D_total^2-(D_structure + D_wire + 2*thick_insulation)^2);
A_bedding = A_total-(A_structure+A_wire+A_insulation+A_fiberOptic+A_fiberOpticSheath+A_extSheath);
V_sturcture = A_structure*l;
V_wire = A_wire*l;
V_insulation = A_insulation*l;
V_fiberOptic = A_fiberOptic*l;
V_fiberOpticSheath = A_fiberOpticSheath*l;
V_extSheath = A_extSheath*l;
V_bedding = A_bedding*l;
V_total = A_total*l;

%% Mechanical Properties
k_structure_Eff = Bool_structure*(E_structure*A_structure)/l;

k_wire_Eff = Bool_wire*((E_wire*A_wire*sind(helix_Angle_wire(ii)))/l_wire);
k_insulation_Eff = Bool_insulation*(E_insulation*A_insulation*sind(helix_Angle_wire(ii)))/l_wire;

k_fiberOptic_Eff = Bool_fiberOptic*(E_fiberOptic*A_fiberOptic*sind(helix_Angle_wire(ii)))/l_fiberOptic;
k_fiberOpticSheath_Eff = Bool_fiberOpticSheath*(E_fiberOpticSheath*A_fiberOpticSheath*sind(helix_Angle_wire(ii)))/l_fiberOptic;

k_extSheath_Eff = Bool_extSheath*(E_extSheath*A_extSheath)/l;
k_bedding_Eff = Bool_bedding*(E_bedding*A_bedding)/l;
k_total = k_structure_Eff+k_wire_Eff+k_insulation_Eff+k_fiberOptic_Eff+k_fiberOpticSheath_Eff+k_extSheath_Eff+k_bedding_Eff;

Strain_total = tension/k_total;
strainTotalPercent = (Strain_total/l)*100;

%% Componet Strains
%poisson_ratio_wire = 0.36;
poisson_ratio__fiberOptic = 0;

structureStrain = Strain_total;
structureStrainPercent = (structureStrain/l)*100;
Structure_StrainDiff = structureStrainPercent - fail_structureStrain;

wireStrain = Strain_total*sind(helix_Angle_wire(ii))/(1+poisson_ratio_wire*cosd(helix_Angle_wire(ii))^2);
wireStrainPercent(ii) = (wireStrain/l_wire)*100;
Wire_StrainDiff = wireStrainPercent - fail_wireStrain;

insulationStrain = Strain_total*sind(helix_Angle_wire(ii))/(1+poisson_ratio_wire*cosd(helix_Angle_wire(ii))^2);
insulationStrainPercent = (insulationStrain/l_wire)*100;
WireInsulation_StrainDiff = insulationStrainPercent - fail_insulationStrain;

fiberOpticStrain = Strain_total*sind(helix_Angle_fiberOptic)/(1+poisson_ratio__fiberOptic*cosd(helix_Angle_fiberOptic)^2);
fiberOpticStrainPercent = (fiberOpticStrain/l_fiberOptic)*100;
FiberOptic_StrainDiff = fiberOpticStrainPercent - fail_fiberOpticStrain;

fiberOpticSheathStrain = Strain_total*sind(helix_Angle_fiberOptic)/(1+poisson_ratio__fiberOptic*cosd(helix_Angle_fiberOptic)^2);
fiberOpticSheathStrainPercent = (fiberOpticSheathStrain/l_fiberOptic)*100;
FiberOpticSheath_StrainDiff = fiberOpticSheathStrainPercent - fail_fiberOpticSheathStrain;

extSheathStrain = Strain_total;
extSheathStrainPercent = (extSheathStrain/l)*100;
ExtSheath_StrainDiff = extSheathStrainPercent - fail_extSheathStrain;

beddingStrain = Strain_total;
beddingStrainPercent = (beddingStrain/l)*100;
Bedding_StrainDiff = beddingStrainPercent - fail_beddingStrain;

% Strains = {'Structure'         ,Structure_StrainDiff       ;...
%            'Wire'              ,Wire_StrainDiff            ;...
%            'Wire Insulation'   ,WireInsulation_StrainDiff  ;...
%            'Fiber Optic'       ,FiberOptic_StrainDiff      ;...
%            'Fiber Optic Sheath',FiberOpticSheath_StrainDiff;...
%            'External Sheath'   ,ExtSheath_StrainDiff       ;...
%            'Bedding'           ,Bedding_StrainDiff         };
%        
% mostStrainVal = max([Strains{:,2}]);
% idx = [Strains{:,2}] == mostStrainVal;
% if mostStrainVal <= 0
%     mostStrains = "";
% else
%     mostStrains = {Strains{idx,1}};
% end

%% Electrical Properties
%D_min = sqrt(((current^2*rho_electrical*l)/(power))*(4/pi));
V_in = power/current;
wire_resistance = rho_electrical*l_wire/A_wire;
V_drop = current*wire_resistance;
PowerLoss = wire_resistance*current^2;
V_drop_percent = (V_drop/V_in)*100;
V_out = V_in-V_drop;


%% Mass Properties
M_structure = V_sturcture*rho_structure;
M_wire = V_wire*rho_wire;
M_insulation = V_insulation*rho_insulation;
M_fiberOptic = V_fiberOptic*rho_fiberOptic;
M_fiberOpticSheath = V_fiberOpticSheath*rho_fiberOpticSheath;
M_extSheath = V_extSheath*rho_extSheath;
M_bedding = V_bedding*rho_bedding;
M_total = M_structure+M_wire+M_insulation+M_fiberOptic+M_fiberOpticSheath+M_extSheath+M_bedding;
M_totalDisplaced = V_total*rho_water;

%% Total Cable Density -
rho_total = M_total/V_total;
T_linearDensity = M_total/l;

%% Outputs of App
support_Force = M_total*g - M_totalDisplaced*g;
strain_Percent = strainTotalPercent;
power_Loss_Percent = (PowerLoss/power)*100;
outer_Diameter = D_total;
failure_Strain_Percent = 0.0;
maxStrain_Percent_Over_Failure = mostStrainVal;
maxStrain_Percent_Over_Failure_Componets = mostStrains;
end

plot(helix_Angle_wire,wireStrainPercent)
title('Helix Angle vs Wire Strain Percent')
ylabel('Wire Strain (%)')
xlabel('Helix Angle (deg)')
% 
% 
% %% Circle Locations
% Centers  = [0,0;...             %Total
%             0,0;...             %Total internl before sheath
%             0,0;...             %Strength Member
%             EqualSpace(D_structure/2+thick_insulation+D_wire/2,0,0,numWires,0);... %Wires
%             EqualSpace(D_structure/2+thick_insulation+D_wire/2,0,0,numWires,0);... %Wire Sheath
%             EqualSpace(D_structure/2+D_wire+2*thick_insulation,0,0,numFiberOptic,((2*pi)/(numWires-1))/2);... %Fiber Optic
%             EqualSpace(D_structure/2+D_wire+2*thick_insulation,0,0,numFiberOptic,((2*pi)/(numWires-1))/2)];   %Fiber Optic Shift
% 
% %% Circle Radius
% Radiuses = [D_total/2                                                       ;...
%             D_total/2 - thick_extSheath                                     ;...
%             D_structure/2                                                   ;...
%             D_wire/2*ones(numWires,1)                                       ;...
%             (D_wire/2 + thick_insulation)*ones(numWires,1)                  ;...
%             D_fiberOptic/2*ones(numFiberOptic,1)                                        ;...
%             (D_fiberOptic/2 + thick_fiberOpticSheath)*ones(numFiberOptic,1)];
% 
% %% Plots for circles
% for ii = 1:length(Radiuses)
%     appviscircles(Centers(ii,:),Radiuses(ii),'Color','k');
% end
% 
% %% Plot limits
% app.PlotAxes.DrawPlot.YLim = [-max(D_total,[],'all')/2, max(D_total,[],'all')/2];
% app.PlotAxes.DrawPlot.XLim = [-max(D_total,[],'all')/2, max(D_total,[],'all')/2];
% 
% 
% 
% %% Function for creating circles
%     function [Centers] = EqualSpace(r,xc,yc,np,Shift,numShow)
%         % xc and yc are the coordinates of the center of the circle
%         % r is the radius of the circle
%         % np is the number of dots printed along the circle
%         if nargin < 6
%             numShow = np;
%         elseif nargin < 4
%             np = 100;
%         elseif nargin < 3
%             yc = 0;
%         elseif nargin < 2
%             xc = 0;
%         end
%         ang = linspace(0+Shift,2*pi+Shift,np+1);
%         x = xc + r * cos(ang);
%         y = yc + r * sin(ang);
%         Centers = [x(1:numShow)',y(1:numShow)'];
%     end
% 
% 
