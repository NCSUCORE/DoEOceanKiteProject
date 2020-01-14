function tscNew = resampleTSC(tscOld,t)
% RESAMPLETSC function to resample tsc to new time steps, useful for
% animations.  Input t can be either a time step (scalar) or vector, which
% will be interpreted as a vector of time steps to resample to.

fieldNames = fieldnames(tscOld);
endTime = [];
for ii = 1:numel(fieldNames)
    switch class(tscOld.(fieldNames{ii}))
        case 'timeseries'
            if ~isempty(tscOld.(fieldNames{ii}).Time)
            endTime = max([endTime tscOld.(fieldNames{ii}).Time(end)]);
            end
        case 'struct'
            subFieldNames = fieldnames(tscOld.(fieldNames{ii}));
            for jj = 1:numel(subFieldNames)
                endTime = max([endTime tscOld.(fieldNames{ii}).(subFieldNames{jj}).Time(end)]);
            end
        otherwise
            error('Unknown class for resampling')
    end
end
if numel(t)>1
    if t(end)~=endTime
        error('Specified time vector does not span entire duration')
    end
    timeVec = t;
else
    timeVec = 0:t:endTime;
end

for ii = 1:numel(fieldNames)
    try
    switch class(tscOld.(fieldNames{ii}))
        case 'timeseries'
            if length(tscOld.(fieldNames{ii}).Time)>1
                tscOld.(fieldNames{ii}) = resample(...
                    tscOld.(fieldNames{ii}),timeVec);
            else
                disp(fieldNames{ii})
            end
        case 'struct'
            subFieldNames = fieldnames(tscOld.(fieldNames{ii}));
            for jj = 1:numel(subFieldNames)
                tscOld.(fieldNames{ii}).(subFieldNames{jj}) = resample(...
                    tscOld.(fieldNames{ii}).(subFieldNames{jj}),timeVec);
                
            end
        otherwise
            error('Unknown class for resampling')
    end
    catch e
        disp(1)
    end
end
tscNew = tscOld;
end