function varargout = compareObjects(obj1,obj2,varargin)
%uses the properties of object 1
%obj1 is the first argument obj2 is the second in the structure
%***varargin is used recursively. There is no need to use it when calling
%       compare objects***

    if isempty(varargin)
        prefix = class(obj1);
    else
        prefix = varargin{1};
    end
    if isempty(inputname(1))
        name1=varargin{2};
        name2=varargin{3};
    else
        name1=inputname(1);
        name2=inputname(2);
    end
    props = properties(obj1);
    output = (nargout >= 1);
    diffs = [];
    for i = 1:length(props)
            ind = length(diffs)+1;
            diffs(ind).name = props{i};
        try
            if isprop(obj1.(props{i}),'Value') && isprop(obj2.(props{i}),'Value')
                val1 = obj1.(props{i}).Value;
                val2 = obj2.(props{i}).Value;
                if val1 == val2
                    diffs(ind) = [];
                else
                    diffs(ind).name = props{i};
                    diffs(ind).(name1) = val1;
                    diffs(ind).(name2) = val2;
                    fprintf(['For the property %s.%s, %s had a value of'...
                            ' %f, and %s had a value of %f.\n'],...
                            prefix,props{i},name1,val1,name2,val2)
                end
            else
                subprops = compareObjects(obj1.(props{i}),obj2.(props{i}),[prefix '.' props{i}],name1,name2);
                if ~isempty(subprops)
                    diffs(ind).subprops = subprops;
                else
                    diffs(ind) = [];
                end
            end
        catch ex
            if ex.identifier == "MATLAB:structRefFromNonStruct" ||...
                    ex.identifier == "MATLAB:nonLogicalConditional"
                diffs(ind).missingFromObj2 = "Yes";
                fprintf('The property %s.%s was missing from one of the objects',...
                            prefix,props{i})
            else
                fprintf('There was an error while evaluating property %s.%s\n',...
                            prefix,props{i})
            end
        end
    end
    if nargout >= 1
        varargout{1} = diffs;
    end
end