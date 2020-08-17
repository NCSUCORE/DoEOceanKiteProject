varNamesMToutputs = {'Pow','Perf','AR','Span','D','L','KiteM','AoA'};...
%     'Bmax','T1Brat','T2Arat',...
    
for i = 1:numel(varNamesMToutputs)
    eval(sprintf('varMT.%s = inputParam;',varNamesMToutputs{i}));
end

varMToutputs.Pow.min = 0;
varMToutputs.Pow.max = 10^10;
varMToutputs.Pow.default = 0;
varMToutputs.Pow.symbol = 'Maximum Power Generated';
varMToutputs.Pow.description = 'Maximum Power Generated';
varMToutputs.Pow.unit = 'kW';

varMToutputs.Perf.min = 0;
varMToutputs.Perf.max = 10^10;
varMToutputs.Perf.default = 0;
varMToutputs.Perf.symbol = 'Maximum Performance';
varMToutputs.Perf.description = 'Maximum Performance';
varMToutputs.Perf.unit = '';

varMToutputs.AR.min = 0;
varMToutputs.AR.max = 20;
varMToutputs.AR.default = 6;
varMToutputs.AR.symbol = 'Aspect Ratio';
varMToutputs.AR.description = 'Aspect Ratio of Wing Airfoil';
varMToutputs.AR.unit = '';

varMToutputs.Span.min = 0;
varMToutputs.Span.max = 20;
varMToutputs.Span.default = 7;
varMToutputs.Span.symbol = 'Wing Span';
varMToutputs.Span.description = 'Span of Wing Airfoil';
varMToutputs.Span.unit = 'm';


varMToutputs.D.min = 0.001;
varMToutputs.D.max = 20;
varMToutputs.D.default = 12;
varMToutputs.D.symbol = 'Diameter of Fuselage';
varMToutputs.D.description = 'Diameter of Fuselage';
varMToutputs.D.unit = 'm';

varMToutputs.L.min = 0.001;
varMToutputs.L.max = 20;
varMToutputs.L.default = 12;
varMToutputs.L.symbol = 'Length of Fuselage';
varMToutputs.L.description = 'Length of Fuselage';
varMToutputs.L.unit = 'm';

varMToutputs.KiteM.min = 5;
varMToutputs.KiteM.max = 10^10;
varMToutputs.KiteM.default = 1000;
varMToutputs.KiteM.symbol = 'Mass of Kite';
varMToutputs.KiteM.description = 'Mass of Kite';
varMToutputs.KiteM.unit = 'kg';

varMToutputs.AoA.min =-13.0;
varMToutputs.AoA.max = 13.0;
varMToutputs.AoA.default = 5;
varMToutputs.AoA.symbol = 'Angle of Attack';
varMToutputs.AoA.description = 'Angle of Attack';
varMToutputs.AoA.unit = 'degrees';

% varSDT.ChrdL.min = 0;
% varSDT.ChrdL.max = 20;
% varSDT.ChrdL.default = varSDT.Span.default/varSDT.AR.default;
% varSDT.ChrdL.symbol = 'Chord Length';
% varSDT.ChrdL.description = 'Chord Length';
% varSDT.ChrdL.unit = 'm';
% 
% varSDT.Lw.min = 0;
% varSDT.Lw.max = 20;
% varSDT.Lw.default = 5;
% varSDT.Lw.symbol = 'Length of Wing';
% varSDT.Lw.description = 'Lenght of Wing';
% varSDT.Lw.unit = 'm';


% varSDT.Bmax.min = 0;
% varSDT.Bmax.max = 100;
% varSDT.Bmax.default = 0.35;
% varSDT.Bmax.symbol = 'Bmax';
% varSDT.Bmax.description = 'Maximum value of B as percentage of chord length';
% varSDT.Bmax.unit = '%';
% 
% varSDT.T1Brat.min = 0;
% varSDT.T1Brat.max = 100;
% varSDT.T1Brat.default = 0.2;
% varSDT.T1Brat.symbol = 'T1/Bmax';
% varSDT.T1Brat.description = ...
%     'Maximum value of T1 as percentage of Maximum length of B';
% varSDT.T1Brat.unit = '%';
% 
% varSDT.T2Arat.min = 0;
% varSDT.T2Arat.max = 100;
% varSDT.T2Arat.default = 0.2;
% varSDT.T2Arat.symbol = 'T2/Amax';
% varSDT.T2Arat.description = ...
%     'Maximum value of T2 as percentage of Maximum length of A';
% varSDT.T2Brat.unit = '%';