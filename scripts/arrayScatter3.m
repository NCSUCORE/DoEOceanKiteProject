function arrayScatter3(arr, varargin)
%Uses Scatter 3 to plot an array with at least 1 dimention with length 3
%Will not plot if array has more than 2 non singular dimentions
%Inputs:
%   arr - the array to be plotted
%   varargin - will be passed directly into the varargin of scatter3
    if any(ismember(size(arr),3))
        arr=squeeze(arr);
        if length(size(arr))~=2
            error("Array must have no more than 2 non singular dimentions")
        elseif size(arr,2)==3 && size(arr,1) ~= 3
             arr=arr';
        end
        if isempty(varargin)
            scatter3(arr(1,:),arr(2,:),arr(3,:))
        else
            scatter3(arr(1,:),arr(2,:),arr(3,:),varargin{:});
        end
    else
        error("Array must have at least 1 dimention whose length is 3")
    end        
end