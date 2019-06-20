function avlPartitioned(obj,alphaRange,numSteps)

% create input files
avlCreateInputFilePart(obj);

%% wing
% set run cases
obj.sweepCase.alpha = linspace(alphaRange(1),alphaRange(2),numSteps);
obj.sweepCase.beta       = 0;
obj.sweepCase.flap       = 0;
obj.sweepCase.aileron    = 0;
obj.sweepCase.elevator   = 0;
obj.sweepCase.rudder     = 0;

% run AVL for right wing 
avlProcessPart(obj,obj.wing_ip_file_name,'sweep','Parallel',true);
load(obj.result_file_name,'results');

[CLWing1DTable,CDWing1DTable,CMxWing1DTable] =...
    avlPartitionedLookupTable(obj,'wing_res',results);

% get wing aileron gains
n_case = 10;
obj.sweepCase.alpha = 0;
obj.sweepCase.aileron = linspace(-5,5,n_case);

avlProcessPart(obj,obj.wing_ip_file_name,'sweep','Parallel',true);
load(obj.result_file_name,'results');

CL_w = NaN(1,n_case);
CD_w = NaN(1,n_case);
for ii = 1:n_case
    CL_w(ii) = results{1}(ii).FT.CLtot;
    CD_w(ii) = results{1}(ii).FT.CDtot;
end

CL_kWing = polyfit(obj.sweepCase.aileron,CL_w,2);
CD_kWing = polyfit(obj.sweepCase.aileron,CD_w,2);

WingAeroData.CLWing1DTable = CLWing1DTable;
WingAeroData.CDWing1DTable = CDWing1DTable;
WingAeroData.CMxWing1DTable = CMxWing1DTable;
WingAeroData.CL_kWing = CL_kWing;
WingAeroData.CD_kWing = CD_kWing;

%% horizontal stabilizers
% set run cases
obj.sweepCase.alpha = linspace(alphaRange(1),alphaRange(2),numSteps);
obj.sweepCase.beta       = 0;
obj.sweepCase.flap       = 0;
obj.sweepCase.aileron    = 0;
obj.sweepCase.elevator   = 0;
obj.sweepCase.rudder     = 0;

% run AVL for HS
avlProcessPart(obj,obj.hs_ip_file_name,'sweep','Parallel',true);
load(obj.result_file_name,'results');

[CLHS1DTable,CDHS1DTable,CMxHS1DTable] =...
    avlPartitionedLookupTable(obj,'hs_res',results);

% get wing aileron gains
n_case = 5;
obj.sweepCase.alpha = 0;
obj.sweepCase.aileron = linspace(-5,5,n_case);

avlProcessPart(obj,obj.hs_ip_file_name,'sweep','Parallel',true);
load(obj.result_file_name,'results');

CL_hs = NaN(1,n_case);
CD_hs = NaN(1,n_case);
for ii = 1:n_case
    CL_hs(ii) = results{1}(ii).FT.CLtot;
    CD_hs(ii) = results{1}(ii).FT.CDtot;
end

CL_kHS = polyfit(obj.sweepCase.aileron,CL_hs,2);
CD_kHS = polyfit(obj.sweepCase.aileron,CD_hs,2);

HSAeroData.CLHS1DTable = CLHS1DTable;
HSAeroData.CDHS1DTable = CDHS1DTable;
HSAeroData.CMxHS1DTable = CMxHS1DTable;
HSAeroData.CL_kHS = CL_kHS;
HSAeroData.CD_kHS = CD_kHS;

%% vertical stabilizer
% set run cases
obj.sweepCase.alpha = linspace(alphaRange(1),alphaRange(2),numSteps);
obj.sweepCase.beta       = 0;
obj.sweepCase.flap       = 0;
obj.sweepCase.aileron    = 0;
obj.sweepCase.elevator   = 0;
obj.sweepCase.rudder     = 0;

% run AVL for HS
avlProcessPart(obj,obj.vs_ip_file_name,'sweep','Parallel',true);
load(obj.result_file_name,'results');

[CLVS1DTable,CDVS1DTable,CMxVS1DTable] =...
    avlPartitionedLookupTable(obj,'hs_res',results);

% get wing aileron gains
n_case = 5;
obj.sweepCase.alpha = 0;
obj.sweepCase.aileron = linspace(-5,5,n_case);

avlProcessPart(obj,obj.vs_ip_file_name,'sweep','Parallel',true);
load(obj.result_file_name,'results');

CL_vs = NaN(1,n_case);
CD_vs = NaN(1,n_case);
for ii = 1:n_case
    CL_vs(ii) = results{1}(ii).FT.CLtot;
    CD_vs(ii) = results{1}(ii).FT.CDtot;
end

CL_kVS = polyfit(obj.sweepCase.aileron,CL_vs,2);
CD_kVS = polyfit(obj.sweepCase.aileron,CD_vs,2);

VSAeroData.CLVS1DTable = CLVS1DTable;
VSAeroData.CDVS1DTable = CDVS1DTable;
VSAeroData.CMxVS1DTable = CMxVS1DTable;
VSAeroData.CL_kVS = CL_kVS;
VSAeroData.CD_kVS = CD_kVS;

dsgnData = obj;

avlPartitionedResults.WingAeroData = WingAeroData;
avlPartitionedResults.HSAeroData = HSAeroData;
avlPartitionedResults.VSAeroData = VSAeroData;

save(obj.lookup_table_file_name,'avlPartitionedResults','dsgnData');



end










