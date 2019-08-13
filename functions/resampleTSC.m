function tscNew = resampleTSC(tscOld,t)

fieldNames = fieldnames(tscOld);
endTime = [];
for ii = 1:numel(fieldNames)
    switch class(tscOld.(fieldNames{ii}))
        case 'timeseries'
            endTime = max([endTime tscOld.(fieldNames{ii}).Time(end)]);
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
    switch class(tscOld.(fieldNames{ii}))
        case 'timeseries'
            tscOld.(fieldNames{ii}) = resample(...
                tscOld.(fieldNames{ii}),timeVec);
        case 'struct'
            subFieldNames = fieldnames(tscOld.(fieldNames{ii}));
            for jj = 1:numel(subFieldNames)
                tscOld.(fieldNames{ii}).(subFieldNames{jj}) = resample(...
                    tscOld.(fieldNames{ii}).(subFieldNames{jj}),timeVec);
                
            end
        otherwise
            error('Unknown class for resampling')
    end
end
tscNew = tscOld;
end