function avlPartitioned(obj,alphaRange,numSteps)

% create input files
avlCreateInputFilePart(obj);
Sref = obj.ref_area;

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

[CLWingTab,CDWingTab] = avlPartitionedLookupTable(results);

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
CL_kWing(end) = 0;
CD_kWing = polyfit(obj.sweepCase.aileron,CD_w,2);
CD_kWing(end) = 0;

% left wing data
aeroStruct(1).refArea        = Sref;
aeroStruct(1).aeroCentPosVec = -obj.reference_point  + [...
    (tand(obj.wing_sweep)*obj.wing_span/4) + obj.wing_chord*(1 + obj.wing_TR)/8;...
    -obj.wing_span/4; tand(obj.wing_dihedral)*obj.wing_span/4];
aeroStruct(1).spanUnitVec    = [0 1 0];
aeroStruct(1).chordUnitVec   = [1 0 0];
aeroStruct(1).CL = reshape(CLWingTab.Table.Value,[],1);
aeroStruct(1).CD = reshape(CDWingTab.Table.Value+0.01,[],1);
aeroStruct(1).alpha = reshape(CDWingTab.Breakpoints.Value,[],1);
aeroStruct(1).GainCL = reshape(CL_kWing,1,[]);
aeroStruct(1).GainCD =  reshape(CD_kWing,1,[]);
aeroStruct(1).MaxCtrlDeflDn = obj.wing_CS_deflection_range(1);
aeroStruct(1).MaxCtrlDeflUp = obj.wing_CS_deflection_range(2);


% right wing data
aeroStruct(2).refArea        = Sref;
aeroStruct(2).aeroCentPosVec = aeroStruct(1).aeroCentPosVec.*[1;-1;1];
aeroStruct(2).spanUnitVec    = [0 1 0];
aeroStruct(2).chordUnitVec   = [1 0 0];
aeroStruct(2).CL = reshape(CLWingTab.Table.Value,[],1);
aeroStruct(2).CD = reshape(CDWingTab.Table.Value+0.01,[],1);
aeroStruct(2).alpha = reshape(CDWingTab.Breakpoints.Value,[],1);
aeroStruct(2).GainCL = reshape(CL_kWing,1,[]);
aeroStruct(2).GainCD =  reshape(CD_kWing,1,[]);
aeroStruct(2).MaxCtrlDeflDn = obj.wing_CS_deflection_range(1);
aeroStruct(2).MaxCtrlDeflUp = obj.wing_CS_deflection_range(2);


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

[CLHSTab,CDHSTab] = avlPartitionedLookupTable(results);

% get HS aileron gains
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
CL_kHS(end) = 0;
CD_kHS = polyfit(obj.sweepCase.aileron,CD_hs,2);
CD_kHS(end) = 0;

% HS data
aeroStruct(3).refArea        = Sref;
aeroStruct(3).aeroCentPosVec = -obj.reference_point  + [obj.h_stab_LE + (obj.h_stab_chord/4);0 ;0];
aeroStruct(3).spanUnitVec    = [0 1 0];
aeroStruct(3).chordUnitVec   = [1 0 0];
aeroStruct(3).CL = reshape(CLHSTab.Table.Value,[],1);
aeroStruct(3).CD = reshape(CDHSTab.Table.Value+0.01,[],1);
aeroStruct(3).alpha = reshape(CDHSTab.Breakpoints.Value,[],1);
aeroStruct(3).GainCL = reshape(CL_kHS,1,[]);
aeroStruct(3).GainCD =  reshape(CD_kHS,1,[]);
aeroStruct(3).MaxCtrlDeflDn = obj.h_stab_CS_deflection_range(1);
aeroStruct(3).MaxCtrlDeflUp = obj.h_stab_CS_deflection_range(2);


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

[CLVSTab,CDVSTab] = avlPartitionedLookupTable(results);

% get VS aileron gains
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
CL_kVS(end) = 0;
CD_kVS = polyfit(obj.sweepCase.aileron,CD_vs,2);
CD_kVS(end) = 0;

aeroStruct(4).refArea        = Sref;
aeroStruct(4).aeroCentPosVec = -obj.reference_point  + [...
    obj.v_stab_LE + (tand(obj.v_stab_sweep)*obj.v_stab_span/2) + obj.v_stab_chord*(1 + obj.v_stab_TR)/8;...
    0 ;obj.v_stab_span/2];
aeroStruct(4).spanUnitVec    = [0 0 1];
aeroStruct(4).chordUnitVec   = [1 0 0];
aeroStruct(4).CL = reshape(CLVSTab.Table.Value,[],1);
aeroStruct(4).CD = reshape(CDVSTab.Table.Value+0.01,[],1);
aeroStruct(4).alpha = reshape(CDVSTab.Breakpoints.Value,[],1);
aeroStruct(4).GainCL = reshape(CL_kVS,1,[]);
aeroStruct(4).GainCD =  reshape(CD_kVS,1,[]);
aeroStruct(4).MaxCtrlDeflDn = obj.v_stab_CS_deflection_range(1);
aeroStruct(4).MaxCtrlDeflUp = obj.v_stab_CS_deflection_range(2);


dsgnData = obj;
save(obj.lookup_table_file_name,'aeroStruct','dsgnData');

delete(obj.wing_ip_file_name);
delete(obj.hs_ip_file_name);
delete(obj.vs_ip_file_name);

%
filepath = fileparts(which('avl.exe'));

delete(fullfile(filepath,strcat(obj.result_file_name,'.mat')));



end










