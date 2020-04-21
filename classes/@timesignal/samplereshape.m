function obj = samplereshape(obj,dims)
nt = numel(obj.Time);
if obj.IsTimeFirst
    newDims = [nt dims(:)'];
else
    newDims = [dims(:)' nt];
end
newData = reshape(obj.Data,newDims);
if ismatrix(newData) && size(newData,2) == numel(obj.Time)
    newData = newData';
end
obj.Data = newData;
end