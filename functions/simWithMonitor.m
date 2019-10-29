function simLogsout = simWithMonitor(model,timestep)
    if nargin==1
        timestep=2;
    end
    try
        simMonitorStart(model,timestep)
        sim(model)
        simMonitorEnd(model)
    catch e
        fprintf(2,'\nsimWithMonitor caught an error.\n')
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
function myTimerFcn(myTimerObj, ~, model,timestep)
    oldtimes=get(myTimerObj,'UserData');
    time=get_param(model,'SimulationTime');
    oldtimes(1:3)=oldtimes(2:4);
    oldtimes(4)=time;
    set(myTimerObj,'UserData',oldtimes);
    stat=get_param(model,'SimulationStatus');
    if stat~= "running"
        fprintf('Status is %s.\n',stat)
    else
        fprintf('The Current simulation time is %0.5f seconds. Run time is %0.1f seconds. Rate is %0.2f sim-sec/sec\n',...
        time,timestep*(myTimerObj.TasksExecuted-1),(time-oldtimes(3))/timestep);
        minrate=0.001;
        if oldtimes(1)>0 && (time-oldtimes(1))/(5*timestep) < minrate
            set_param(model, 'SimulationCommand', 'stop')
            fprintf(2,'Simulation stopped by simWithMonitor because rate dropped below %f sim-sec/sec for longer than %0.0f sec.\n',minrate,5*timestep);
            pause(.5);%Allow the simulation to actually stop.
        end
    end
end
function [] = simMonitorStart(model,timestep)
    %model should be a string of the name of the model you are about to run
    %timestep (optional) allows control over how often the text will print
    if ~slreportgen.utils.isModelLoaded('OCTModel')
        OCTModel
    end
    oldtimes = zeros(1,4);
    sim_timer=timer("Name",strcat(model,"_timer"));
    sim_timer.UserData = oldtimes;
    sim_timer.period=timestep;
    sim_timer.ExecutionMode = 'fixedRate';
    sim_timer.TimerFcn = {@myTimerFcn, model, timestep};
%         @(myTimerObj, thisEvent)fprintf('The Current simulation time is %0.5f seconds. Run time is %0.1f seconds.\n',...
%         get_param(model,'SimulationTime'),timestep*(myTimerObj.TasksExecuted-1));
%     disp(['The Current simulation time is '...
%         num2str(get_param(model,'SimulationTime')) 'seconds. Run time is '...
%         num2str(timestep*(myTimerObj.TasksExecuted-1)) ' seconds.']);
    
    sim_timer.StopFcn = @(myTimerObj, thisEvent)disp(...
        strcat("Timer for ", model, " Stopped"));
    start(sim_timer)
end