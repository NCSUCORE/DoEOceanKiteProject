function simLogsout = simWithMonitor(model,varargin)
    %model should be a string of the name of the model you are about to run
    %timeStep (optional) allows control over how often the text will print.
    %   Default: 2 seconds;
    %minRate (optional but requires timeStep because I don't have the time
    %   to implement input parser) minimum sim-sec/sec rate over 5 timeSteps
    %   before stopping. Default: 0.001; inputting a rate of zero disables the stop;
    p=inputParser;
    addRequired(p,'model');
    addParameter(p,'timeStep',2);
    addParameter(p,'minRate',0.00001);
    parse(p,model,varargin{:})
    model=p.Results.model;
    timeStep=p.Results.timeStep;
    minRate=p.Results.minRate;
    try
        simMonitorStart(model,timeStep,minRate)
        sim(model)
        simMonitorEnd(model)
    catch e
        fprintf(2,'simWithMonitor caught an error.\n')
        fprintf(2,'The identifier was:\n     %s\n',e.identifier);
        fprintf(2,'The message was:\n     %s\n',e.message);
        if ~isempty(e.cause)
            fprintf(2,'The cause was:\n     %s\n',e.cause{1}.message);
        end
        simMonitorEnd(model)
    end
    if exist('logsout','var')
        assignin('base', 'logsout', logsout);
    else
        simLogsout=[];
    end
end
function myTimerFcn(myTimerObj, ~, model,timeStep,minRate)
    oldtimes=get(myTimerObj,'UserData');
    time=get_param(model,'SimulationTime');
    stat=get_param(model,'SimulationStatus');
    if stat~= "running"
        fprintf('Simulation status is %s.\n',stat)
    else
        fprintf('Simulation time: %0.5f seconds; Run time: %0.1f seconds; Rate: %0.2f simsec/sec;\n',...
        time,timeStep*(myTimerObj.TasksExecuted-1),(time-oldtimes(end))/timeStep);
        if oldtimes(1)>0 && minRate>0 && (time-oldtimes(1))/((length(oldtimes))*timeStep) < minRate
            set_param(model, 'SimulationCommand', 'stop')
            fprintf(2,'Simulation stopped by simWithMonitor because average rate dropped below %.4g sim-sec/sec for longer than %.3g sec.\nUse simWithMonitor(model,''minRate'',0) to disable this functionality.\n',minRate,(length(oldtimes))*timeStep);
            pause(.5);%Allow the simulation to actually stop.
        end
    end
    oldtimes(1:end-1)=oldtimes(2:end);
    oldtimes(end)=time;
    set(myTimerObj,'UserData',oldtimes);
end
function [] = simMonitorStart(model,timeStep,minRate)
    if ~slreportgen.utils.isModelLoaded(model)
        open_system(model)
    end
    oldtimes = zeros(1,5);
    sim_timer=timer("Name",strcat(model,"_timer"));
    sim_timer.UserData = oldtimes;
    sim_timer.period=timeStep;
    sim_timer.ExecutionMode = 'fixedRate';
    sim_timer.TimerFcn = {@myTimerFcn, model, timeStep, minRate};
%         @(myTimerObj, thisEvent)fprintf('The Current simulation time is %0.5f seconds. Run time is %0.1f seconds.\n',...
%         get_param(model,'SimulationTime'),timeStep*(myTimerObj.TasksExecuted-1));
%     disp(['The Current simulation time is '...
%         num2str(get_param(model,'SimulationTime')) 'seconds. Run time is '...
%         num2str(timeStep*(myTimerObj.TasksExecuted-1)) ' seconds.']);
    
    sim_timer.StopFcn = @(myTimerObj, thisEvent)fprintf('Timer for %s stopped.\n',model);
    start(sim_timer)
end