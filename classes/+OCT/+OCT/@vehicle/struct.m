function [val,varargout] = struct(obj,className)
% Function returns all properties of the specified class in a
% 1xN struct useable in a for loop in simulink
% Example classnames: OCT.turb, OCT.aeroSurf
props = sort(obj.getPropsByClass(className));
if numel(props)<1
    return
end

if  ismember(props{1},{'portWing','stbdWing','hStab','vStab'})
    props{1} = 'portWing';
    props{2} = 'stbdWing';
    props{3} = 'hStab';
    props{4} = 'vStab';
end
subProps = properties(obj.(props{1}));

if numel(obj.(props{1})) == 1
    for ii = 1:length(props)
        for jj = 1:numel(subProps)
            val(ii).(subProps{jj}) = obj.(props{ii}).(subProps{jj}).Value;
        end
    end
else
    for ii = 1:numel(obj.(props{1}))
        for jj = 1:numel(subProps)
            val(ii).(subProps{jj}) = obj.(props{1})(ii).(subProps{jj}).Value;
        end
    end
end
if nargout>0
    varargout{1} = props;
end
end