clc
clear all
close all

load('poolTether')
load('poolScaleKiteAbney')
vhcl.plotCoeffPolars
vhcl.plotVehiclePolars(thr,3)

load('poolScaleKiteAbneyRefined')
vhcl.plotCoeffPolars
vhcl.plotVehiclePolars(thr,3,'color',[1 0 0],'marker','square')
% legend('Simulation','Water Tunnel Refinement')

V = 1.5;                                                    %   m/s - Apparent flow speed magnitude
Lthr = 3;                                                   %   m - tether length
Aref = vhcl.fluidRefArea.Value;                             %   m^2 - kite reference area
AoA = 0:2:10;                                               %   deg - investigated angles of attack
Athr = Lthr*thr.tether1.diameter.Value/4;                   %   m^2 - projected tether area according to Lloyd
CDthr = thr.tether1.dragCoeff.Value(1)*Athr/Aref;           %   tether coefficient of drag with respect to the kite
Lcfd = [4.687 9.532 14.215 18.579 22.931 26.813]*4.448;     %   N - lift force from CFD results
Dcfd = [1.631 1.716 1.89 2.158 2.553 3.024]*4.448;          %   N - drag force from CFD results
CLcfd = 2*Lcfd./(Aref*1000*V^2);                            %   CFD lift coefficient
CDcfd = 2*Dcfd./(Aref*1000*V^2);                            %   CFD drag coefficient
CDcfd = CDcfd+CDthr;                                        %   CFD drag coefficient with tether drag included

%%  Plot Raw Vehicle Polars 
% vhcl.plotVehiclePolars(thr,Lthr,'color',[0 0 1]);
subplot(2,2,1); plot(AoA,CLcfd,'k-o'); xlim([-5 15]); legend('Sim','Water Tunnel','CFD','location','northwest')
subplot(2,2,2); plot(AoA,CDcfd,'k-o'); xlim([-5 15]);
subplot(2,2,3); plot(AoA,CLcfd.^3./CDcfd.^2,'k-o'); xlim([-5 15]);
subplot(2,2,4); plot(AoA,CLcfd./CDcfd,'k-o'); xlim([-5 15]);