varNamesSFDT = {'x1','x2','xW','Hstab_c','fos', 'Syield',...
    'IntP','ExtP','DynP'};...
%     'Bmax','T1Brat','T2Arat',...
    
for i = 1:numel(varNamesSFDT)
    eval(sprintf('varSFDT.%s = inputParam;',varNamesSFDT{i}));
end

varSFDT.x1.min = 0.1;
varSFDT.x1.max = 0.5;
varSFDT.x1.default = 0.4;
varSFDT.x1.symbol = 'x1';
varSFDT.x1.description = 'Position of TAP from front';
varSFDT.x1.unit = '';


varSFDT.x2.min = 0.1;
varSFDT.x2.max = 0.5;
varSFDT.x2.default = 0.3;
varSFDT.x2.symbol = 'x2';
varSFDT.x2.description = 'Position of TAP from rear';
varSFDT.x2.unit = '';

varSFDT.xW.min = 0.1;
varSFDT.xW.max = 0.5;
varSFDT.xW.default = 0.45;
varSFDT.xW.symbol = 'xW';
varSFDT.xW.description = 'Position of Wing';
varSFDT.xW.unit = '';


varSFDT.Hstab_c.min = 0.05;
varSFDT.Hstab_c.max = 1;
varSFDT.Hstab_c.default = 0.2;
varSFDT.Hstab_c.symbol = 'Horizontal stabilizer chord';
varSFDT.Hstab_c.description = 'Horizontal stabilizer chord';
varSFDT.Hstab_c.unit = 'm';

varSFDT.fos.min = 1;
varSFDT.fos.max = 5;
varSFDT.fos.default = 1.5;
varSFDT.fos.symbol = 'Factor of safety';
varSFDT.fos.description = 'Factor of safety';
varSFDT.fos.unit = '';

varSFDT.Syield.min = 10;
varSFDT.Syield.max = 10^10;
varSFDT.Syield.default = 2.7*(10^8);
varSFDT.Syield.symbol = 'Yield stress of material';
varSFDT.Syield.description = 'Yield stress of material';
varSFDT.Syield.unit = 'Pa';

varSFDT.IntP.min = 10^4;
varSFDT.IntP.max = 10^6;
varSFDT.IntP.default = 10^5;
varSFDT.IntP.symbol = 'Internal pressure';
varSFDT.IntP.description = 'Internal pressure in fuselage';
varSFDT.IntP.unit = 'Pa';

varSFDT.ExtP.min = 10^5;
varSFDT.ExtP.max = 10^7;
varSFDT.ExtP.default = 2.2*(10^5);
varSFDT.ExtP.symbol = 'External Pressure';
varSFDT.ExtP.description = 'External pressure in fuselage';
varSFDT.ExtP.unit = 'Pa';

varSFDT.DynP.min = 0;
varSFDT.DynP.max = 2*(10^5);
varSFDT.DynP.default = 5*(10^4);
varSFDT.DynP.symbol = 'Dynamic Pressure';
varSFDT.DynP.description = 'Dynamic Pressure in Fuselage';
varSFDT.DynP.unit = 'Pa';


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