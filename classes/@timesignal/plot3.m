% Plot 3D vector as a trace in space
function h = plot3(obj,varargin)
nt = numel(obj.Time);
sz = size(obj.getsamples(1).Data);
switch find(sz==3)
    case 1 % First dimension is 3
        indX={1,1,1:nt};
        indY={2,1,1:nt};
        indZ={3,1,1:nt};
    case 2 % Second dimension is 3
        indX={1,1,1:nt};
        indY={1,2,1:nt};
        indZ={1,3,1:nt};
    otherwise
        error('Incorrect data dimensions')
end
h = plot3(...
    squeeze(obj.Data(indX{:})),...
    squeeze(obj.Data(indY{:})),...
    squeeze(obj.Data(indZ{:})),varargin{:});
end