varNamesSFOToutputs = {'AoAOpt'};...
%     'Bmax','T1Brat','T2Arat',...
    
for i = 1:numel(varNamesSFOToutputs)
    eval(sprintf('varSFOT.%s = inputParam;',varNamesSFOToutputs{i}));
end

varSFOToutputs.AoAOpt.min = -13.0;
varSFOToutputs.AoAOpt.max = 13.0;
varSFOToutputs.AoAOpt.default = 5;
varSFOToutputs.AoAOpt.symbol = 'Optimal Angle of Attack';
varSFOToutputs.AoAOpt.description = 'Optimal Angle of Attack';
varSFOToutputs.AoAOpt.unit = '';


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