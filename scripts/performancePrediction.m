clear val ind
close all
thrL = [0 250 500];

loadComponent('ultDoeKiteTSR');
gbLoss = vhcl.gearBoxLoss.Value;
kt = vhcl.genKt.Value;
R = vhcl.genR.Value;
gbRat = vhcl.gearBoxRatio.Value;
legEnt = {'Baseline'};
for i = 1:numel(thrL)
    titleEnt{i} = sprintf('$l_{eff}=$ %dm',thrL(i));
end

h = figure(1);
h.Position=[100 100 1500 500];
tL = tiledlayout(1,3);

h2 = figure(2);
h2.Position=[100 100 1500 500];
tL2 = tiledlayout(1,3);

h3 = figure(3);
h3.Position=[100 100 1500 500];
tL3 = tiledlayout(1,3);

h4 = figure(4);
h4.Position=[100 100 1500 500];
tL4 = tiledlayout(1,3);

vehicles = {'ultDoeKiteTSR'};

for i = 1:numel(vehicles)
            loadComponent(vehicles{i});
    alph = 5:1:20;
T = vhcl.turb1.RPMref.Value(1):0.25:vhcl.turb1.RPMref.Value(end);
eta1 = 0;-0.2:.05:.2;
rho = 1000;
velW = 1:.1:2;
[alpha,TSR,TSR1,eta,velW1]=ndgrid(alph,T,T,eta1,velW);
eta2 = -eta;
x = size(alpha);
    for j = 1:3
        loadComponent('pathFollowingTether');                       %   Manta Ray tether
        thr.numNodes.setValue(9,'');
        thr.tether1.numNodes.setValue(9,'');
        thr.tether1.setDensity(1000,'kg/m^3');
        thr.tether1.setDiameter(0.022,'m');

        [CL,CD] = vhcl.getCLCD(thr,thrL(j)*4);
        CD = CD.kiteThr;
        alphaVhc = vhcl.stbdWing.alpha.Value;
        
        CP = vhcl.turb1.CpLookup.Value;
        CT = vhcl.turb1.CtLookup.Value;
        [ref,refInd] = max(CP./CT);
        refTSR = vhcl.turb1.RPMref.Value;
        compInd = find(T==refTSR(refInd));
        
        cpctTSR = refTSR(refInd);
        turbDiam = vhcl.turb1.diameter.Value;
        if i == 4
            turbDiam = turbDiam*1.2;
        end
        turbArea = pi*turbDiam^2/4;
        refArea = vhcl.fluidRefArea.Value;
        N = vhcl.numTurbines.Value/2; %Num turbines per side
        areaRatio = (turbArea)/refArea; %area ratio of each turbine
        
        cl = interp1(alphaVhc,CL,alpha);
        cd = interp1(alphaVhc,CD,alpha);
        cp = N*interp1(refTSR,CP,TSR)*areaRatio.*cos(alpha*pi/180).^3;
        ct = N*interp1(refTSR,CT,TSR)*areaRatio;
        cp1 = N*interp1(refTSR,CP,TSR1)*areaRatio.*cos(alpha*pi/180).^3;
        ct1 = N*interp1(refTSR,CT,TSR1)*areaRatio;

        glideRatio = cl./(ct.*(1+eta2).^2+ct1.*(1+eta).^2+cd);      
        vApp = velW1.*glideRatio;
        powNorm = 1/2*rho*vApp.^3*refArea;
