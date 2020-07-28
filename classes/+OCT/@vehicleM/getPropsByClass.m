% Function to get properties according to their class
% May be able to vectorize this somehow
function val = getPropsByClass(obj,className)
props = properties(obj);
val = {};
for ii = 1:length(props)
    if isa(obj.(props{ii}),className)
        val{end+1} = props{ii};
    end
end
end