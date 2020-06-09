function tscIter = parseIterations(tsc)
rstIdx = logical(diff(tsc.iterationNumber.Data));
startTimes = tsc.iterationNumber.Time([true rstIdx(:)']);
endTimes   = tsc.iterationNumber.Time([rstIdx(:)' true]);
signalNames = fieldnames(tsc);

for ii = 1:numel(signalNames)
    for jj = 1:numel(endTimes)-1
        try
            tscIter{jj}.(signalNames{ii}) = ...
                getsampleusingtime(tsc.(signalNames{ii}),startTimes(jj),endTimes(jj));
        catch
            warning('Skipping Signal %s',signalNames{ii})
            break % Break out of loop over start/end times
        end
    end
end
end
