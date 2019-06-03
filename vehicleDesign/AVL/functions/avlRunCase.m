function avlRunCase(obj,varargin)

p = inputParser;
addParameter(p,'InputFileName',obj.input_file_name,@ischar);
parse(p,varargin{:})

prevPath = cd;
basePath = fileparts(which('avl.exe'));
cd(basePath)
inputFilePath = fileparts(which(obj.input_file_name));

% Create temporary file to hold commands typed into exe
fileID_exe = fopen(obj.exe_file_name,'w');

% load input file
fprintf(fileID_exe,'load %s\n',obj.input_file_name);

% load run file
fprintf(fileID_exe,'case %s\n',obj.run_file_name);

% Find all the run case numbers in the run file
data = fileread(obj.run_file_name);
runNumbers = regexp(regexp(data,'Run case  \d*:','match'),'\d*','Match');
runNumbers = str2double([runNumbers{:}]);

% for ii = 1:length(runNumbers)
    % enter oper menu
    fprintf(fileID_exe,'oper\n');
    
    % Set the case number
%     fprintf(fileID_exe,'%d\n',runNumbers(ii));
    
    % run case
    fprintf(fileID_exe,'xx\n');
    
%     % get total force output
%     fprintf(fileID_exe,'ft\n');
%     
%     % enter file name
%     fprintf(fileID_exe,'%s\n',[obj.result_file_name '_' num2str(runNumbers(ii))]);
% end

% exit oper menu
fprintf(fileID_exe,'\n');

% quit avl
fprintf(fileID_exe,'quit\n');

fclose(fileID_exe);
 
% Run AVL
cmd_str = strcat('avl.exe','<',obj.exe_file_name);
[~,result] = system(cmd_str);

% Save the results to a file
fid = fopen([obj.result_file_name sprintf('_%dTo%d',runNumbers(1),runNumbers(end))],'w');
fprintf(fid,result);
fclose(fid);

fclose('all');
delete(obj.exe_file_name);

% cd(prevPath);

end