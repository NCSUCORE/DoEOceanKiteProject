%%  Vehicle Polars
loadComponent('poolScaleKiteAbney');
loadComponent('MantaTether');                               %   Manta Ray tether
V = 1.5;
Lthr = 3;
Aref = vhcl.fluidRefArea.Value;
AoA = 0:2:10;
Athr = 3*thr.tether1.diameter.Value/4;
CDthr = thr.tether1.dragCoeff.Value(1)*Athr/Aref;
Lcfd = [4.687 9.532 14.215 18.579 22.931 26.813]*4.448;
Dcfd = [1.631 1.716 1.89 2.158 2.553 3.024]*4.448;
CLcfd = 2*Lcfd./(Aref*1000*V^2);
CDcfd = 2*Dcfd./(Aref*1000*V^2);
CDcfd = CDcfd+CDthr;

vhcl.plotVehiclePolars(thr,Lthr,'fuseFactor',10,'color',[0 1 1]);
subplot(2,2,1); plot(AoA,CL,'r-o'); xlim([0 10]); %legend('Model','CFD','location','northwest')
subplot(2,2,2); plot(AoA,CD,'r-o'); xlim([0 10]);
subplot(2,2,3); plot(AoA,CL.^3./CD.^2,'r-o'); xlim([0 10]);
subplot(2,2,4); plot(AoA,CLcfd./CDcfd,'r-o'); xlim([0 10]);
%%
Lthr = 2:.01:6;
AoA = 10;
for i = 1:numel(Lthr)
    Athr = Lthr(i)*thr.tether1.diameter.Value/4;
    CLtot(i) = CLcfd(end);
    CDthr = thr.tether1.dragCoeff.Value(1)*Athr/Aref;
    CDtot(i) = CDcfd(end)+CDthr;
%     [CLk(i),CDk(i)] = vhcl.plotVehiclePolars(thr,Lthr(i),'AoA',0);
end
figure;hold on;grid on;
