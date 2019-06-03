function result = avlRunFile(obj)
% Function to programmatically run an AVL .run file

% Create temporary file to hold commands typed into exe
fileID_exe = fopen(obj.exe_file_name,'w');

% load input file
fprintf(fileID_exe,'load %s\n',obj.input_file_name);

% load run file
fprintf(fileID_exe,'case %s\n',obj.run_file_name);

% enter oper menu
fprintf(fileID_exe,'oper\n');

% enter options menu
fprintf(fileID_exe,'O\n');

% Enter print menu
fprintf(fileID_exe,'P\n');

% Change default output to screen options
fprintf(fileID_exe,'T F T F\n');

% Back out to oper menu
fprintf(fileID_exe,'\n');

% run case
fprintf(fileID_exe,'xx\n');

% exit oper menu
fprintf(fileID_exe,'\n');

% quit avl
fprintf(fileID_exe,'quit\n');

fclose(fileID_exe);

% Run AVL
cmd_str = strcat('avl.exe','<',obj.exe_file_name);
[~,result] = system(cmd_str);


end