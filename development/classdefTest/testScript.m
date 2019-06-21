%% close all
% clear
% clc
% liftingBody = CustomClasses.liftBdy;
%
% liftingBody.addprop('PortWing');
% liftingBody.PortWing = CustomClasses.aeroSurf;
% liftingBody.PortWing.Gain.Value         = 1;
% % liftingBody.PortWing.refArea.Value      = 2;
% % liftingBody.PortWing.chordUnitVec.Value = [1 0 0];
% % liftingBody.PortWing.spanUnitVec.Value  = [0 1 0];
% % liftingBody.PortWing.alphas.Value = linspace(-10,10,10);
% % liftingBody.PortWing.CLs.Value = linspace(-10,10,10);
% % liftingBody.PortWing.CDs.Value = linspace(-10,10,10);
%
% liftingBody.addprop('StarboardWing');
% liftingBody.StarboardWing = CustomClasses.aeroSurf;
% liftingBody.StarboardWing.Gain.Value         = 2;
% % liftingBody.StarboardWing.refArea.Value      = 2;
% % liftingBody.StarboardWing.chordUnitVec.Value = [1 0 0];
% % liftingBody.StarboardWing.spanUnitVec.Value  = [0 1 0];
% % liftingBody.StarboardWing.alphas.Value = linspace(-10,10,10);
% % liftingBody.StarboardWing.CLs.Value = linspace(-10,10,10);
% % liftingBody.StarboardWing.CDs.Value = linspace(-10,10,10);
%
% %  x = liftingBody.forLoopStruct;
%  sim('testModel')
%
%
%
%%
close all; clear all

vhcl = vehicle.vehicle;
vhcl.numSurfaces.Value = 4;
vhcl.numTethers.Value  = 1;
vhcl.build

% vhcl.prtWng.span.Value = 5;
% vhcl.prtWng.chord.Value = 2;
% vhcl.prtWng.sweepAngle.Value = 0;
% vhcl.prtWng.spanUnitVec.Value  = [0 1 0];
% vhcl.prtWng.chordUnitVec.Value = [1 0 0];
% vhcl.prtWng.alphas.Value = ;
% vhcl.prtWng.CLs = ;
% vhcl.prtWng.CDs = ;
% vhcl.prtWng.GainCL = ;
% vhcl.prtWng.GainCD = ;
% 
% vhcl.stbWng.span.Value = 5;
% vhcl.stbWng.chord.Value = 2;
% vhcl.stbWng.sweepAngle.Value = 0;
% vhcl.stbWng.spanUnitVec.Value  = [0 1 0];
% vhcl.stbWng.chordUnitVec.Value = [1 0 0];
% vhcl.stbWng.alphas.Value = ;
% vhcl.stbWng.CLs = ;
% vhcl.stbWng.CDs = ;
% vhcl.stbWng.GainCL = ;
% vhcl.stbWng.GainCD = ;
% 
% vhcl.hrzStb.span.Value = 5;
% vhcl.hrzStb.chord.Value = 2;
% vhcl.hrzStb.sweepAngle.Value = 0;
% vhcl.hrzStb.spanUnitVec.Value  = [0 1 0];
% vhcl.hrzStb.chordUnitVec.Value = [1 0 0];
% vhcl.hrzStb.alphas.Value = ;
% vhcl.hrzStb.CLs = ;
% vhcl.hrzStb.CDs = ;
% vhcl.hrzStb.GainCL = ;
% vhcl.hrzStb.GainCD = ;
% 
% vhcl.vrtStb.span.Value = 5;
% vhcl.vrtStb.chord.Value = 2;
% vhcl.vrtStb.sweepAngle.Value = 0;
% vhcl.vrtStb.spanUnitVec.Value  = [0 1 0];
% vhcl.vrtStb.chordUnitVec.Value = [1 0 0];
% vhcl.vrtStb.alphas.Value = ;
% vhcl.vrtStb.CLs = ;
% vhcl.vrtStb.CDs = ;
% vhcl.vrtStb.GainCL = ;
% vhcl.vrtStb.GainCD = ;
% 



