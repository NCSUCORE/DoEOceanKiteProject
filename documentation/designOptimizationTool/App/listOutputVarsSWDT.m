varNamesSWDToutputs = {'SkinT','Spar1T','Spar2T','Spar3T'};...
%     'Bmax','T1Brat','T2Arat',...
    
for i = 1:numel(varNamesSWDToutputs)
    eval(sprintf('varSWDT.%s = inputParam;',varNamesSWDToutputs{i}));
end

varSWDToutputs.SkinT.min = 0.0;
varSWDToutputs.SkinT.max = 1.0;
varSWDToutputs.SkinT.default = 0.15;
varSWDToutputs.SkinT.symbol = 'Skin Thickness';
varSWDToutputs.SkinT.description = 'Skin Thickness';
varSWDToutputs.SkinT.unit = '';


varSWDToutputs.Spar1T.min = 0;
varSWDToutputs.Spar1T.max = 1.0;
varSWDToutputs.Spar1T.default = 0.08
varSWDToutputs.Spar1T.symbol = 'Spar 1 Thickness';
varSWDToutputs.Spar1T.description = 'Spar 1 Thickness';
varSWDToutputs.Spar1T.unit = '';

varSWDToutputs.Spar2T.min = 0;
varSWDToutputs.Spar2T.max = 1.0;
varSWDToutputs.Spar2T.default = 0.08;
varSWDToutputs.Spar2T.symbol = 'Spar 2 Thickness';
varSWDToutputs.Spar2T.description = 'Spar 2 Thickness';
varSWDToutputs.Spar2T.unit = '';


varSWDToutputs.Spar3T.min = 0;
varSWDToutputs.Spar3T.max = 1.0;
varSWDToutputs.Spar3T.default = 0.08;
varSWDToutputs.Spar3T.symbol = 'Spar 3 Thickness';
varSWDToutputs.Spar3T.description = 'Spar 3 Thickness';
varSWDToutputs.Spar3T.unit = '';
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