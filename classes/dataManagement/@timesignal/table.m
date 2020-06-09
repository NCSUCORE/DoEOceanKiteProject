function tb = table(obj)
%% Return data as table object, used to write to excel
data = [];
dims = size(obj.Data);
tDimMask = numel(obj.Time)==dims;

% Put time in the first column and reshape the others to rows
obj = obj.samplereshape(prod(dims(~tDimMask)));
data = [obj.Time(:) obj.Data];
% build column headers
[r,c] = ind2sub(size(obj.getdatasamples(1)),1:numel(obj.getdatasamples(1)));
heads{1} = 'Time';
for ii = 1:numel(r)
    heads{ii+1} = sprintf('(%d,%d)',r(ii),c(ii));
end
tb = array2table(data);
tb.Properties.VariableNames = heads;
end