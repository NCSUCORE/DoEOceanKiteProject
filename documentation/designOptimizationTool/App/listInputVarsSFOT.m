varNamesSFOT = {'CL0','Kvisc','xg','h',...
    'Cdh','Cd0h','Cfe','Hstall','yW','eW','eDW'};
for i = 1:numel(varNamesSFOT)
    eval(sprintf('varSFOT.%s = inputParam;',varNamesSFOT{i}));
end

varSFOT.CL0.min = -0.1;
varSFOT.CL0.max = 0.3;
varSFOT.CL0.default = 0.16;
varSFOT.CL0.symbol = 'CL0';
varSFOT.CL0.description = 'Lift at zero AoA';
varSFOT.CL0.unit = '';

%Default is Aluminum
varSFOT.Kvisc.min = 0;
varSFOT.Kvisc.max = 0.1;
varSFOT.Kvisc.default = 0.03;
varSFOT.Kvisc.symbol = 'Kvisc';
varSFOT.Kvisc.description = 'Viscous coefficient factor';
varSFOT.Kvisc.unit = '';

varSFOT.xg.min = -1;
varSFOT.xg.max = 1;
varSFOT.xg.default = 0.2;
varSFOT.xg.symbol = 'Center of Mass';
varSFOT.xg.description = 'Center of Mass';
varSFOT.xg.unit = 'm';


varSFOT.h.min = -0.6;
varSFOT.h.max = 0;
varSFOT.h.default = -0.2;
varSFOT.h.symbol = 'Stability Margin';
varSFOT.h.description = 'Stability Margin (h)';
varSFOT.h.unit = 'm';

varSFOT.Cdh.min = 0;
varSFOT.Cdh.max = 0.1;
varSFOT.Cdh.default = 0.0392;
varSFOT.Cdh.symbol = 'Overall H Stab drag factor';
varSFOT.Cdh.description = 'Overall H Stab drag factor';
varSFOT.Cdh.unit = '';

varSFOT.Cd0h.min = 0;
varSFOT.Cd0h.max = 0.1;
varSFOT.Cd0h.default = 1.7*(10^-4);
varSFOT.Cd0h.symbol = 'H Stab drag at zero lift';
varSFOT.Cd0h.description = 'H stabilizer drag at zero lift';
varSFOT.Cd0h.unit = '';


varSFOT.Cfe.min = 0.0;
varSFOT.Cfe.max = 0.1;
varSFOT.Cfe.default = 0.003;
varSFOT.Cfe.symbol = 'Fuse Skin Friction drag';
varSFOT.Cfe.description = 'Fuselage Skin Friction drag';
varSFOT.Cfe.unit = '';

varSFOT.Hstall.min = 0;
varSFOT.Hstall.max = 20;
varSFOT.Hstall.default = 10;
varSFOT.Hstall.symbol = 'H Stab Stall Angle';
varSFOT.Hstall.description = 'H Stabilizer Stall Angle';
varSFOT.Hstall.unit = '';

varSFOT.yW.min = 0.7;
varSFOT.yW.max = 1;
varSFOT.yW.default = 0.95;
varSFOT.yW.symbol = 'yW';
varSFOT.yW.description = 'Wing Efficiency';
varSFOT.yW.unit = '';

varSFOT.eW.min = 0.7;
varSFOT.eW.max = 1;
varSFOT.eW.default = 0.71;
varSFOT.eW.symbol = 'eW';
varSFOT.eW.description = 'Wing Oswald efficiency';
varSFOT.eW.unit = '';


varSFOT.eDW.min = 0;
varSFOT.eDW.max = 1;
varSFOT.eDW.default = 0.98;
varSFOT.eDW.symbol = 'eDW';
varSFOT.eDW.description = 'Wing Drag efficiency';
varSFOT.eDW.unit = '';

% varSFOT.eDH.min = 0.7;
% varSFOT.eDH.max = 1;
% varSFOT.eDH.default = 0.85;
% varSFOT.eDH.symbol = 'eDH';
% varSFOT.eDH.description = ...
%     'Maximum value of T2 as percentage of Maximum length of A';
% varSFOT.eDH.unit = '%';

% varSFOT.CDFfuse.min = 0.001;
% varSFOT.CDFfuse.max = 0.08;
% varSFOT.CDFfuse.default = 0.04;
% varSFOT.CDFfuse.symbol = 'CDFfuse';
% varSFOT.CDFfuse.description = ...
%     'Maximum value of T2 as percentage of Maximum length of A';
% varSFOT.CDFfuse.unit = '%';