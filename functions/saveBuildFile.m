function saveBuildFile(object,objectName,BSfileName,varargin)

% this script stores the object parameters of into a .mat file which has
% the same name as the script thats being used to create the file
% INPUTS
% object: object you which to save
% objectName: the variable you wish use to save the object as eg. x = 1. in
% here 'x' would be the objectName
% BSfilename, name of the script you are using to build the .mat file
% I recomment using typing the command 'mfilename' in this space
% optional inputs
% use these if you wish to save the variant associated with the object in the .mat
% eg. variantVariableName = 'VEHICLE',variantVariable = VEHICLE


p = inputParser;
addRequired(p,'object',@isobject);
addRequired(p,'objectName',@ischar);
addRequired(p,'BSfileName',@ischar);
addParameter(p,'variantVariableName','',@ischar);
addParameter(p,'variantVariable','',@ischar);

parse(p,object,objectName,BSfileName,varargin{:});

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

eval([p.Results.objectName ' =  p.Results.object;']);


if all(emptyCheck)
    if isempty(p.UsingDefaults)
        eval([p.Results.variantVariableName, ' = ''', p.Results.variantVariable,''';']);
        save(strcat(currentMfileLoc,saveFileName),p.Results.objectName,p.Results.variantVariableName);
    else
        save(strcat(currentMfileLoc,saveFileName),p.Results.objectName);
    end
else
    error('Please do not specify initial conditions in build script')
end


end
