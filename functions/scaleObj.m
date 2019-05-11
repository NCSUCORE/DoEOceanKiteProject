function obj = scaleObj(obj,val)
% function that uses the listed units to automatically scale the quantity
p = properties(obj);
unitList = '_mPs|_m|_radPs|_degPs|_rad|_deg|_s|_mPsrad|_mPsdeg|_Ps|_mPsdeg|_mPrad|_mPdeg|_mPrads3|_mPs2|_Ps3|_na';
for ii = 1:length(p)
    unit = regexp(p{ii},unitList,'match');
    if ~isempty(unit)
        switch unit{1}
            case {'_rad','_deg','_mPs2','_na'}
                scaleFactor = 1;
            case {'_s'}
                scaleFactor = sqrt(val);
            case {'_radPs','_degPs','_Ps','_mPrads3'}
                scaleFactor = 1/sqrt(val);
            case {'_m','_mPrad','_mPdeg'}
                scaleFactor = val;
            case {'_mPs','_mPsrad','_mPsdeg'}
                scaleFactor = val/sqrt(val);
            case {'_Ps3'}
                scaleFactor = 1/(val^(3.2));
            otherwise
                % Don't know how to scale this
                scaleFactor = 1;
        end
        obj.(p{ii}) = obj.(p{ii})*scaleFactor;
    end
end
end
