%QoL function. When you get "Data cannot have more than 2 dimensions." just
%add sq to the end of plot and this will squeeze whichever inputs are >3
%dimentions and have at least 1 singular dimension
function plotsq(varargin)
    for i=1:nargin
        if isnumeric(varargin{i}) && ndims(varargin{i})>2 && min(size(varargin{i}))==1 %#ok<ISMAT>
            varargin{i}=squeeze(varargin{i});
        end
    end
    plot(varargin{:})
end