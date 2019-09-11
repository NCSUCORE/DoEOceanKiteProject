%clear all
 %clc
% format compact

%% Set up environment
% Create
%duration_s is needed in workspace to run this file
if exist('flowspeed') == 0
  flowspeed = 1;
end
    
env = ENV.variedFlow;
env.gravAccel.setValue(9.81,'m/s^2')
env.addFlow({'water'},{'variedFlow'},'FlowDensities',1000)
env.waveBias.setValue(1.5,'')
env.depth.setValue(2,'m')
env.amplitude.setValue(.5,'')
period = 10; % seconds
env.setPeriod(duration_s, period);
env.repeat.setValue(3,'')
%set to 2 for sine wave flow, set to one for constant uniform flow
env.waveCoursenessFactor.setValue(10,'')

%set automatically if it flowtype is ADCP data
env.setDepthArray(duration_s)

env.water.velVec.setValue([flowspeed 0 0],'m/s');
env.velVec.setValue(env.water.velVec.Value,'m/s');

if exist('flowType') == 0
  flowType = 'adcpFlowWithTurbulence';
end
%DONT CHANGE THIS WITHOUT CHANGING THE TURBULENCE BUILD MAT. IT TAKES
%FOREVER TO RUN SO JUST DONT CHANGE IT
env.setStartADCPTime(4000,'s')
flowSeries = createTimeSeriesFlow(env,duration_s,env.water.velVec.Value,flowType);

% createTimeSeriesFlow(env,duration_s,env.water.velVec.Value,flowType,env.startADCPTime.Value); 

env.setFlowTSeries(flowSeries,'')
variableFlow_bc(env.depthArray.Value,env.flowTSeries.Value.data)



 ENVIRONMENT = 'variableFlow';

 saveBuildFile('env',mfilename,'variant','ENVIRONMENT');

