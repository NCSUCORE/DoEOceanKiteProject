varNamesMTinputs = {'ARll','ARul','Spanll','Spanul','Prated','vf','TarB','MassF'};...
%     'Bmax','T1Brat','T2Arat',...
    
for i = 1:numel(varNamesMTinputs)
    eval(sprintf('varMT.%s = inputParam;',varNamesMTinputs{i}));
end

varMTinputs.ARll.min = 4;
varMTinputs.ARll.max = 8;
varMTinputs.ARll.default = 5;
varMTinputs.ARll.symbol = 'AR Lower Limit';
varMTinputs.ARll.description = 'AR Lower Limit';
varMTinputs.ARul.unit = '';

varMTinputs.ARul.min = 8;
varMTinputs.ARul.max = 25;
varMTinputs.ARul.default = 12;
varMTinputs.ARul.symbol = 'AR Upper Limit';
varMTinputs.ARul.description = 'AR Upper Limit';
varMTinputs.ARul.unit = '';

varMTinputs.Spanll.min = 4;
varMTinputs.Spanll.max = 10;
varMTinputs.Spanll.default = 8;
varMTinputs.Spanll.symbol = 'Span Lower Limit';
varMTinputs.Spanll.description = 'Span Lower Limit';
varMTinputs.Spanul.unit = 'm';

varMTinputs.Spanul.min = 6;
varMTinputs.Spanul.max = 15;
varMTinputs.Spanul.default = 10;
varMTinputs.Spanul.symbol = 'Span Upper Limit';
varMTinputs.Spanul.description = 'Span Upper Limit';
varMTinputs.Spanul.unit = 'm';

varMTinputs.Prated.min = 0.5;
varMTinputs.Prated.max = 250.0;
varMTinputs.Prated.default = 100.0;
varMTinputs.Prated.symbol = 'Prated';
varMTinputs.Prated.description = 'Rated Power';
varMTinputs.Prated.unit = 'kW';


varMTinputs.vf.min = 0.2;
varMTinputs.vf.max = 5;
varMTinputs.vf.default = 1.5;
varMTinputs.vf.symbol = 'Flow velocity';
varMTinputs.vf.description = 'Flow velocity';
varMTinputs.vf.unit = 'm/s';

varMTinputs.TarB.min = 0.5;
varMTinputs.TarB.max = 1.0;
varMTinputs.TarB.default = 0.99;
varMTinputs.TarB.symbol = 'Target Buoyancy';
varMTinputs.TarB.description = 'Target Buoyancy';
varMTinputs.TarB.unit = '';

varMTinputs.MassF.min = 0.3;
varMTinputs.MassF.max = 0.8;
varMTinputs.MassF.default = 0.4;
varMTinputs.MassF.symbol = 'Mass Fraction of Wing';
varMTinputs.MassF.description = 'Mass Fraction of Wing';
varMTinputs.MassF.unit = '';


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