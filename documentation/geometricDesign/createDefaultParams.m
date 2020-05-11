varNames = {'eta','vw','alphaw',...
    'bw','CLa0w','CD0w','gammaw','eLw','eDw',...
    'bh','ARh','CLa0h','CD0h','gammah','eLh','eDh',...
    'rf','CD0f','CDaf'};
for ii = 1:numel(varNames)
    eval(sprintf('p.%s = sliderParam;',varNames{ii}));
end

% eta
% vw
% alpha
% bw
% CLa0w
% CD0w
% gammaw
% eLw
% eDw
% bh
% ARh
% CLa0h
% CD0h
% gammah
% eLh
% eDh
% gammah
% rf
% CD0f
% CDaf

p.eta.min = 0;
p.eta.max = 1;
p.eta.default = 0.3;
p.eta.symbol = 'eta';
p.eta.description = 'Lumped Lyod efficiency';
p.eta.unit = '-';

p.vw.min = 0.1;
p.vw.max = 3;
p.vw.default = 0.5;
p.vw.symbol = 'vw';
p.vw.description = 'Wind speed';
p.vw.unit = 'm/s';

p.alphaw.min = 0;
p.alphaw.max = 20;
p.alphaw.default = 7;
p.alphaw.symbol = 'alphaw';
p.alphaw.description = 'Angle of attack';
p.alphaw.unit = 'deg';

p.bw.min = 7;
p.bw.max = 11;
p.bw.default = 8;
p.bw.symbol = 'bw';
p.bw.description = 'Wing span';
p.bw.unit = 'm';

p.CLa0w.min = 0;
p.CLa0w.max = 0.5;
p.CLa0w.default = 0.25;
p.CLa0w.symbol = 'CLa0w';
p.CLa0w.description = 'Wing lift coeff at zero AoA';
p.CLa0w.unit = '-';

p.CD0w.min = 0;
p.CD0w.max = 0.3;
p.CD0w.default = 0.015;
p.CD0w.symbol = 'CD0w';
p.CD0w.description = 'Wing drag coeff at zero lift';
p.CD0w.unit = '-';

p.gammaw.min = 0.7;
p.gammaw.max = 1;
p.gammaw.default = 1;
p.gammaw.symbol = 'gammaw';
p.gammaw.description = 'Wing airfoil lift curve multiplier';
p.gammaw.unit = '-';

p.eLw.min = 0.8;
p.eLw.max = 1;
p.eLw.default = 0.9;
p.eLw.symbol = 'eLw';
p.eLw.description = 'Wing Oswald lift efficiency factor';
p.eLw.unit = '-';

p.eDw.min = 0.8;
p.eDw.max = 1;
p.eDw.default = 0.9;
p.eDw.symbol = 'eDw';
p.eDw.description = 'Wing Oswald drag efficiency factor';
p.eDw.unit = '-';

p.bh.min = 0.5;
p.bh.max = 5;
p.bh.default = 4.5;
p.bh.symbol = 'bh';
p.bh.description = 'H. stab. span';
p.bh.unit = 'm';

p.ARh.min = 1;
p.ARh.max = 10;
p.ARh.default = 5;
p.ARh.symbol = 'ARh';
p.ARh.description = 'H. stab. aspect ratio';
p.ARh.unit = '-';

p.CLa0h.min = -0.25;
p.CLa0h.max = 0.25;
p.CLa0h.default = 0;
p.CLa0h.symbol = 'CLa0h';
p.CLa0h.description = 'H. stab. lift coeff at zero AoA';
p.CLa0h.unit = '-';

p.CD0h.min = 0;
p.CD0h.max = 0.3;
p.CD0h.default = 0.015;
p.CD0h.symbol = 'CD0h';
p.CD0h.description = 'H. stab. drag coeff at zero lift';
p.CD0h.unit = '-';

p.gammah.min = 0.7;
p.gammah.max = 1;
p.gammah.default = 1;
p.gammah.symbol = 'gammah';
p.gammah.description = 'H. stab. airfoil lift curve multiplier';
p.gammah.unit = '-';

p.eLh.min = 0.8;
p.eLh.max = 1;
p.eLh.default = 0.9;
p.eLh.symbol = 'eLh';
p.eLh.description = 'H. stab. lift Oswald efficiency factor';
p.eLh.unit  = '-';

p.eDh.min = 0.8;
p.eDh.max = 1;
p.eDh.default = 0.9;
p.eDh.symbol = 'eDh';
p.eDh.description = 'H. stab. drag Oswald efficiency factor';
p.eDh.unit  = '-';

p.rf.min = 0.1;
p.rf.max = 5;
p.rf.default = 0.75;
p.rf.symbol = 'rf';
p.rf.description = 'Fuselage radius';
p.rf.unit = 'm';

p.CD0f.min = 0.0001;
p.CD0f.max = 0.5;
p.CD0f.default = 0.1;
p.CD0f.symbol = 'CD0f';
p.CD0f.description = 'Fuselage drag coeff at zero AoA';
p.CD0f.unit = '-';

p.CDaf.min = 0;
p.CDaf.max = 1;
p.CDaf.default = 0;
p.CDaf.symbol = 'CDaf';
p.CDaf.description = 'Fuselage drag coeff AoA quadratic sensitivity coefficient';
p.CDaf.unit = '-';