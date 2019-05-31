function [CLtotTbl,CDtotTbl,CltotTbl,CmtotTbl,CntotTbl] =...
    buildAVLLookupTable(saveFile,inputFileName,resultsFileName,...
    alphas,betas,flaps,ailerons,elevators,rudders)
% Initialize lookup tables for all the aero coefficients
% Lift coefficient
CLtotTbl = Simulink.LookupTable;
CLtotTbl.StructTypeInfo.Name = 'CLtotTbl';
CLtotTbl.Table.Value = nan(...
    length(alphas),length(betas),length(flaps),...
    length(ailerons),length(elevators),length(rudders));
CLtotTbl.Breakpoints(1).Value = alphas;
CLtotTbl.Breakpoints(2).Value = betas;
CLtotTbl.Breakpoints(3).Value = flaps;
CLtotTbl.Breakpoints(4).Value = ailerons;
CLtotTbl.Breakpoints(5).Value = elevators;
CLtotTbl.Breakpoints(6).Value = rudders;
CLtotData = CLtotTbl.Table.Value;

% Drag coefficient
CDtotTbl = Simulink.LookupTable;
CDtotTbl.StructTypeInfo.Name = 'CDtotTbl';
CDtotTbl.Table.Value = nan(...
    length(alphas),length(betas),length(flaps),...
    length(ailerons),length(elevators),length(rudders));
CDtotTbl.Breakpoints(1).Value = alphas;
CDtotTbl.Breakpoints(2).Value = betas;
CDtotTbl.Breakpoints(3).Value = flaps;
CDtotTbl.Breakpoints(4).Value = ailerons;
CDtotTbl.Breakpoints(5).Value = elevators;
CDtotTbl.Breakpoints(6).Value = rudders;
CDtotData = CDtotTbl.Table.Value;

% Moment about body x lookup table
CltotTbl = Simulink.LookupTable;
CltotTbl.StructTypeInfo.Name = 'CltotTbl';
CltotTbl.Table.Value = nan(...
    length(alphas),length(betas),length(flaps),...
    length(ailerons),length(elevators),length(rudders));
CltotTbl.Breakpoints(1).Value = alphas;
CltotTbl.Breakpoints(2).Value = betas;
CltotTbl.Breakpoints(3).Value = flaps;
CltotTbl.Breakpoints(4).Value = ailerons;
CltotTbl.Breakpoints(5).Value = elevators;
CltotTbl.Breakpoints(6).Value = rudders;
CltotData = CltotTbl.Table.Value;


% Moment about body y lookup table
CmtotTbl = Simulink.LookupTable;
CmtotTbl.StructTypeInfo.Name = 'CmtotTbl';
CmtotTbl.Table.Value = nan(...
    length(alphas),length(betas),length(flaps),...
    length(ailerons),length(elevators),length(rudders));
CmtotTbl.Breakpoints(1).Value = alphas;
CmtotTbl.Breakpoints(2).Value = betas;
CmtotTbl.Breakpoints(3).Value = flaps;
CmtotTbl.Breakpoints(4).Value = ailerons;
CmtotTbl.Breakpoints(5).Value = elevators;
CmtotTbl.Breakpoints(6).Value = rudders;
CmtotData = CmtotTbl.Table.Value;

% Moment about body z lookup table
CntotTbl = Simulink.LookupTable;
CntotTbl.StructTypeInfo.Name = 'CntotTbl';
CntotTbl.Table.Value = nan(...
    length(alphas),length(betas),length(flaps),...
    length(ailerons),length(elevators),length(rudders));
CntotTbl.Breakpoints(1).Value = alphas;
CntotTbl.Breakpoints(2).Value = betas;
CntotTbl.Breakpoints(3).Value = flaps;
CntotTbl.Breakpoints(4).Value = ailerons;
CntotTbl.Breakpoints(5).Value = elevators;
CntotTbl.Breakpoints(6).Value = rudders;
CntotData = CntotTbl.Table.Value;

for ii = 1:length(alphas)
    alpha = alphas(ii);
    for jj = 1:length(betas)
        beta = betas(jj);
        for kk = 1:length(flaps)
            flap = flaps(kk);
            for mm = 1:length(ailerons)
                aileron = ailerons(mm);
                for nn = 1:length(elevators)
                    elevator = elevators(nn);
                    for pp = 1:length(rudders)
                        rudder = rudders(pp);
                        % Run AVL
                        avlRunCase(inputFileName,resultsFileName,...
                            alpha,beta,flap,aileron,elevator,rudder)
                        rslt = loadAVLResults(resultsFileName);
                        CLtotData(ii,jj,kk,mm,nn,pp) = rslt.CLtot;
                        CDtotData(ii,jj,kk,mm,nn,pp) = rslt.CDtot;
                        CltotData(ii,jj,kk,mm,nn,pp) = rslt.Cltot;
                        CmtotData(ii,jj,kk,mm,nn,pp) = rslt.Cmtot;
                        CntotData(ii,jj,kk,mm,nn,pp) = rslt.Cntot;
                    end
                end
            end
        end
    end
end

CLtotTbl.Table.Value = CLtotData;
CDtotTbl.Table.Value = CDtotData;
CltotTbl.Table.Value = CltotData;
CmtotTbl.Table.Value = CmtotData;
CntotTbl.Table.Value = CntotData;

save(saveFile,'CLtotTbl','CDtotTbl','CltotTbl','CmtotTbl','CntotTbl')
end