%         if i == 4
%             glideRatio = glideRatio*0.8;
%         end
        %Gearbox Losses
        RPM = TSR.*vApp*(60/(pi*turbDiam));
        RPM1 = TSR1.*vApp*(60/(pi*turbDiam));

        gbEta = N*RPM*gbLoss./powNorm;
        gbEta1 = N*RPM1*gbLoss./powNorm;
        
        %Generator Losses
        mosfetLoss = 1.1;
        motOmega = RPM*gbRat*2*pi/60;
        motOmega1 = RPM1*gbRat*2*pi/60;
        genPow = (cp-gbEta)/N.*powNorm;
        genPow1 = (cp1-gbEta1)/N.*powNorm;
        genT = genPow./motOmega/1.3558*12*16;
        genC = genT/kt;
        genL = genC.^2*R;
        genEta = N*genL./powNorm*mosfetLoss;
        
        genT1 = genPow1./motOmega1/1.3558*12*16;
        genC1 = genT1/kt;
        genL1 = genC1.^2*R;
        genEta1 = N*genL1./powNorm*mosfetLoss;
        
        Cp = (1+eta2).^3.*cp+(1+eta).^3.*cp1;
        Cpeff = Cp-gbEta-gbEta1-genEta-genEta1;
        Cpeff(Cpeff<0) = 0;
        gbEff = (Cp-gbEta-gbEta1)./(Cp);
        motEff = (Cp-gbEta-gbEta1-genEta1-genEta)./(Cp-gbEta-gbEta1);
        eff = gbEff.*motEff;
        cpSys = glideRatio.^3.*Cpeff;

        [m,n] = size(alpha);
        [powCoef,ind]=max(cpSys,[],[2 3],'linear');
        effOut = squeeze(eff(ind));
        gbEffOut = gbEff(ind);
        motEffOut = motEff(ind);
        powCoef = squeeze(powCoef);
        velWP = repmat(velW,size(powCoef(:,1)));
        
        
        P = 1/2*1000*velW.^3.*powCoef*refArea;
        P1 = 1/2*1000*velW1.^3.*cpSys*refArea;
        Pmech = P./effOut;
        TSRout = TSR(ind);
        
        
        figure(1)
        nexttile(j)
        title(titleEnt{j})
        hold on
        plotsq(velW,TSRout(14,:),'DisplayName',legEnt{i})
        ylim([0 inf])
        if j == 1
            legend('Location','northwest')
        end
        grid on
        ylabel 'TSR'
        xlabel 'Flow Velocity [m/s]'   
        
        figure(2)
        nexttile(j)
        title(titleEnt{j})
        hold on
        plotsq(alph,effOut(:,6),'DisplayName',legEnt{i})
        %         plot(alph,powCoef,'DisplayName',legEnt{i})
        ylim([0 inf])
        if j == 1
            legend('Location','northwest')
        end
        grid on
        ylabel 'Efficiency'
        xlabel 'AoA [deg]'
        
        figure(3)
        nexttile(j)
        title(titleEnt{j})
        hold on
        plotsq(TSR(14,:,1,1,6),cpSys(14,:,1,1,6)./max(cpSys(14,:,1,1,6)),'DisplayName','System Power Coefficient')
        plotsq(T,((cp(14,:,1,1,6)+cp1(14,:,1,1,6))./(ct(14,:,1,1,6)+ct1(14,:,1,1,6)))./max((cp(14,:,1,1,6)+cp1(14,:,1,1,6))./(ct(14,:,1,1,6)+ct1(14,:,1,1,6))),'DisplayName','Turbine $C_P/C_T$')
        ylim([0 inf])
        if j == 1
            legend('Location','northwest')
        end
        grid on
        ylabel 'TSR Normalized Coefficient'
        xlabel 'TSR'   
        
        figure(4)
        nexttile(j)
        title(titleEnt{j})
        hold on
        plotsq(velW,P(6,:),'DisplayName',legEnt{i})
        hold on
        
        ylim([0 inf])
        if j == 1
            legend('Location','northwest')
        end
        grid on
        ylabel 'Power'
        xlabel 'Flow Velocity [m/s]'
    end
end

tL.Padding = 'compact';
tL.TileSpacing = 'compact';
tL2.Padding = 'compact';
tL2.TileSpacing = 'compact';
tL3.Padding = 'compact';
tL3.TileSpacing = 'compact';
tL4.Padding = 'compact';
tL4.TileSpacing = 'compact';
