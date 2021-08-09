%%  Post-process CFD Results 
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
%%  Plot Vehicle Polars
vhcl.plotVehiclePolars(thr,Lthr,'color',[0 0 1]);
subplot(2,2,1); plot(AoA,CLcfd,'r-o'); xlim([0 10]); %legend('Model','CFD','location','northwest')
subplot(2,2,2); plot(AoA,CDcfd,'r-o'); xlim([0 10]);
subplot(2,2,3); plot(AoA,CLcfd.^3./CDcfd.^2,'r-o'); xlim([0 10]);
subplot(2,2,4); plot(AoA,CLcfd./CDcfd,'r-o'); xlim([0 10]);
%%  Adjust sim parameters to match CFD results 
loadComponent('poolScaleKiteAbney');
endFactor = 12; sideFactor = 01;
alpha = [0 10];  
vhcl.fuse.endDragCoeff.setValue(vhcl.fuse.endDragCoeff.Value*endFactor,'')
vhcl.fuse.sideDragCoeff.setValue(vhcl.fuse.sideDragCoeff.Value*sideFactor,'')
Afuse = pi/4*vhcl.fuse.diameter.Value^2.*cosd(alpha)+...
    (pi/4*vhcl.fuse.diameter.Value^2+vhcl.fuse.diameter.Value*vhcl.fuse.length.Value).*(1-cosd(alpha));
CDfuse = (vhcl.fuse.endDragCoeff.Value.*cosd(alpha)+...
    vhcl.fuse.sideDragCoeff.Value.*(1-cosd(alpha))).*Afuse/Aref;
CLwing = interp1(vhcl.portWing.alpha.Value,vhcl.portWing.CL.Value,alpha)+interp1(vhcl.stbdWing.alpha.Value,vhcl.stbdWing.CL.Value,alpha);
CLstab = interp1(vhcl.hStab.alpha.Value,vhcl.hStab.CL.Value,alpha);
CDwing = interp1(vhcl.portWing.alpha.Value,vhcl.portWing.CD.Value,alpha)+interp1(vhcl.stbdWing.alpha.Value,vhcl.stbdWing.CD.Value,alpha);
CDstab = interp1(vhcl.hStab.alpha.Value,vhcl.hStab.CD.Value,alpha);
CDvert = interp1(vhcl.vStab.alpha.Value,vhcl.vStab.CD.Value,alpha);
CLtot = CLwing+CLstab;
CDtot = CDwing+CDstab+CDvert+CDfuse+CDthr;
fprintf('AoA = 0:\tKite CFD CD: %.3f;\tKite Sim CD: %.3f\n',CDcfd(1),CDtot(1));
fprintf('AoA = 10:\tKite CFD CD: %.3f;\tKite Sim CD: %.3f\n',CDcfd(end),CDtot(2));
fprintf('Required Fuse Nose CD: %.3f;\nRequired Fuse Side CD: %.3f\n\n',vhcl.fuse.endDragCoeff.Value,vhcl.fuse.sideDragCoeff.Value);
%%  Effect of tether length 
Lthr = 2:.01:6;
AoA = 10;
for i = 1:numel(Lthr)
    Athr = Lthr(i)*thr.tether1.diameter.Value/4;
    CLtot(i) = CLcfd(end);
    CDthr = thr.tether1.dragCoeff.Value(1)*Athr/Aref;
    CDtot(i) = CDcfd(end)+CDthr;
%     [CLk(i),CDk(i)] = vhcl.plotVehiclePolars(thr,Lthr(i),'AoA',0);
end

