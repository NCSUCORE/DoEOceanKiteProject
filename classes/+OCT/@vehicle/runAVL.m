function varargout = runAVL(obj)
presFolder = pwd;
avlCreateInputFilePart_v2LE(obj)

%% wing
alp_max = 55;
alp_min = -55;
n_steps = 71;
% set run cases
alphas   = linspace(alp_min,alp_max,n_steps);
ailerons = 0;

% run AVL for right wing
avlProcessPart_v2LE(obj,'wing',alphas,ailerons,'Parallel',true);
load('resultFile','results');

[CLWingTab,CDWingTab] = avlPartitionedLookupTable(results);

% get wing aileron gains
n_case = 10;
alphas = 0;
ailerons = linspace(-5,5,n_case);

avlProcessPart_v2LE(obj,'wing',alphas,ailerons,'Parallel',true);
load('resultFile','results');

CL_w = NaN(1,n_case);
CD_w = NaN(1,n_case);
for ii = 1:n_case
    CL_w(ii) = results{1}(ii).FT.CLtot;
    CD_w(ii) = results{1}(ii).FT.CDtot;
end

CL_kWing = polyfit(ailerons,CL_w,2);
CL_kWing(end) = 0;
CD_kWing = polyfit(ailerons,CD_w,2);
CD_kWing(end) = 0;

% port wing data
CdOffset = 0.01;
aeroStruct(1).CL = reshape(CLWingTab.Table.Value,[],1);
aeroStruct(1).CD = reshape(CDWingTab.Table.Value,[],1) + CdOffset;
aeroStruct(1).alpha = reshape(CDWingTab.Breakpoints.Value,[],1);
aeroStruct(1).GainCL = reshape(CL_kWing,1,[]);
aeroStruct(1).GainCD =  reshape(CD_kWing,1,[]);

% stbd wing data
aeroStruct(2).CL = aeroStruct(1).CL;
aeroStruct(2).CD = aeroStruct(1).CD;
aeroStruct(2).alpha = aeroStruct(1).alpha;
aeroStruct(2).GainCL = aeroStruct(1).GainCL;
aeroStruct(2).GainCD =  aeroStruct(1).GainCD;

%% horizontal stabilizers
% set run cases
alphas   = linspace(alp_min,alp_max,n_steps);
ailerons = 0;

% run AVL for HS
avlProcessPart_v2LE(obj,'H_stab',alphas,ailerons,'Parallel',true);
load('resultFile','results');

[CLHSTab,CDHSTab] = avlPartitionedLookupTable(results);

% get HS aileron gains
alphas = 0;
ailerons = linspace(-5,5,n_case);

avlProcessPart_v2LE(obj,'H_stab',alphas,ailerons,'Parallel',true);
load('resultFile','results');

CL_hs = NaN(1,n_case);
CD_hs = NaN(1,n_case);

for ii = 1:n_case
    CL_hs(ii) = results{1}(ii).FT.CLtot;
    CD_hs(ii) = results{1}(ii).FT.CDtot;
end

CL_kHS = polyfit(ailerons,CL_hs,2);
CL_kHS(end) = 0;
CD_kHS = polyfit(ailerons,CD_hs,2);
CD_kHS(end) = 0;

% HS data
aeroStruct(3).CL = reshape(CLHSTab.Table.Value,[],1);
aeroStruct(3).CD = reshape(CDHSTab.Table.Value,[],1) + CdOffset;
aeroStruct(3).alpha = reshape(CDHSTab.Breakpoints.Value,[],1);
aeroStruct(3).GainCL = reshape(CL_kHS,1,[]);
aeroStruct(3).GainCD =  reshape(CD_kHS,1,[]);

%% vertical stabilizer
% set run cases
alphas   = linspace(alp_min,alp_max,n_steps);
ailerons = 0;

% run AVL for VS
avlProcessPart_v2LE(obj,'V_stab',alphas,ailerons,'Parallel',true);
load('resultFile','results');

[CLVSTab,CDVSTab] = avlPartitionedLookupTable(results);

% get VS aileron gains
alphas = 0;
ailerons = linspace(-5,5,n_case);

avlProcessPart_v2LE(obj,'V_stab',alphas,ailerons,'Parallel',true);
load('resultFile','results');

CL_vs = NaN(1,n_case);
CD_vs = NaN(1,n_case);
for ii = 1:n_case
    CL_vs(ii) = results{1}(ii).FT.CLtot;
    CD_vs(ii) = results{1}(ii).FT.CDtot;
end

CL_kVS = polyfit(ailerons,CL_vs,2);
CL_kVS(end) = 0;
CD_kVS = polyfit(ailerons,CD_vs,2);
CD_kVS(end) = 0;

aeroStruct(4).CL = reshape(CLVSTab.Table.Value,[],1);
aeroStruct(4).CD = reshape(CDVSTab.Table.Value,[],1) + CdOffset;
aeroStruct(4).alpha = reshape(CDVSTab.Breakpoints.Value,[],1);
aeroStruct(4).GainCL = reshape(CL_kVS,1,[]);
aeroStruct(4).GainCD =  reshape(CD_kVS,1,[]);

aeroStruct = reshape(aeroStruct,1,[]);

save(obj.fluidCoeffsFileName.Value,'aeroStruct');

fclose('all');
%     delete('wing');
%     delete('H_stab');
%     delete('V_stab');

filepath = fileparts(which('avl.exe'));

delete(fullfile(filepath,strcat('resultFile','.mat')));

fprintf('''%s'' created in:\n %s\n',...
    obj.fluidCoeffsFileName.Value,fileparts(which(obj.fluidCoeffsFileName.Value)));

cd(presFolder);

if nargout == 1
    varargout{1} = aeroStruct;
end
end