function [CLtotTbl,CDtotTbl,CltotTbl,CmtotTbl,CntotTbl] =...
    avlBuildLookupTable(saveFileName,aeroResults)

alphas      = [];
betas       = [];
flaps       = [];
ailerons    = [];
elevators   = [];
rudders     = [];

CLs         = [];
CDs         = [];
Cls         = [];
Cms         = [];
Cns         = [];


for ii = 1:length(aeroResults)
    for jj = 1:length(aeroResults{ii})
        alphas      = [alphas       aeroResults{ii}(jj).FT.Alpha];
        betas       = [betas        aeroResults{ii}(jj).FT.Beta];
        flaps       = [flaps        aeroResults{ii}(jj).FT.flap];
        ailerons    = [ailerons     aeroResults{ii}(jj).FT.aileron];
        elevators   = [elevators    aeroResults{ii}(jj).FT.elevator];
        rudders     = [rudders      aeroResults{ii}(jj).FT.rudder];
        
        CLs         = [CLs          aeroResults{ii}(jj).FT.CLtot];     
        CDs         = [CDs          aeroResults{ii}(jj).FT.CDtot];     
        Cls         = [Cls          aeroResults{ii}(jj).FT.Cltot];     
        Cms         = [Cms          aeroResults{ii}(jj).FT.Cmtot];     
        Cns         = [Cns          aeroResults{ii}(jj).FT.Cntot];     
        
    end
end

inputs = [alphas' betas' flaps' ailerons' elevators' rudders'];
ouptuts  = [CLs' CDs' Cls' Cms' Cns'];    

alphas      = unique(alphas);
betas       = unique(betas);
flaps       = unique(flaps);
ailerons    = unique(ailerons);
elevators   = unique(elevators);
rudders     = unique(rudders);

nalphas     = numel(alphas);
nbetas      = numel(betas);
nflaps      = numel(flaps);
nailerons   = numel(ailerons);
nelevators  = numel(elevators);
nrudders    = numel(rudders);

tableDims = size(nan(nalphas,nbetas,nflaps,nailerons,nelevators,nrudders));

% Initialize lookup tables for all the aero coefficients
% Lift coefficient
CLtotTbl = Simulink.LookupTable;
CLtotTbl.StructTypeInfo.Name = 'CLtotTbl';
CLtotTbl.Table.Value = reshape(CLs,tableDims);
CLtotTbl.Breakpoints(1).Value = alphas;
CLtotTbl.Breakpoints(2).Value = betas;
CLtotTbl.Breakpoints(3).Value = flaps;
CLtotTbl.Breakpoints(4).Value = ailerons;
CLtotTbl.Breakpoints(5).Value = elevators;
CLtotTbl.Breakpoints(6).Value = rudders;

% Drag coefficient
CDtotTbl = Simulink.LookupTable;
CDtotTbl.StructTypeInfo.Name = 'CDtotTbl';
CDtotTbl.Table.Value = reshape(CDs,tableDims);
CDtotTbl.Breakpoints(1).Value = alphas;
CDtotTbl.Breakpoints(2).Value = betas;
CDtotTbl.Breakpoints(3).Value = flaps;
CDtotTbl.Breakpoints(4).Value = ailerons;
CDtotTbl.Breakpoints(5).Value = elevators;
CDtotTbl.Breakpoints(6).Value = rudders;

% Moment about body x lookup table
CltotTbl = Simulink.LookupTable;
CltotTbl.StructTypeInfo.Name = 'CltotTbl';
CltotTbl.Table.Value = reshape(Cls,tableDims);
CltotTbl.Breakpoints(1).Value = alphas;
CltotTbl.Breakpoints(2).Value = betas;
CltotTbl.Breakpoints(3).Value = flaps;
CltotTbl.Breakpoints(4).Value = ailerons;
CltotTbl.Breakpoints(5).Value = elevators;
CltotTbl.Breakpoints(6).Value = rudders;

% Moment about body y lookup table
CmtotTbl = Simulink.LookupTable;
CmtotTbl.StructTypeInfo.Name = 'CmtotTbl';
CmtotTbl.Table.Value = reshape(Cms,tableDims);
CmtotTbl.Breakpoints(1).Value = alphas;
CmtotTbl.Breakpoints(2).Value = betas;
CmtotTbl.Breakpoints(3).Value = flaps;
CmtotTbl.Breakpoints(4).Value = ailerons;
CmtotTbl.Breakpoints(5).Value = elevators;
CmtotTbl.Breakpoints(6).Value = rudders;

% Moment about body z lookup table
CntotTbl = Simulink.LookupTable;
CntotTbl.StructTypeInfo.Name = 'CntotTbl';
CntotTbl.Table.Value = reshape(Cns,tableDims);
CntotTbl.Breakpoints(1).Value = alphas;
CntotTbl.Breakpoints(2).Value = betas;
CntotTbl.Breakpoints(3).Value = flaps;
CntotTbl.Breakpoints(4).Value = ailerons;
CntotTbl.Breakpoints(5).Value = elevators;
CntotTbl.Breakpoints(6).Value = rudders;

saveFileName = fullfile(fileparts(which('avl.exe')),'designLibrary',saveFileName);
save(saveFileName,'CLtotTbl','CDtotTbl','CltotTbl','CmtotTbl','CntotTbl')
end