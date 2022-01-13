% clc
% clear all
close all

load('poolTether')


%% Plot Wing Data
fpath = 'C:\Users\adabney\Documents\'
fname = 'wingChar'
load('poolScaleKiteAbney')
% Original Characterization
figure(9)
t = tiledlayout(2,1)
nexttile; hold on; grid on;
plot(vhcl.stbdWing.alpha.Value,vhcl.stbdWing.CL.Value*2,'b')
ylabel '$C_L$'
% xlabel '$\alpha$ [deg]'
set(gca,'FontSize',12)
nexttile; hold on; grid on;
plot(vhcl.stbdWing.alpha.Value,vhcl.stbdWing.CD.Value*2,'b')
ylabel '$C_D$'
xlabel '$\alpha$ [deg]'
set(gca,'FontSize',12)

% Water Tunnel Data
load('poolScaleKiteAbneyRefined')
nexttile(1)
plot(vhcl.stbdWing.alpha.Value,vhcl.stbdWing.CL.Value*2,'-sr')
xlim([-6 16])
nexttile(2)
plot(vhcl.stbdWing.alpha.Value,vhcl.stbdWing.CD.Value*2,'-sr')
xlim([-6 16])
legend('Simulation','Water Tunnel Refinement','Location','northwest')
t.Padding = 'compact'
t.TileSpacing = 'compact'
saveas(gcf,[fpath fname],'emf')
saveas(gcf,[fpath fname],'fig')
%% Plot Fuselage Data

load('poolScaleKiteAbney')
% Original Fuselage Characterization
alpha = -6:2:16
Aref = vhcl.fluidRefArea.Value
Afuse = pi/4*vhcl.fuse.diameter.Value^2.*cosd(alpha)+...
    (pi/4*vhcl.fuse.diameter.Value^2+vhcl.fuse.diameter.Value*vhcl.fuse.length.Value).*(1-cosd(alpha));
CDfuse = (vhcl.fuse.endDragCoeff.Value.*cosd(alpha)+...
    vhcl.fuse.sideDragCoeff.Value.*(1-cosd(alpha))).*Afuse/Aref

figure(10)
plot(alpha,CDfuse,'b')
hold on; grid on;

load('poolScaleKiteAbneyRefined')

plot(vhcl.fuse.alpha.Value,vhcl.fuse.CD.Value,'-sr')
ylabel 'Fuselage $C_D$'
xlabel '$\alpha [deg]$'
fname = 'fuseChar'
vhcl.fuse.CL.setValue(pF(2,:)','')
vhcl.fuse.CD.setValue(pF(3,:)','')

plot(vhcl.fuse.alpha.Value,vhcl.fuse.CD.Value,'-sk')
legend('Simulation','Water Tunnel Refinement - Connectors','Water Tunnel Refinement - No Connectors','Location','northwest')
saveas(gcf,[fpath fname],'emf')
saveas(gcf,[fpath fname],'fig')
%% Plot Aggregate Characteristics

load('poolScaleKiteAbney')
vhcl.plotVehiclePolars(thr,3)
load('poolScaleKiteAbneyRefined')
vhcl.plotVehiclePolars(thr,3,'color',[1 0 0],'marker','square')
legend('Simulation','Water Tunnel Refinement','Location','south')
set(gcf,'Position',[100 100 800 800])


for i = 1:4
    subplot(2,2,i)
    xlim([-6 16])
end
fname = 'aggregate'
saveas(gcf,[fpath fname],'emf')
saveas(gcf,[fpath fname],'fig')
% V = 1.5;                                                    %   m/s - Apparent flow speed magnitude
% Lthr = 3;                                                   %   m - tether length
% Aref = vhcl.fluidRefArea.Value;                             %   m^2 - kite reference area
% AoA = 0:2:10;                                               %   deg - investigated angles of attack
% Athr = Lthr*thr.tether1.diameter.Value/4;                   %   m^2 - projected tether area according to Lloyd
% CDthr = thr.tether1.dragCoeff.Value(1)*Athr/Aref;           %   tether coefficient of drag with respect to the kite
% Lcfd = [4.687 9.532 14.215 18.579 22.931 26.813]*4.448;     %   N - lift force from CFD results
% Dcfd = [1.631 1.716 1.89 2.158 2.553 3.024]*4.448;          %   N - drag force from CFD results
% CLcfd = 2*Lcfd./(Aref*1000*V^2);                            %   CFD lift coefficient
% CDcfd = 2*Dcfd./(Aref*1000*V^2);                            %   CFD drag coefficient
% CDcfd = CDcfd+CDthr;                                        %   CFD drag coefficient with tether drag included

%%  Plot Raw Vehicle Polars 
subplot(2,2,1); 
xlim([-5 15]);set(gca,'FontSize',12);xlabel '$\alpha$ [deg]'

subplot(2,2,2); 
% plot(AoA,CDcfd,'k-o'); 
xlim([-5 15]);set(gca,'FontSize',12);xlabel '$\alpha$ [deg]'

subplot(2,2,3); 
% plot(AoA,CLcfd.^3./CDcfd.^2,'k-o'); 
xlim([-5 15]);set(gca,'FontSize',12);xlabel '$\alpha$ [deg]'

subplot(2,2,4); 
% plot(AoA,CLcfd./CDcfd,'k-o'); 
xlim([-5 15]);set(gca,'FontSize',12);xlabel '$\alpha$ [deg]'