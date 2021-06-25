function obj = reSampleDataUsingTime(objIn,tStart,tEnd)
%Find field names
names = fieldnames(objIn);
% Initialize output object
obj = struct;

for i = 1:numel(names)
    %Resample each field using time
    if isprop(objIn.(names{i}), 'Time')  ~= 1
        obj.(names{i}) = objIn.(names{i});
        continue
    end
    obj.(names{i}) = objIn.(names{i}).getsampleusingtime(tStart,tEnd);
    %Initialize each time series to tStart = 0
    obj.(names{i}).Time = obj.(names{i}).Time-tStart;
end

end