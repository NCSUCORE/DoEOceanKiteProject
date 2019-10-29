function [] = simMonitorEnd(model)
    %Finds the timer opened by the sim_monitor_start call using the same
    %model, closes it, and deletes it.
    %Should run without error if given a model without a running timer.
    sim_timer=timerfind("Name",strcat(model,"_timer"));
    if ~isempty(sim_timer)
        stop(sim_timer);
        delete(sim_timer);
        fprintf(2,'\n')
    end
end