function compareObjects(obj1,obj2,varargin)
%uses the properties of object 1
%obj1 is the first argument obj2 is the second in the structure
%***varargin is used recursively. There is no need to use it when calling
%       compare objects***
    if isempty(varargin)
        prefix = class(obj1);
    else
        prefix = genvarname(varargin{1});
    end
    try
        if isempty(inputname(1))
            name1=genvarname(varargin{2});
            name2=genvarname(varargin{3});
        else
            name1=genvarname(inputname(1));
            name2=genvarname(inputname(2));
        end
    catch
        name1="obj1";
        name2="obj2";
    end
    props = properties(obj1);
    props2 = properties(obj2);
    for j = 1:length(props) %This really ugly code appends unique entries to the end of the property list
        ii=1;
        while ii <= length(props2)
            if isequal(props2{ii},props{j})
                props2(ii)=[];  
                ii=length(props2)+2;              
            end
            ii=ii+1;
        end
    end
    props(end+1:end+length(props2)) = props2;
    anyDiffs = false;
    for i = 1:length(props)
        try
            if isprop(obj1.(props{i}),'Value') && isprop(obj2.(props{i}),'Value')
                val1 = obj1.(props{i}).Value;
                val2 = obj2.(props{i}).Value;
                if ~isequal(val1,val2)
                    anyDiffs=true;
                    prefix = strrep(prefix,'0x2E','.');
                    if max(size(val1))==1 || max(size(val2))==1
                        fprintf(['For the property %s.%s, %s had a value of'...
                                ' %6.3f, and %s had a value of %6.3f.\n'],...
                                prefix,props{i},name1,val1,name2,val2)
                    else
                        if ~isempty(inputname(1)) 
                            fprintf('for the property %s.%s, %s had a value of <a href="matlab:disp([newline '' %s.%s.Value='']);disp(%s.%s.Value)">value</a> and %s had a value of <a href="matlab:disp([newline '' %s.%s.Value='']);disp(%s.%s.Value)">value</a>\n',...%fprintf([strrep(%s.%s,class(eval(%s)),%s) ''='' eval(strrep(%s.%s,class(eval(%s)),%s))
                                    prefix,props{i},name1,name1,props{i},name1,props{i},name2,name2,props{i},name2,props{i});%prefix,props{i},name1,name1)
                        else
                            fprintf(['For the property %s.%s, %s and %s'...
                                     ' had different, non-singular values\n'],...
                                     prefix,props{i},name1,name2);
                        end
                    end
                end
            else
                compareObjects(obj1.(props{i}),obj2.(props{i}),[prefix '.' props{i}],name1,name2);
            end
        catch ex
            if ex.identifier == "MATLAB:structRefFromNonStruct" ||...
                    ex.identifier == "MATLAB:nonLogicalConditional" ||...
                    ex.identifier == "MATLAB:noSuchMethodOrField"
                fprintf('There was an error evaluating property %s.%s\n',...
                            prefix,props{i})
            else
                fprintf('There was an error while evaluating property %s.%s\n',...
                            prefix,props{i})
            end
        end
    end
    %Checks if you are in the initial call to the function
    if length(dbstack)==1 && ~anyDiffs
        fprintf("The evaluated properties of the objects are identical.\n\n")
    end
end
