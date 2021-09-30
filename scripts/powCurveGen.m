flwArray = 0.15:0.05:0.5;                %   m/s - candidate flow speeds
altArray = 50:50:400;                   %   m - candidate operating altitudes
thrArray = 200:50:600;                 %   m - candidate tether lengths
thrDiam = 18.0;
fairing = 50;
for i = 1:numel(flwArray)
    for j = 1:numel(thrArray)
        for k = 1:numel(altArray)
            flwSpd = flwArray(i);           %   m/s - current flow speed
            thrLength = thrArray(j);        %   m = current tether length
            altitude = altArray(k);
            iter = k + (j-1)*numel(altArray) + (i-1)*numel(altArray)*numel(thrArray);
            perc = iter/(numel(altArray)*numel(thrArray)*numel(flwArray))*100;
            note = sprintf('%.1f Complete\n',perc); fprintf(note);
            filename = sprintf(strcat('CDR_V-%.3f_alt-%.d_thrL-%d_thrD-%.1f_Fair-%d.mat'),flwSpd,altitude,thrLength,thrDiam,fairing);
            fpath = fullfile(fileparts(which('OCTProject.prj')),sprintf('output\\PowSurf%d\\',fairing));
            if isfile([fpath filename])
                load([fpath filename])
                if tsc.lapNumS.Data(end) >= 2
                    dt = datestr(now,'mm-dd_HH-MM');
                    [Idx1,Idx2] = tsc.getLapIdxs(max(tsc.lapNumS.Data)-1);  ran = Idx1:Idx2;
                    [CLtot,CDtot] = tsc.getCLCD(vhcl,thr);
                    [Lift,Drag,Fuse,Thr] = tsc.getLiftDrag;
                    Turb = squeeze(sqrt(sum(tsc.FTurbBdy.Data.^2,1)));
                    Pow = tsc.rotPowerSummary(vhcl,env,thr);
                    R.Pavg(i,j,k) = Pow.elec;
                    R.Pnet(i,j,k) = Pow.net;
                    V = squeeze(sqrt(sum(tsc.velCMvec.Data.^2,1)));
                    R.Vavg(i,j,k) = mean(V(ran));
                    R.AoA(i,j,k) = mean(squeeze(tsc.vhclAngleOfAttack.Data(:,:,ran)));
                    airNode = squeeze(sqrt(sum(tsc.airTenVecs.Data.^2,1)))*1e-3;
                    gndNode = squeeze(sqrt(sum(tsc.gndNodeTenVecs.Data.^2,1)))*1e-3;
                    R.ten(i,j,k) = max([max(airNode(ran)) max(gndNode(ran))]);
                    R.CL(i,j,k) = mean(CLtot(ran));   R.CD(i,j,k) = mean(CDtot(ran));
                    R.Fdrag(i,j,k) = mean(Drag(ran)); R.Flift(i,j,k) = mean(Lift(ran));
                    R.Ffuse(i,j,k) = mean(Fuse(ran)); R.Fthr(i,j,k) = mean(Thr(ran));   R.Fturb(i,j,k) = mean(Turb(ran));
                    R.elevation(i,j,k) = el*180/pi;
                    R.thrL(i,j,k) = thrLength; R.alt(i,j,k) = altitude; R.flw(i,j,k) = flwSpd;
                else
                    R.Pavg(i,j,k) = NaN;  R.AoA(i,j,k) = NaN;   R.ten(i,j,k) = NaN;
                    R.CL(i,j,k) = NaN;    R.CD(i,j,k) = NaN;    R.Fdrag(i,j,k) = NaN;
                    R.Flift(i,j,k) = NaN; R.Ffuse(i,j,k) = NaN; R.Fthr(i,j,k) = NaN;
                    R.Fturb(i,j,k) = NaN; R.elevation(i,j,k) = el*180/pi;
                    R.Pnet(i,j,k) = NaN;  R.Vavg(i,j,k) = NaN;
                    R.thrL(i,j,k) = thrLength; R.alt(i,j,k) = altitude; R.flw(i,j,k) = flwSpd;
                end
            else
                R.Pavg(i,j,k) = NaN;  R.AoA(i,j,k) = NaN;   R.ten(i,j,k) = NaN;
                R.CL(i,j,k) = NaN;    R.CD(i,j,k) = NaN;    R.Fdrag(i,j,k) = NaN;
                R.Flift(i,j,k) = NaN; R.Ffuse(i,j,k) = NaN; R.Fthr(i,j,k) = NaN;
                R.Fturb(i,j,k) = NaN; R.elevation(i,j,k) = el*180/pi;
                R.Pnet(i,j,k) = NaN;  R.Vavg(i,j,k) = NaN;
                R.thrL(i,j,k) = thrLength; R.alt(i,j,k) = altitude; R.flw(i,j,k) = flwSpd;
            end
        end
    end
end
filename1 = sprintf('Pow_Study_CDR_ThrD-%.1f_Fair-%d.mat',thrDiam,fairing);
fpath1 = fullfile(fileparts(which('OCTProject.prj')),'output\');
save([fpath1,filename1],'R','thrLength','fairing','flwSpd','thrDiam','Tmax','altitude')