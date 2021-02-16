%%
[Idx1,Idx2] = tsc.getLapIdxs(max(tsc.lapNumS.Data)-1);  ran = Idx1:Idx2;
V = -squeeze(tsc.velCMvec.Data(1,:,ran));
Time = squeeze(tsc.ctrlSurfDeflCmd.Time(ran,1));
PortAileron = squeeze(tsc.ctrlSurfDeflCmd.Data(ran,1));
StbdAileron = squeeze(tsc.ctrlSurfDeflCmd.Data(ran,2));
Elevator = squeeze(tsc.ctrlSurfDeflCmd.Data(ran,3));
Rudder = squeeze(tsc.ctrlSurfDeflCmd.Data(ran,4));
PortWingLoad = squeeze(tsc.portWingForce.Data(:,1,ran))';
StbdWingLoad = squeeze(tsc.stbdWingForce.Data(:,1,ran))';
HorStabLoad = squeeze(tsc.hStabForce.Data(:,1,ran))';
VerStabLoad = squeeze(tsc.vStabForce.Data(:,1,ran))';
TetherLoad = squeeze(tsc.airTenVecs.Data(:,1,ran))';
T1 = table(Time,PortAileron,StbdAileron,Elevator,Rudder,PortWingLoad,StbdWingLoad,HorStabLoad,VerStabLoad,TetherLoad);

Location = {'Center of Mass';'Center of Buoyancy';'Tether Attachment';'Port Wing Aero Center';'Stbd Wing Aero Center';'Hor Stab Aero Center';'Vert Stab Aero Center'};
CM = vhcl.rCM_LE.Value-vhcl.fuse.rNose_LE.Value;
CB = vhcl.rCentOfBuoy_LE.Value-vhcl.fuse.rNose_LE.Value;
ThrAttach = vhcl.rBridle_LE.Value-vhcl.fuse.rNose_LE.Value;
PortWingAC = vhcl.portWing.RSurf2Bdy.Value*vhcl.portWing.rAeroCent_SurfLE.Value-vhcl.fuse.rNose_LE.Value;
StbdWingAC = vhcl.stbdWing.RSurf2Bdy.Value*vhcl.stbdWing.rAeroCent_SurfLE.Value-vhcl.fuse.rNose_LE.Value;
HorStabAC = vhcl.hStab.rSurfLE_WingLEBdy.Value+vhcl.hStab.RSurf2Bdy.Value*vhcl.hStab.rAeroCent_SurfLE.Value-vhcl.fuse.rNose_LE.Value;
VerStabAC = vhcl.vStab.rSurfLE_WingLEBdy.Value+vhcl.vStab.RSurf2Bdy.Value*vhcl.vStab.rAeroCent_SurfLE.Value-vhcl.fuse.rNose_LE.Value;
X = [CM(1),CB(1),ThrAttach(1),PortWingAC(1),StbdWingAC(1),HorStabAC(1),VerStabAC(1)]';
Y = [CM(2),CB(2),ThrAttach(2),PortWingAC(2),StbdWingAC(2),HorStabAC(2),VerStabAC(2)]';
Z = [CM(3),CB(3),ThrAttach(3),PortWingAC(3),StbdWingAC(3),HorStabAC(3),VerStabAC(3)]';
T2 = table(Location,X,Y,Z);
%%
fpath = fullfile(fileparts(which('OCTProject.prj')),'Results','Manta 2.0\');
writetable(T1,[fpath 'Load_Profiles_and_Locations.xlsx'],'Sheet',1,'Range',sprintf('A1:T%d',numel(Time)+2))
writetable(T2,[fpath 'Load_Profiles_and_Locations.xlsx'],'Sheet',4,'Range','A1:D8')
