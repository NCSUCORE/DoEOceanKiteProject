%%  Turb Diameter Study
for i = 1:numel(E)
    Idx = find(AoA(:,i) > 13.5);
    Pavg(Idx,i) = NaN;   AoA(Idx,i) = NaN;   CL(Idx,i) = NaN;  CD(Idx,i) = NaN;
    Fdrag(Idx,i) = NaN;  Ffuse(Idx,i) = NaN; Fturb(Idx,i) = NaN;
end
[Dm,Em] = find(Pavg==max(max(Pavg)));
%%
for i = 1:numel(D)
    [Pmax(i),Dmax(i)] = max(Pavg(i,:));
end
%%
figure; subplot(2,2,1);
a = contourf(E,D,Pavg,20,'edgecolor','none');  xlabel('Elevator [deg]');  ylabel('Diameter [m]');  
title('Avg. Power [kW]');  colorbar;  hold on; plot(E(Dmax),D,'r-'); 
plot(E(Em),D(Dm),'kx','markersize',10,'linewidth',2);
subplot(2,2,2);
contourf(E,D,CL.^3./CD.^2,20,'edgecolor','none');  xlabel('Elevator [deg]');  ylabel('Diameter [m]');  
title('Avg. $\mathrm{CL^3/CD^2}$');  colorbar;  hold on; plot(E(Dmax),D,'r-')
plot(E(Em),D(Dm),'kx','markersize',10,'linewidth',2);
subplot(2,2,3);
contourf(E,D,AoA,20,'edgecolor','none');  xlabel('Elevator [deg]');  ylabel('Diameter [m]');  
title('Avg. AoA [deg]');  colorbar;  hold on; plot(E(Dmax),D,'r-')
plot(E(Em),D(Dm),'kx','markersize',10,'linewidth',2);
subplot(2,2,4);
contourf(E,D,Fturb./(Fdrag+Ffuse),20,'edgecolor','none');  xlabel('Elevator [deg]');  ylabel('Diameter [m]');  
title('Avg. $\mathrm{D_t/D_k}$');  colorbar;  hold on; plot(E(Dmax),D,'r-')
plot(E(Em),D(Dm),'kx','markersize',10,'linewidth',2);