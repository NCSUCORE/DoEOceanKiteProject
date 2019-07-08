maskHandle = Simulink.Mask.get(gcb);
popup = maskHandle.getParameter('pathGeometryFcn');
basePath = what('pathGeometryFunctions');
files = dir(fullfile(basePath.path,'*.m'));
if numel(intersect(popup.TypeOptions,{files(:).name}))<numel({files(:).name})
    currentValue = popup.Value;
    popup.TypeOptions = strrep({files(:).name},'.m','')';
    if any(strcmp(popup.TypeOptions,currentValue))
        value = popup.TypeOptions(strcmp(popup.TypeOptions,currentValue));
        popup.Value = value{1};
    end
end
 