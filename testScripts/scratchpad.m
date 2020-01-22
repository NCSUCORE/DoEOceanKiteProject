props = fieldnames(tsc)

for ii = 3:5
    figure
    tsc.(props{ii}).diff.plot
    
end