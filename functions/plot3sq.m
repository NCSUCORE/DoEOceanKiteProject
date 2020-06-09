function plot3sq(varargin)
    for i=1:nargin
        if isnumeric(varargin{i}) && ndims(varargin{i})>2 && min(size(varargin{i}))==1 %#ok<ISMAT>
            varargin{i}=squeeze(varargin{i});
        end
    end
    plot3(varargin{:})
end