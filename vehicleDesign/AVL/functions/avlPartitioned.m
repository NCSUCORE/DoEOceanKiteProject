function [CL,CD,GainCL,GainCD] = avlPartitioned(obj)

% create input files
avlCreateInputFilePart(obj,'input.avl');
% Sref = obj.refArea.Value;

results = avlProcessPart(obj,obj.alpha.Value,0);

[CLWingTab,CDWingTab] = avlPartitionedLookupTable(results);

% get wing aileron gains
n_case = 10;
ctrlDefls = linspace(-5,5,n_case);
results = avlProcessPart(obj,0,ctrlDefls);

CL_w = NaN(1,n_case);
CD_w = NaN(1,n_case);
for ii = 1:n_case
    CL_w(ii) = results{1}(ii).FT.CLtot;
    CD_w(ii) = results{1}(ii).FT.CDtot;
end

CL_kWing = polyfit(ctrlDefls,CL_w,2);
CL_kWing(end) = 0;
CD_kWing = polyfit(ctrlDefls,CD_w,2);
CD_kWing(end) = 0;

CL = reshape(CLWingTab.Table.Value,[],1);
CD = reshape(CDWingTab.Table.Value,[],1);

GainCL = reshape(CL_kWing,1,[]);
GainCD =  reshape(CD_kWing,1,[]);

delete('input.avl')

end










