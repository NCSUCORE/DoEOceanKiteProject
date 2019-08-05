function saveBuildFile(object,BSfileName,varargin)

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
addParameter(p,'variant','',@ischar);

parse(p,object,BSfileName,varargin{:});

[currentMfileLoc,currentMfileName,~] = fileparts(which(p.Results.BSfileName));

if endsWith(currentMfileName,'_bs')
    saveFileName = strcat('\',erase(currentMfileName,'_bs'),'.mat');
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
    if isempty(p.UsingDefaults)
        eval([p.Results.variant ' =  evalin(''caller'',p.Results.variant);']);
        save(strcat(currentMfileLoc,saveFileName),p.Results.object,p.Results.variant);
    else
        save(strcat(currentMfileLoc,saveFileName),p.Results.object);
    end
else
    error('Please do not specify initial conditions in build script')
end


end
