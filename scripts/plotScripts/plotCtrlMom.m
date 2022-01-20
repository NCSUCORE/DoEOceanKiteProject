figure
t = tiledlayout(2,2)

nexttile(t)
plotsq(tsc.portWingCtrlMom.Time,tsc.portWingCtrlMom.Data)
xlabel 'Time [s]'
ylabel 'Port Aileron Moment [Nm]'

nexttile
plotsq(tsc.stbdWingCtrlMom.Time,tsc.stbdWingCtrlMom.Data)
xlabel 'Time [s]'
ylabel 'Starboard Aileron Moment [Nm]'

nexttile
plotsq(tsc.hStabCtrlMom.Time,tsc.hStabCtrlMom.Data)
xlabel 'Time [s]'
ylabel 'Elevator Moment [Nm]'

nexttile
plotsq(tsc.vStabCtrlMom.Time,tsc.vStabCtrlMom.Data)
xlabel 'Time [s]'
ylabel 'Rudder Moment [Nm]'