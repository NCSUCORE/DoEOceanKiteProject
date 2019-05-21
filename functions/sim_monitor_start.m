function [] = sim_monitor_start(model,timestep)
    %model should be a string of the name of the model you are about to run
    %timestep (optional) allows control over how often the text will print
    %Example of how to run:
    %try
    %    sim_monitor_start('OCTModel')
    %    sim('OCTModel')
    %    sim_monitor_end('OCTModel')
    %catch
    %    sim_monitor_end('OCTModel')
    %end
    if nargin==1
        timestep=2;
    end
    sim_timer=timer("Name",strcat(model,"_timer"));
    sim_timer.period=2;
    sim_timer.ExecutionMode = 'fixedRate';
    sim_timer.TimerFcn = ...
        @(myTimerObj, thisEvent)disp(['The Current simulation time is '...
        num2str(get_param(model,'SimulationTime')) 'seconds. Run time is '...
        num2str(timestep*(myTimerObj.TasksExecuted-1)) ' seconds.']);
    sim_timer.StopFcn = @(myTimerObj, thisEvent)disp(...
        strcat("Timer for ", model, " Stopped"));
    start(sim_timer)
end