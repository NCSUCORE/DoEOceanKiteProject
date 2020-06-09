function [CLtot_1D_Tbl,CDtot_1D_Tbl] =...
    avlPartitionedLookupTable(aeroResults)

nCases = 25*(length(aeroResults) - 1) + length(aeroResults{end});

alphas      = NaN(1,nCases);
ailerons    = NaN(1,nCases);

CLs         = NaN(1,nCases);
CDs         = NaN(1,nCases);
Cms         = NaN(1,nCases);

kk = 1;

for ii = 1:length(aeroResults)
    for jj = 1:length(aeroResults{ii})
        alphas(kk)      = aeroResults{ii}(jj).FT.Alpha;
        ailerons(kk)    = aeroResults{ii}(jj).FT.aileron;
        
        CLs(kk)         = aeroResults{ii}(jj).FT.CLtot;     
        CDs(kk)         = aeroResults{ii}(jj).FT.CDtot;     
        Cms(kk)         = aeroResults{ii}(jj).FT.Cmtot;     
        
        kk = kk+1;
        
    end
end

alphas      = unique(alphas);
nalphas     = numel(alphas);

tableDims = size(nan(1,nalphas));

% Initialize lookup tables for all the aero coefficients
% Lift coefficient
CLtot_1D_Tbl = Simulink.LookupTable;
CLtot_1D_Tbl.StructTypeInfo.Name = 'CLtot_1D_Tbl';
CLtot_1D_Tbl.Table.Value = reshape(CLs,tableDims)';
CLtot_1D_Tbl.Breakpoints(1).Value = alphas;

% Drag coefficient
CDtot_1D_Tbl = Simulink.LookupTable;
CDtot_1D_Tbl.StructTypeInfo.Name = 'CDtot_1D_Tbl';
CDtot_1D_Tbl.Table.Value = reshape(CDs,tableDims)';
CDtot_1D_Tbl.Breakpoints(1).Value = alphas;


% saveFileName = fullfile(fileparts(which('avl.exe')),'designLibrary',saveFileName);
% dsgnData = obj;
% save(saveFileName,'CLtot_1D_Tbl','CDtot_1D_Tbl','dsgnData');


end