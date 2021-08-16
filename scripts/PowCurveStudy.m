%%  Load Results
% thrDarray = 18;[11 14 16 18];
% fairArray = 100;[0 100];
% flwArray = 0.1:0.05:0.5;                %   m/s - candidate flow speeds
% altArray = 50:50:400;                   %   m - candidate operating altitudes
% thrArray = 100:100:600;                 %   m - candidate tether lengths
% 
% loadComponent('pathFollowWithAoACtrl');             %   Path-following controller with AoA control
% loadComponent('Manta2RotXFoil_AR8_b8');             %   AR = 8; 8m span
% Cp0 = interp1(vhcl.turb1.RPMref.Value,vhcl.turb1.CpLookup.Value,fltCtrl.RPMConst.Value);
% Ct0 = interp1(vhcl.turb1.RPMref.Value,vhcl.turb1.CtLookup.Value,fltCtrl.RPMConst.Value);
% D0 = vhcl.turb1.diameter.Value; A0 = pi/4*D0^2;
% Cp1 = 0.288;  Ct1 = 0.425; A1 = A0*Ct0/Ct1; D1 = sqrt(A1*4/pi);
% f = Cp1/Cp0*A1/A0;
% Rthr = 13.96;   Vthr = 1000;
% for ii = 1:4
%     for jj = 1:2
%         thrDiam = thrDarray(ii);   fairing = fairArray(jj);
%         filename1 = sprintf('Pow_Study_CDR_ThrD-%.1f_Fair-%d.mat',thrDiam,fairing);
%         fpath1 = fullfile(fileparts(which('OCTProject.prj')),'output\');
%         load([fpath1 filename1]);
%         %%  Reassign variables
%         for i = 1:numel(flwArray)
%             for j = 1:numel(altArray)
%                 if ~isnan(max(R.Pavg(i,:,j)))
%                     idx1 = find(R.Pavg(i,:,j)==max(R.Pavg(i,:,j)));
%                     R1.Pavg(i,j) = R.Pavg(i,idx1,j)*f;
%                     Ploss = (R1.Pavg(i,j)*1e3/Vthr)^2*Rthr*1e-3;
%                     R1.Pnet(i,j) = R.Pavg(i,idx1,j)*f*.76-Ploss;
%                     R1.Vavg(i,j) = R.Vavg(i,idx1,j);
%                     R1.alpha(i,j) = R.AoA(i,idx1,j);
%                     R1.CD(i,j) = R.CD(i,idx1,j);
%                     R1.CL(i,j) = R.CL(i,idx1,j);
%                     R1.EL(i,j) = R.elevation(i,idx1,j);
%                     R1.ten(i,j) = R.ten(i,idx1,j);
%                     R1.thrL(i,j) = R.thrL(i,idx1,j);
%                     R1.Fdrag(i,j) = R.Fdrag(i,idx1,j);
%                     R1.Ffuse(i,j) = R.Ffuse(i,idx1,j);
%                     R1.Flift(i,j) = R.Flift(i,idx1,j);
%                     R1.Fthr(i,j) = R.Fthr(i,idx1,j);
%                     R1.Fturb(i,j) = R.Fturb(i,idx1,j);
%                 else
%                     R1.Pavg(i,j) = NaN;
%                     R1.Pnet(i,j) = NaN;
%                     R1.Vavg = NaN;
%                     R1.CD(i,j) = NaN;
%                     R1.CL(i,j) = NaN;
%                     R1.EL(i,j) = NaN;
%                     R1.ten(i,j) = NaN;
%                     R1.thrL(i,j) = NaN;
%                     R1.Fdrag(i,j) = NaN;
%                     R1.Ffuse(i,j) = NaN;
%                     R1.Flift(i,j) = NaN;
%                     R1.Fthr(i,j) = NaN;
%                     R1.Fturb(i,j) = NaN;
%                 end
%             end
%         end
%         %%  Save
%         fpath = fullfile(fileparts(which('OCTProject.prj')),'output\');
%         save([fpath,sprintf('powStudy_CDR_ThrD-%.1f_Fair-%d.mat',thrDiam,fairing)],'flwArray','altArray','thrArray','R1','R','thrDiam','fairing');
%         %%  Save Power Curve
%         Pnet = R1.Pnet; Pavg = R1.Pavg;
%         fpath = fullfile(fileparts(which('OCTProject.prj')),'output\PowSurfaces\');
%         save([fpath sprintf('PowCurve_CDR_D-%.1f_F-%d.mat',thrDiam,fairing)],'Pnet','Pavg','flwArray','altArray')
%     end
% end
%%  Extract Results
flwArray = 0.5;%0.1:0.05:0.5;                %   m/s - candidate flow speeds
altArray = 50:50:400;                   %   m - candidate operating altitudes
thrArray = 100:100:600;                 %   m - candidate tether lengths
thrDiam = 18.0;                         %   mm - candidate tether diameters
Tmax = getMaxTension(thrDiam);          %   kN - candidate tether tension limits
fairing = 100;                          %   m - length of fairing distribution

for i = 1:numel(flwArray)
    for j = 1:numel(thrArray)
        for k = 1:numel(altArray)
            flwSpd = flwArray(i);           %   m/s - current flow speed
            thrLength = thrArray(j);        %   m = current tether length
            altitude = altArray(k);         %   m - current altitude
            if ~(altitude == 1/2*thrLength)
                el = NaN;
            else
                el = asin(altitude/thrLength);
            end
            if ~isnan(el)
                try
                    filename = sprintf(strcat('CDR_V-%.3f_alt-%.d_thrL-%d_thrD-%.1f_Fair-%d.mat'),flwSpd,altitude,thrLength,thrDiam,fairing);
                    fpath = 'D:\Power Study\';
                    load(strcat(fpath,filename))
                    [Idx1,Idx2] = tsc.getLapIdxs(max(tsc.lapNumS.Data)-1);  ran = Idx1:Idx2;
                    [CLtot,CDtot] = tsc.getCLCD(vhcl,thr);
                    [Lift,Drag,Fuse,Thr] = tsc.getLiftDrag;
                    Turb = squeeze(sqrt(sum(tsc.FTurbBdy.Data.^2,1)));
                    Pow = tsc.rotPowerSummary(vhcl,env,thr);
                    R.Pavg(i,j,k) = Pow.mech;
                    R.Pnet(i,j,k) = Pow.net;
                    V = squeeze(sqrt(sum(tsc.velCMvec.Data.^2,1)));
                    R.Vavg(i,j,k) = mean(V(ran));
                    R.Vmax(i,j,k) = max(V(ran));
                    R.AoA(i,j,k) = mean(squeeze(tsc.vhclAngleOfAttack.Data(:,:,ran)));
                    airNode = squeeze(sqrt(sum(tsc.airTenVecs.Data.^2,1)))*1e-3;
                    gndNode = squeeze(sqrt(sum(tsc.gndNodeTenVecs.Data.^2,1)))*1e-3;
                    R.ten(i,j,k) = max([max(airNode(ran)) max(gndNode(ran))]);
                    R.CL(i,j,k) = mean(CLtot(ran));   R.CD(i,j,k) = mean(CDtot(ran));
                    R.Fdrag(i,j,k) = mean(Drag(ran)); R.Flift(i,j,k) = mean(Lift(ran));
                    R.Ffuse(i,j,k) = mean(Fuse(ran)); R.Fthr(i,j,k) = mean(Thr(ran));   R.Fturb(i,j,k) = mean(Turb(ran));
                    R.elevation(i,j,k) = el*180/pi;
                    R.thrL(i,j,k) = thrLength; R.alt(i,j,k) = altitude; R.flw(i,j,k) = flwSpd;
                catch
                    R.Pavg(i,j,k) = NaN;  R.AoA(i,j,k) = NaN;   R.ten(i,j,k) = NaN;
                    R.CL(i,j,k) = NaN;    R.CD(i,j,k) = NaN;    R.Fdrag(i,j,k) = NaN;
                    R.Flift(i,j,k) = NaN; R.Ffuse(i,j,k) = NaN; R.Fthr(i,j,k) = NaN;
                    R.Fturb(i,j,k) = NaN; R.elevation(i,j,k) = el*180/pi; 
                    R.Pnet(i,j,k) = NaN;  R.Vavg(i,j,k) = NaN;  R.Vmax(i,j,k) = NaN; 
                    R.thrL(i,j,k) = thrLength; R.alt(i,j,k) = altitude; R.flw(i,j,k) = flwSpd;
                end
            else
                R.Pavg(i,j,k) = NaN;  R.AoA(i,j,k) = NaN;   R.ten(i,j,k) = NaN;
                R.CL(i,j,k) = NaN;    R.CD(i,j,k) = NaN;    R.Fdrag(i,j,k) = NaN;
                R.Flift(i,j,k) = NaN; R.Ffuse(i,j,k) = NaN; R.Fthr(i,j,k) = NaN;
                R.Fturb(i,j,k) = NaN; R.elevation(i,j,k) = el*180/pi;
                R.Pnet(i,j,k) = NaN;  R.Vavg(i,j,k) = NaN;  R.Vmax(i,j,k) = NaN;
                R.thrL(i,j,k) = thrLength; R.alt(i,j,k) = altitude; R.flw(i,j,k) = flwSpd;
            end
        end
    end
end

