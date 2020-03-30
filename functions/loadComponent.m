function [varargout] = loadComponent(name,varargin)
%%
% LOADCOMPONENT(Name) attempts to find and load the single variable stored 
%   in Name.mat.  User can specify variable with or without .mat extension.
%
% LOADCOMPONENT(Name,Subpath1,...,SubpathN) attempts to load the file
%   Name.mat stored in
%   basePath/compositions/Subpath1/.../SubpathN/library/Name/ where
%   basePath is the directory containing OCTProject.prj.
%
% x = LOADCOMPONENT(__) attempts to load the single variable stored in
%   Name.mat, if successful, it returns it as x.

%% 
p = inputParser;
addRequired(p,'name',@ischar);
parse(p,name);

% if user did not include .mat file extension, append it
if ~strcmpi(p.Results.name(end-3:end),'.mat')
    fName = [p.Results.name '.mat'];
else
    fName = p.Results.name;
end

if nargin>1 % If the user provides additional path specifications, go look there
    % Path to .prj file
    fPath = fileparts(which('OCTProject.prj'));
    % Append additional directories
    fPath = fullfile(...
        fPath,...
        'compositions',... % compositions folder
        varargin{:},... % whatever the user specified
        'library',... % library within that
        strrep(fName,'.mat',''),... % folder within library
        fName); % .mat file name
    if nargout == 0 % If they didn't specify output variable name, use the variable name saved in the .mat file
        evalin('caller',sprintf('load(''%s'');',fPath)); % load in caller workspace
        return % return
    elseif nargout > 0 % If they asked for outputs
        varName = who(matfile(fPath)); % Get the name of the variable stored in the .mat file
        if numel(varName)>1 % if there's more than 1 variable stored there
            error('.mat file contains multiple variables, not sure which one you want') % throw an error
        end
        load(fPath); % otherwise load it
        eval(sprintf('varargout{1} = %s;',varName{1})); % Write the variable to the output
        if nargout>1
            varargout(2:nargout)={[]}; % Set extra outputs to empty matrices
            warning('Ignoring extra outputs, setting them to [].') % Warn the user
        end
        return
    end
    
else % User did not provide full path specification
    
    % Attempt to load it (filename must be unique)
    fPath = which(fName,'-all'); % Search for the file
    if numel(fPath)>1 % If the filename is not unique
        % Tell the user that idk which one to load, because there are
        % multiple, provide path to each non-unique file
        str = sprintf('%s is not a unique filename (IDK which one to load).\nFiles of that name were found at:\n',fName);
        str = [str sprintf('%s\n',fPath{:})];
        str = [str sprintf('Please specify additional arguments to select a specific .mat file\n')];
        error(str)
    elseif numel(fPath)==0
        error(".mat file not found")
    else % File name is unique
        if nargout == 0 % If they didn't specify output variable name, use the variable name saved in the .mat file
            evalin('caller',sprintf('load(''%s'');',fPath{1})); % load in caller workspace
            return % return
        elseif nargout > 0 % If they asked for outputs
            varName = who(matfile(fPath{1})); % Get the name of the variable stored in the .mat file
            if numel(varName)>1 % if there's more than 1 variable stored there
                error('.mat file contains multiple variables, not sure which one you want') % throw an error
            end
            load(fPath{1}); % otherwise load it
            eval(sprintf('varargout{1} = %s;',varName{1})); % Write the variable to the output
            if nargout>1
                varargout(2:nargout)={[]}; % Set extra outputs to empty matrices
                warning('Ignoring extra outputs, setting them to [].') % Warn the user
            end
            return
        end
        
    end
end


end