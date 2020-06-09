% Function to save files within parfor loop
% For a justification of this function, see:
% https://www.mathworks.com/matlabcentral/answers/135285-how-do-i-use-save-with-a-parfor-loop-using-parallel-computing-toolbox
function parsave(fname,x)
callerVarName = inputname(2);
eval(sprintf('%s = x;',callerVarName));
save(fname, callerVarName);
end