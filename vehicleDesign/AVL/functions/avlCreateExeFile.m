function avlCreateExeFile(exeFileName,inputFileName,runFileName)
% Create temporary file to hold commands typed into exe
fileID_exe = fopen(exeFileName,'w');

% load input file
fprintf(fileID_exe,'load %s\n',inputFileName);

% load run file
fprintf(fileID_exe,'case %s\n',runFileName);

% load mass file
fprintf(fileID_exe,'mass dsgnMassFile.mass\n');

% type mset for whatever reason
fprintf(fileID_exe,'mset\n');

% type 0 to apply mass file to all run cases
fprintf(fileID_exe,'0\n');

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

% Close the file
fclose(fileID_exe);

end