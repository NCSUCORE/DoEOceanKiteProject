varNamesSWDT = {'WingDef','Fy','AsR','WSpan','AFT','ChrdL', 'Lw'};...
%     'Bmax','T1Brat','T2Arat',...
    
for i = 1:numel(varNamesSWDT)
    eval(sprintf('varSWDT.%s = inputParam;',varNamesSWDT{i}));
end

varSWDT.WingDef.min = 0;
varSWDT.WingDef.max = 15;
varSWDT.WingDef.default = 5;
varSWDT.WingDef.symbol = 'Wing Deflection';
varSWDT.WingDef.description = 'Wing Deflection';
varSWDT.WingDef.unit = '%';

varSWDT.Fy.min = 0;
varSWDT.Fy.max = 10^10;
varSWDT.Fy.default = 5.5045*(10^5)/2;
varSWDT.Fy.symbol = 'Fy';
varSWDT.Fy.description = 'Load on one wing in the Y direction';
varSWDT.Fy.unit = 'N';

%Default is Aluminum
varSWDT.AsR.min = 0;
varSWDT.AsR.max = 20;
varSWDT.AsR.default = 6;
varSWDT.AsR.symbol = 'Aspect Ratio';
varSWDT.AsR.description = 'Aspect Ratio of Wing Airfoil';
varSWDT.AsR.unit = 'm';

varSWDT.WSpan.min = 0;
varSWDT.WSpan.max = 20;
varSWDT.WSpan.default = 7;
varSWDT.WSpan.symbol = 'Wing Span';
varSWDT.WSpan.description = 'Span of Wing Airfoil';
varSWDT.WSpan.unit = 'm';


varSWDT.AFT.min = 2;
varSWDT.AFT.max = 20;
varSWDT.AFT.default = 12;
varSWDT.AFT.symbol = 'Airfoil Thickness';
varSWDT.AFT.description = 'Airfoil Thickness';
varSWDT.AFT.unit = '%';

varSWDT.ChrdL.min = 0;
varSWDT.ChrdL.max = 20;
varSWDT.ChrdL.default = varSWDT.WSpan.default/varSWDT.AsR.default;
varSWDT.ChrdL.symbol = 'Chord Length';
varSWDT.ChrdL.description = 'Chord Length';
varSWDT.ChrdL.unit = 'm';

varSWDT.Lw.min = 0;
varSWDT.Lw.max = 20;
varSWDT.Lw.default = 5;
varSWDT.Lw.symbol = 'Length of Wing';
varSWDT.Lw.description = 'Lenght of Wing';
varSWDT.Lw.unit = 'm';


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