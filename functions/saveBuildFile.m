function varargout = saveBuildFile(object,BSfileName,varargin)

% this script stores the object parameters into a .mat file which has
% the same name as the script thats being used to create the file
% INPUTS
% object: object you which to save passed as a string
% BSfilename, name of the script you are using to build the .mat file
% I recommend using typing the command 'mfilename' in this space
% optional inputs
% use these if you wish to save the variant associated with the object in the .mat
% eg. saveBuildFile('vhcl',mfilename,'variant','VEHICLE');

p = inputParser;
addRequired(p,'object',@ischar);
addRequired(p,'BSfileName',@ischar);
addParameter(p,'variant','',@(x) ischar(x) || isstring(x));

parse(p,object,BSfileName,varargin{:});

[currentMfileLoc,currentMfileName,~] = fileparts(which(p.Results.BSfileName));

if endsWith(currentMfileName,'_bs')
    saveFileName = strcat('\',erase(currentMfileName,'_bs'),'.mat');
    txtFileName = strcat('\',erase(currentMfileName,'_bs'),'.txt');
else
    saveFileName = currentMfileName;
end

props = properties(p.Results.object);
checkInit = false(size(props));
for ii = 1:length(props)
    checkInit(ii) = startsWith(props{ii},'init','IgnoreCase',true);
end
initProps = props(checkInit);

if isempty(initProps)
    emptyCheck = true;
else
    emptyCheck = false(size(initProps));
    for ii = 1:length(initProps)
        emptyCheck(ii) = isempty(p.Results.object.(initProps{ii}).Value);
    end
end

eval([p.Results.object ' =  evalin(''caller'',p.Results.object);']);


if all(emptyCheck)
    saveFile = strcat(currentMfileLoc,saveFileName);
    txtFile = strcat(currentMfileLoc,txtFileName);
    if isempty(p.UsingDefaults)
        if length(p.Results.variant) == 1
            % Check if the variant specifier exists in the caller workspace
            if ~evalin( 'base', sprintf('exist(''%s'',''var'') == 1;',p.Results.variant ))
                error('Variant specifier %s does not exist in workspace.\nPlease specify the relevant variant',p.Results.variant );
            end
            
            eval([p.Results.variant ' =  evalin(''caller'',p.Results.variant);']);
            save(saveFile,p.Results.object,p.Results.variant);
            saveClassTxt(evalin('caller',p.Results.object),txtFile,p.Results.object);
        else
            save(saveFile,p.Results.object);
            for i = 1: length(p.Results.variant)
                eval([char(p.Results.variant(i)) ' =  evalin(''caller'',p.Results.variant(i));']);
                 save(saveFile,char(p.Results.variant(i)),'-append');
            end
                
                saveClassTxt(evalin('caller',p.Results.object),txtFile,p.Results.object);
        end
    else
        save(saveFile,p.Results.object);
        saveClassTxt(evalin('caller',p.Results.object),txtFile,p.Results.object);
    end
else
    error('Please do not specify initial conditions in build script')
end

if nargout > 0
    varargout{1} = saveFile;
end

end
