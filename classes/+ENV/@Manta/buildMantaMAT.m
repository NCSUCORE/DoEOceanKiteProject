function [data,xBreak,yBreak,zBreak] = buildMantaMAT(obj,files)
% Sort the filenames alphanumerically
fNames = sort({files.name})';
% Note that this *should* get things in the proper order to just loop
% through and compile
for ii = 1:numel(fNames)
    % Construct the full file name
    fName = fullfile(files(ii).folder,fNames{ii});
    % Get the information on this file
    info = ncinfo(fName);
    % Get the names of the variables in the file
    vars = {info.Variables.Name};
    % Load those variables in
    for jj = 1:numel(vars)
        eval(sprintf('%s = ncread(''%s'',''%s'');',vars{jj},fName,vars{jj}));
    end
    % Find the name of the data that we just loaded
    dataVar = who('-regexp','water_[u,v,w]vel');
    if ii == 1
        % Preallocate data matrix with correct dimensions
        data = zeros([size(eval(dataVar{1})) 3 numel(files)/3]);
    end
    % Figure out which component we're dealing with
    componentName = regexp(dataVar,'[u,v,w]vel','match','once');
    switch componentName{1}
        case 'uvel'
            componentIndex = 1;
        case 'vvel'
            componentIndex = 2;
        case 'wvel'
            componentIndex = 3;
        otherwise
            error('Unknown velocity component')
    end
    % Figure out which time step we're looking at
    timeIndx = regexp(fNames{ii},'_t\d{3}_','match','once');
    timeIndx = str2double(timeIndx(3:end-1));
    data(:,:,:,componentIndex,timeIndx) = eval(dataVar{1});
end
% Convert x and y breakpoints to m, center them at zero
xBreak = 1000*(xindx-mean(xindx));
yBreak = 1000*(yindx-mean(yindx));
% Flip the order of the z breakpoints so that largest = surface
zBreak = -sort(depth);
end

