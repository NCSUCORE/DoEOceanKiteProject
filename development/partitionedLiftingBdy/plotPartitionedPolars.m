function plotPartitionedPolars(lookupTableFileName)

load(lookupTableFileName,'aeroStruct','dsgnData');

fh = findobj( 'Type', 'Figure', 'Name', 'Partitioned Aero Coeffs');

if isempty(fh)
    fh = figure;
    fh.Position =[102 92 3*560 2*420];
    fh.Name ='Partitioned Aero Coeffs';
else
    figure(fh);
end

% left wing
ax1 = subplot(2,4,1);
plot(aeroStruct(1).alpha,aeroStruct(1).CL);
hCL_ax = gca;

xlabel('$\alpha$ [deg]')
ylabel('$C_{L}$')
title('Left Wing')
grid on
hold on

ax5 = subplot(2,4,5);
plot(aeroStruct(1).alpha,aeroStruct(1).CD);
xlabel('$\alpha$ [deg]')
ylabel('$C_{D}$')
grid on
hold on
hCD_ax = gca;

linkaxes([ax1,ax5],'x');

% right wing
ax2 = subplot(2,4,2);
plot(aeroStruct(2).alpha,aeroStruct(2).CL);

xlabel('$\alpha$ [deg]')
ylabel('$C_{L}$')
title('Right Wing')
grid on
hold on

ax6 = subplot(2,4,6);
plot(aeroStruct(2).alpha,aeroStruct(2).CD);
xlabel('$\alpha$ [deg]')
ylabel('$C_{D}$')
grid on
hold on

linkaxes([ax2,ax6],'x');

% HS
ax3 = subplot(2,4,3);
plot(aeroStruct(3).alpha,aeroStruct(3).CL);
xlabel('$\alpha$ [deg]')
ylabel('$C_{L}$')
title('H-stab')
grid on
hold on

ax7 = subplot(2,4,7);
plot(aeroStruct(3).alpha,aeroStruct(3).CD);
xlabel('$\alpha$ [deg]')
ylabel('$C_{D}$')
grid on
hold on

linkaxes([ax3,ax7],'x');

% VS
ax4 = subplot(2,4,4);
plot(aeroStruct(4).alpha,aeroStruct(4).CL);
xlabel('$\alpha$ [deg]')
ylabel('$C_{L}$')
title('V-stab')
grid on
hold on

ax8 = subplot(2,4,8);
plot(aeroStruct(4).alpha,aeroStruct(4).CD);
xlabel('$\alpha$ [deg]')
ylabel('$C_{D}$')
grid on
hold on

linkaxes([ax4,ax8],'x');

axis([ax1 ax2 ax3 ax4],[-inf inf hCL_ax.YLim(1) hCL_ax.YLim(2)]);
axis([ax5 ax6 ax7 ax8],[-inf inf hCD_ax.YLim(1) hCD_ax.YLim(2)]);

dsgnData.plot;
plot3(aeroStruct(1).aeroCentPosVec(1),aeroStruct(1).aeroCentPosVec(2),aeroStruct(1).aeroCentPosVec(3),'b+')
plot3(aeroStruct(2).aeroCentPosVec(1),aeroStruct(2).aeroCentPosVec(2),aeroStruct(2).aeroCentPosVec(3),'b+')
plot3(aeroStruct(3).aeroCentPosVec(1),aeroStruct(3).aeroCentPosVec(2),aeroStruct(3).aeroCentPosVec(3),'b+')
plot3(aeroStruct(4).aeroCentPosVec(1),aeroStruct(4).aeroCentPosVec(2),aeroStruct(4).aeroCentPosVec(3),'b+')



end