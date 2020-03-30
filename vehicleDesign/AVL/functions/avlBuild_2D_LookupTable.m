function [CLtot_2D_Tbl,CDtot_2D_Tbl,Cltot_2D_Tbl,Cmtot_2D_Tbl,Cntot_2D_Tbl] =...
    avlBuild_2D_LookupTable(obj,aeroResults)

saveFileName = obj.lookup_table_file_name;
nCases = 25*(length(aeroResults) - 1) + length(aeroResults{end});

alphas      = NaN(1,nCases);
betas       = NaN(1,nCases);
flaps       = NaN(1,nCases);
ailerons    = NaN(1,nCases);
elevators   = NaN(1,nCases);
rudders     = NaN(1,nCases);

CLs         = NaN(1,nCases);
CDs         = NaN(1,nCases);
Cls         = NaN(1,nCases);
Cms         = NaN(1,nCases);
Cns         = NaN(1,nCases);

kk = 1;

for ii = 1:length(aeroResults)
    for jj = 1:length(aeroResults{ii})
        alphas(kk)      = aeroResults{ii}(jj).FT.Alpha;
        betas(kk)       = aeroResults{ii}(jj).FT.Beta;
        flaps(kk)       = aeroResults{ii}(jj).FT.flap;
        ailerons(kk)    = aeroResults{ii}(jj).FT.aileron;
        elevators(kk)   = aeroResults{ii}(jj).FT.elevator;
        rudders(kk)     = aeroResults{ii}(jj).FT.rudder;
        
        CLs(kk)         = aeroResults{ii}(jj).FT.CLtot;     
        CDs(kk)         = aeroResults{ii}(jj).FT.CDtot;     
        Cls(kk)         = aeroResults{ii}(jj).FT.Cltot;     
        Cms(kk)         = aeroResults{ii}(jj).FT.Cmtot;     
        Cns(kk)         = aeroResults{ii}(jj).FT.Cntot;
        
        kk = kk+1;
        
    end
end

inputs = [alphas' betas' flaps' ailerons' elevators' rudders'];
ouptuts  = [CLs' CDs' Cls' Cms' Cns'];    

alphas      = unique(alphas);
betas       = unique(betas);

nalphas     = numel(alphas);
nbetas      = numel(betas);

tableDims = size(nan(nbetas,nalphas));

% Initialize lookup tables for all the aero coefficients
% Lift coefficient
CLtot_2D_Tbl = Simulink.LookupTable;
CLtot_2D_Tbl.StructTypeInfo.Name = 'CLtot_2D_Tbl';
CLtot_2D_Tbl.Table.Value = reshape(CLs,tableDims)';
CLtot_2D_Tbl.Breakpoints(1).Value = alphas;
CLtot_2D_Tbl.Breakpoints(2).Value = betas;

% Drag coefficient
CDtot_2D_Tbl = Simulink.LookupTable;
CDtot_2D_Tbl.StructTypeInfo.Name = 'CDtot_2D_Tbl';
CDtot_2D_Tbl.Table.Value = reshape(CDs,tableDims)';
CDtot_2D_Tbl.Breakpoints(1).Value = alphas;
CDtot_2D_Tbl.Breakpoints(2).Value = betas;

% Moment about body x lookup table
Cltot_2D_Tbl = Simulink.LookupTable;
Cltot_2D_Tbl.StructTypeInfo.Name = 'Cltot_2D_Tbl';
Cltot_2D_Tbl.Table.Value = reshape(Cls,tableDims)';
Cltot_2D_Tbl.Breakpoints(1).Value = alphas;
Cltot_2D_Tbl.Breakpoints(2).Value = betas;

% Moment about body y lookup table
Cmtot_2D_Tbl = Simulink.LookupTable;
Cmtot_2D_Tbl.StructTypeInfo.Name = 'Cmtot_2D_Tbl';
Cmtot_2D_Tbl.Table.Value = reshape(Cms,tableDims)';
Cmtot_2D_Tbl.Breakpoints(1).Value = alphas;
Cmtot_2D_Tbl.Breakpoints(2).Value = betas;

% Moment about body z lookup table
Cntot_2D_Tbl = Simulink.LookupTable;
Cntot_2D_Tbl.StructTypeInfo.Name = 'Cntot_2D_Tbl';
Cntot_2D_Tbl.Table.Value = reshape(Cns,tableDims)';
Cntot_2D_Tbl.Breakpoints(1).Value = alphas;
Cntot_2D_Tbl.Breakpoints(2).Value = betas;

saveFileName = fullfile(fileparts(which('avl.exe')),'designLibrary',saveFileName);
dsgnData = obj;
save(saveFileName,'CLtot_2D_Tbl','CDtot_2D_Tbl','Cltot_2D_Tbl','Cmtot_2D_Tbl','Cntot_2D_Tbl','dsgnData')
end