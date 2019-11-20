function tf = checkedAgainstSavedVersion(saveFile,obj,varName,varargin)
p = inputParser;
addParameter(p,'Exceptions',{},@iscell);
parse(p,varargin{:})
tf = true;

% If the file doesn't exist, then obviously it doesn't match
if ~isfile(saveFile)
    tf = false;
    return
end

oldObj = obj;
newObj = load(saveFile,varName);
newObj = newObj.(varName);

oldProps = sort(properties(oldObj));
newProps = sort(properties(newObj));

if numel(oldProps)~=numel(newProps)
    tf = false;
    return
end

for ii = 1:numel(oldProps)
    if ~any(strcmp(oldProps{ii},p.Results.Exceptions))
        switch class(oldObj.(oldProps{ii}).Value)
            case 'timeseries'
                % Check that data is the same size
                if any(size(oldObj.(oldProps{ii}).Value.Data)~=...
                        size(newObj.(newProps{ii}).Value.Data))
                    tf = false;
                    return
                end
                if any(oldObj.(oldProps{ii}).Value.Data~=newObj.(newProps{ii}).Value.Data)
                    tf = false;
                    return
                end
                
            otherwise
                try
                if oldObj.(oldProps{ii}).Value ~= newObj.(newProps{ii}).Value
                    tf = false;
                    return
                end
                catch 
                   tf = false;
                   return;
                end
        end
    end
end

end