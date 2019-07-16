function simLogsout = simWithMonitor(model,timestep)
    if nargin==1
        timestep=2;
    end
    try
        sim_monitor_start(model,timestep)
        sim(model)
        sim_monitor_end(model)
    catch e
        sim_monitor_end(model)
        fprintf(2,'There was an error!')
        fprintf(2,'The identifier was:\n     %s\n',e.identifier);
        fprintf(2,'The message was:\n     %s\n',e.message);
        if ~isempty(e.cause)
            fprintf(2,'The cause was:\n     %s\n',e.cause{1}.message);
        end
    end
    if exist('logsout','var')
        assignin('base', 'logsout', logsout);
    else
        simLogsout=[];
    end
end
function [] = sim_monitor_start(model,timestep)
    %model should be a string of the name of the model you are about to run
    %timestep (optional) allows control over how often the text will print

    sim_timer=timer("Name",strcat(model,"_timer"));
    sim_timer.period=2;
    sim_timer.ExecutionMode = 'fixedRate';
    sim_timer.TimerFcn = ...
        @(myTimerObj, thisEvent)fprintf('The Current simulation time is %0.5f seconds. Run time is %0.1f seconds.\n',...
        get_param(model,'SimulationTime'),timestep*(myTimerObj.TasksExecuted-1));
%     disp(['The Current simulation time is '...
%         num2str(get_param(model,'SimulationTime')) 'seconds. Run time is '...
%         num2str(timestep*(myTimerObj.TasksExecuted-1)) ' seconds.']);
    
    sim_timer.StopFcn = @(myTimerObj, thisEvent)disp(...
        strcat("Timer for ", model, " Stopped"));
    start(sim_timer)
end

function [] = sim_monitor_end(model)
    %Finds the timer opened by the sim_monitor_start call using the same
    %model, closes it, and deletes it.
    %Should run without error if given a model without a running timer.
    sim_timer=timerfind("Name",strcat(model,"_timer"));
    stop(sim_timer);
    delete(sim_timer);  
end