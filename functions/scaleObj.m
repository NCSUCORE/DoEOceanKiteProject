function obj = scaleObj(obj,lengthScaleFactor,densityScaleFactor)
% function that uses the listed units to automatically scale up/down
p = properties(obj);
scaleUnitList = {'m','s','kg','rad','deg','N','Pa'}; % units that impact how to scale things

scaleFactors  = {...
    num2str(lengthScaleFactor),...
    num2str(sqrt(lengthScaleFactor)),...
    num2str(lengthScaleFactor^3),...
    '1',...
    '1',...
    num2str(lengthScaleFactor^3),...
    num2str(lengthScaleFactor)};

skipListNames = {'grav' ,'visc' ,'visc'};
% skipListVals  = [9.8    ,8.9e-4 ,1.81e-5];
skipUnits     = {'m/s^2','Pa'   ,'Pa'};

for ii = 1:length(p)
    unit = obj.(p{ii}).Unit;
    if ~isempty(unit) && ~skipCheck(p{ii},unit,skipListNames,skipUnits)
        for jj = 1:length(scaleUnitList)
            unit = strrep(unit, scaleUnitList{jj},scaleFactors{jj});
        end
        scaleFactor = eval(unit);
        obj.(p{ii}).Value = obj.(p{ii}).Value*scaleFactor;
        
    end
end
end
function rslt = skipCheck(name,unit,names,units)
rslt = false;
for ii = 1:length(names)
    if any(contains(names,lower(name))) && any(strcmp(units,unit))
        rslt = true;
        break
    end
end

end