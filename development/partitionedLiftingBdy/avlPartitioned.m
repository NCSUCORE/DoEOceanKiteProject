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

% left wing data
partitionedAero(1).CLVals = reshape(CLWing1DTable.Table.Value,[],1);
partitionedAero(1).CDVals = reshape(CDWing1DTable.Table.Value,[],1);
partitionedAero(1).alpha   = reshape(CDWing1DTable.Breakpoints.Value,[],1);
partitionedAero(1).GainCL  = reshape(CL_kWing,1,[]);
partitionedAero(1).GainCD  = reshape(CD_kWing,1,[]);

% right wing data
partitionedAero(2).CLVals = reshape(CLWing1DTable.Table.Value,[],1);
partitionedAero(2).CDVals = reshape(CDWing1DTable.Table.Value,[],1);
partitionedAero(2).alpha   = reshape(CDWing1DTable.Breakpoints.Value,[],1);
partitionedAero(2).GainCL  = reshape(CL_kWing,1,[]);
partitionedAero(2).GainCD  = reshape(CD_kWing,1,[]);

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

partitionedAero(3).CLVals = reshape(CLHS1DTable.Table.Value,[],1);
partitionedAero(3).CDVals = reshape(CDHS1DTable.Table.Value,[],1);
partitionedAero(3).alpha   = reshape(CDHS1DTable.Breakpoints.Value,[],1);
partitionedAero(3).GainCL  = reshape(CL_kHS,1,[]);
partitionedAero(3).GainCD  = reshape(CD_kHS,1,[]);

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

partitionedAero(4).CLVals = reshape(CLVS1DTable.Table.Value,[],1);
partitionedAero(4).CDVals = reshape(CDVS1DTable.Table.Value,[],1);
partitionedAero(4).alpha   = reshape(CDVS1DTable.Breakpoints.Value,[],1);
partitionedAero(4).GainCL  = reshape(CL_kVS,1,[]);
partitionedAero(4).GainCD  = reshape(CD_kVS,1,[]);

dsgnData = obj;

save(obj.lookup_table_file_name,'partitionedAero','dsgnData');



end










