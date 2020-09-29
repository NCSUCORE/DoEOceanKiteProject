
varNamesMTinputs = {'Structure'       ,'Wire'     ,'wireInsulation'  ,'fiberOptic' ,...
                    'fiberOpticSheath','extSheath','bedding'         ,'generator'  ,...
                    'tether'          ,'extProp'  ,'kite'        };
    
for i = 1:numel(varNamesMTinputs)
    eval(sprintf('varMT.%s = inputParam;',varNamesMTinputs{i}));
end

%Structral Member Properties "Dyneema"
varMTinputs.Structure.rho                  = 975;
varMTinputs.Structure.youngsMod            = 100*10^9;
varMTinputs.Structure.boolSpring           = 1;
varMTinputs.Structure.strainFailurePercent = 3.5;
varMTinputs.Structure.Diameter.default     = .005;
varMTinputs.Structure.Diameter.symbol      = 'Structral Member Diameter';
varMTinputs.Structure.Diameter.description = 'Structral Member Diameter';
varMTinputs.Structure.Diameter.unit        = 'm';

% Wire Properties "Copper"
varMTinputs.Wire.rho                  = 8960;
varMTinputs.Wire.youngsMod            = 128*10^9;
varMTinputs.Wire.boolSpring           = 1;
varMTinputs.Wire.strainFailurePercent = .3;
varMTinputs.Wire.Diameter.default     = .001;
varMTinputs.Wire.Diameter.symbol      = 'Wire Diameter';
varMTinputs.Wire.Diameter.description = 'Wire Diameter';
varMTinputs.Wire.Diameter.unit        = 'm';
varMTinputs.Wire.number               = 16;
varMTinputs.Wire.rho_electrical       = 1.68*10^-8;
varMTinputs.Wire.helixAngle           = 35;
varMTinputs.Wire.Poisson              = 1;

%Wire Insulation Properties "XLPE"
varMTinputs.wireInsulation.rho                   = 930;
varMTinputs.wireInsulation.youngsMod             = 60*10^9;
varMTinputs.wireInsulation.boolSpring            = 1;
varMTinputs.wireInsulation.strainFailurePercent  = 1;
varMTinputs.wireInsulation.thickness.default     = .00015;
varMTinputs.wireInsulation.thickness.symbol      = 'Wire Insulation Thickness';
varMTinputs.wireInsulation.thickness.description = 'Wire Insulation Thickness';
varMTinputs.wireInsulation.thickness.unit        = 'm';

%Fiber Optic Properties "POF"
varMTinputs.fiberOptic.rho                  = 1000;
varMTinputs.fiberOptic.youngsMod            = 15*10^9;
varMTinputs.fiberOptic.boolSpring           = 1;
varMTinputs.fiberOptic.strainFailurePercent = 2;
varMTinputs.fiberOptic.Diameter.default     = 0.000125;
varMTinputs.fiberOptic.Diameter.symbol      = 'Structral Member Diameter';
varMTinputs.fiberOptic.Diameter.description = 'Structral Member Diameter';
varMTinputs.fiberOptic.Diameter.unit        = 'm';
varMTinputs.fiberOptic.number               =  3;
varMTinputs.fiberOptic.helixAngle           = 35;

%Fiber Optic Sheath Properties "Steel"
varMTinputs.fiberOpticSheath.rho                   = 8050;
varMTinputs.fiberOpticSheath.youngsMod             = 200*10^9;
varMTinputs.fiberOpticSheath.boolSpring            = 1;
varMTinputs.fiberOpticSheath.strainFailurePercent  = 6;
varMTinputs.fiberOpticSheath.thickness.default     = .0001;
varMTinputs.fiberOpticSheath.thickness.symbol      = 'Fiber Optic Sheath Thickness';
varMTinputs.fiberOpticSheath.thickness.description = 'Fiber Optic Sheath Thickness';
varMTinputs.fiberOpticSheath.thickness.unit        = 'm';

%External Sheath Properties "HDPE"
varMTinputs.extSheath.rho                   = 1000;
varMTinputs.extSheath.youngsMod             = 1.5*10^9;
varMTinputs.extSheath.boolSpring            = 0;
varMTinputs.extSheath.strainFailurePercent  = 9;
varMTinputs.extSheath.thickness.default     = .001;
varMTinputs.extSheath.thickness.symbol      = 'Wire Insulation Thickness';
varMTinputs.extSheath.thickness.description = 'Wire Insulation Thickness';
varMTinputs.extSheath.thickness.unit        = 'm';

%Bedding Properties
varMTinputs.bedding.rho                   = 1000;
varMTinputs.bedding.youngsMod             = .01*10^9;
varMTinputs.bedding.boolSpring            = 1;
varMTinputs.bedding.strainFailurePercent  = 50;

%Generator Properties
varMTinputs.generator.power   = 1000; %Watts
varMTinputs.generator.voltage = 95;  %Volts 

%Tether Properties
varMTinputs.tether.tension = 30000; %Newtons
varMTinputs.tether.length  = 400;   %meters

%Fluid Properties
varMTinputs.extProp.fluidRho = 1000;
varMTinputs.extProp.gravAcc = 9.81;

%Kite Properties
varMTinputs.kite.rho = 1000;
varMTinputs.kite.volume = 1.02;




