figure
tiledlayout(2,2)
hold on
grid on
[m,n] = size(tsc.rotorTorque.Data);

lap = tsc.lapNumS.max-1;
[idx1,idx2,~] = tsc.getLapIdxs(lap);
ran = idx1:idx2;
vAppMag = tsc.vAppTurb.mag;
for i = 1:n
    nexttile(1)
    hold on; grid on;
    plot(tsc.rotorTorque.Time(ran)-tsc.rotorTorque.Time(idx1),...
        tsc.rotorTorque.Data(ran,i))
    ylabel 'Rotor Torque [Nm]'
    set(gca,'FontSize',12)
    
    nexttile(2)
    hold on; grid on;
    plotsq(tsc.rotorTorque.Time(ran)-tsc.rotorTorque.Time(idx1),...
        tsc.rotorSpeed.Data(1,i,ran))
    ylabel 'Rotor Speed [RPM]'
    set(gca,'FontSize',12)
    
        nexttile(3)
    hold on; grid on;
    plotsq(tsc.rotorTorque.Time(ran)-tsc.rotorTorque.Time(idx1),...
        tsc.rotorPower.Data(1,i,ran))
    ylabel 'Rotor Power [W]'
    set(gca,'FontSize',12)
    
    nexttile(4)
    hold on; grid on;
    plotsq(tsc.rotorTorque.Time(ran)-tsc.rotorTorque.Time(idx1),...
        vAppMag.Data(1,i,ran))
    ylabel '$v_{app}$ [m/s]'
    set(gca,'FontSize',12)
end
xlabel 'Time [s]'