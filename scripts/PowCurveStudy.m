%%  Load Results 
flwArray = 0.1:0.05:0.5;                %   m/s - candidate flow speeds
altArray = 50:50:400;                   %   m - candidate operating altitudes
thrArray = 100:100:600;                 %   m - candidate tether lengths
thrDiam = 14;   fairing = 00;
filename1 = sprintf('Pow_Study_CDR_ThrD-%.1f_Fair-%d.mat',thrDiam,fairing);
fpath1 = fullfile(fileparts(which('OCTProject.prj')),'output\');
load([fpath1 filename1]);
%%  Reassign variables 
for i = 1:numel(flwArray)
    for j = 1:numel(altArray)
        if ~isnan(max(R.Pavg(i,:,j)))
            idx1 = find(R.Pavg(i,:,j)==max(R.Pavg(i,:,j)));
            R1.Pavg(i,j) = R.Pavg(i,idx1,j);
            R1.Pnet(i,j) = R.Pnet(i,idx1,j);
            R1.Vavg(i,j) = R.Vavg(i,idx1,j);
            R1.alpha(i,j) = R.AoA(i,idx1,j);
            R1.CD(i,j) = R.CD(i,idx1,j);
            R1.CL(i,j) = R.CL(i,idx1,j);
            R1.EL(i,j) = R.elevation(i,idx1,j);
            R1.ten(i,j) = R.ten(i,idx1,j);
            R1.thrL(i,j) = R.thrL(i,idx1,j);
            R1.Fdrag(i,j) = R.Fdrag(i,idx1,j);
            R1.Ffuse(i,j) = R.Ffuse(i,idx1,j);
            R1.Flift(i,j) = R.Flift(i,idx1,j);
            R1.Fthr(i,j) = R.Fthr(i,idx1,j);
            R1.Fturb(i,j) = R.Fturb(i,idx1,j);
        else
            R1.Pavg(i,j) = NaN;
            R1.Pnet(i,j) = NaN;
            R1.Vavg = NaN;
            R1.CD(i,j) = NaN;
            R1.CL(i,j) = NaN;
            R1.EL(i,j) = NaN;
            R1.ten(i,j) = NaN;
            R1.thrL(i,j) = NaN;
            R1.Fdrag(i,j) = NaN;
            R1.Ffuse(i,j) = NaN;
            R1.Flift(i,j) = NaN;
            R1.Fthr(i,j) = NaN;
            R1.Fturb(i,j) = NaN;
        end
    end
end
%%  Save
fpath = fullfile(fileparts(which('OCTProject.prj')),'output\');
save([fpath,sprintf('powStudy_CDR_ThrD-%.1f_Fair-%d.mat',thrDiam,fairing)],'flwArray','altArray','thrArray','R1','R','thrDiam','fairing');
%%  Save Power Curve 
Pnet = R1.Pnet; Pavg = R1.Pavg;
fpath = fullfile(fileparts(which('OCTProject.prj')),'output\');
save([fpath sprintf('PowCurve_CDR_D-%.1f_F-%d.mat',thrDiam,fairing)],'Pnet','Pavg','flwArray','altArray')
%%  Extract Results 
% simScenario = 1.3;  TDiam = 0.0125;   eff = 0.95;
% fpath2 = fullfile(fileparts(which('OCTProject.prj')),'vehicleDesign','Tether\');
% Tmax = 20;
% thrLength = 200:50:600;                                     %   m - Initial tether length
% flwSpd = 0.1:0.05:0.5;                                      %   m/s - Flow speed
% altitude = [50 100 150 200 250 300];
% for kk = 1:numel(flwSpd)
%     for ii = 1:numel(thrLength)
%         for jj = 1:numel(altitude)
%             if altitude(jj) >= 0.7071*thrLength(ii) || altitude(jj) <= 0.1736*thrLength(ii)
%                 el = NaN;
%             else
%                 el = asind(altitude(jj)/thrLength(ii))*pi/180;
%             end
%             if ~isnan(el)
%                 filename = sprintf(strcat('Turb%.1f_V-%.3f_Alt-%.d_ThrL-%d_Tmax-%d.mat'),simScenario,flwSpd(kk),altitude(jj),thrLength(ii),Tmax);
%                 fpath = 'D:\Altitude Thr-L Study\';
%                 load(strcat(fpath,filename))
%                 [Idx1,Idx2] = tsc.getLapIdxs(max(tsc.lapNumS.Data)-1);  ran = Idx1:Idx2;
%                 [CLtot,CDtot] = tsc.getCLCD(vhcl);
%                 [Lift,Drag,Fuse,Thr] = tsc.getLiftDrag;
%                 Turb = squeeze(sqrt(sum(tsc.FTurbBdy.Data.^2,1)));
%                 Pow = tsc.rotPowerSummary(vhcl,env);
%                 Pavg(kk,ii,jj) = Pow.avg;    Pnet(kk,ii,jj) = Pow.avg*eff;
%                 V = squeeze(sqrt(sum(tsc.velCMvec.Data.^2,1)));
%                 Vavg(kk,ii,jj) = mean(V(ran));
%                 AoA(kk,ii,jj) = mean(squeeze(tsc.vhclAngleOfAttack.Data(:,:,ran)));
%                 airNode = squeeze(sqrt(sum(tsc.airTenVecs.Data.^2,1)))*1e-3;
%                 gndNode = squeeze(sqrt(sum(tsc.gndNodeTenVecs.Data.^2,1)))*1e-3;
%                 ten(kk,ii,jj) = max([max(airNode(ran)) max(gndNode(ran))]);
%                 fprintf('Average AoA = %.3f;\t Max Tension = %.1f kN;\t Elevation = %.1f\n',AoA(kk,ii,jj),ten(kk,ii,jj),el*180/pi);
%                 CL(kk,ii,jj) = mean(CLtot(ran));   CD(kk,ii,jj) = mean(CDtot(ran));
%                 Fdrag(kk,ii,jj) = mean(Drag(ran)); Flift(kk,ii,jj) = mean(Lift(ran));
%                 Ffuse(kk,ii,jj) = mean(Fuse(ran)); Fthr(kk,ii,jj) = mean(Thr(ran));   Fturb(kk,ii,jj) = mean(Turb(ran));
%                 elevation(kk,ii,jj) = el*180/pi;
%             else
%                 Pavg(kk,ii,jj) = NaN;  AoA(kk,ii,jj) = NaN;   ten(kk,ii,jj) = NaN;
%                 CL(kk,ii,jj) = NaN;    CD(kk,ii,jj) = NaN;    Fdrag(kk,ii,jj) = NaN;
%                 Flift(kk,ii,jj) = NaN; Ffuse(kk,ii,jj) = NaN; Fthr(kk,ii,jj) = NaN;
%                 Fturb(kk,ii,jj) = NaN; elevation(kk,ii,jj) = el*180/pi;
%                 Pnet(kk,ii,jj) = NaN;   Vavg(kk,ii,jj) = NaN;
%             end
%         end
%     end
% end

