function createTabInputMT(app)
%%
listInputVarsMT;
listOutputVarsMT;
T = 'MT';
fontSizeLabel = 16;
fontSizeNumbers = 14;
%% Input Start
x = 50; y = 700;
width = 130; height = 25;

app.Labels.SlidSwitch = uilabel(app.UITabs.(T));
app.Labels.SlidSwitch.Text = 'Inputs';
app.Labels.SlidSwitch.Position = [x y 320 30];
app.Labels.SlidSwitch.FontSize = fontSizeLabel+5;
y = y-40;

%% Generator Properties
%Title
app.Labels.(varNamesMTinputs{8}) = uilabel(app.UITabs.(T));
app.Labels.(varNamesMTinputs{8}).Parent = app.UITabs.(T);
app.Labels.(varNamesMTinputs{8}).Text = 'Generator Properties';
app.Labels.(varNamesMTinputs{8}).Position = [x y width+50 height];
app.Labels.(varNamesMTinputs{8}).FontSize = fontSizeLabel+2;
y = y - 25;

%Total Power
app.Labels.genPower = uilabel(app.UITabs.(T));
app.Labels.genPower.Parent = app.UITabs.(T);
app.Labels.genPower.Text = 'Total Power (W)';
app.Labels.genPower.Position = [x y width+50 height];
app.Labels.genPower.FontSize = fontSizeLabel;
y = y-25;
app.InputBoxs.genPower = uieditfield(app.UITabs.(T),'numeric');
app.InputBoxs.genPower.Parent = app.UITabs.(T);
app.InputBoxs.genPower.Position = [x y width height];
app.InputBoxs.genPower.Value = varMTinputs.(varNamesMTinputs{8}).power;
app.InputBoxs.genPower.FontSize = fontSizeNumbers;
y = y+25;

%Total Power
x = x+150;
app.Labels.genVoltage = uilabel(app.UITabs.(T));
app.Labels.genVoltage.Parent = app.UITabs.(T);
app.Labels.genVoltage.Text = 'Generator Voltage (V)';
app.Labels.genVoltage.Position = [x y width+50 height];
app.Labels.genVoltage.FontSize = fontSizeLabel;
y = y-25;
app.InputBoxs.genVoltage = uieditfield(app.UITabs.(T),'numeric');
app.InputBoxs.genVoltage.Parent = app.UITabs.(T);
app.InputBoxs.genVoltage.Position = [x y width height];
app.InputBoxs.genVoltage.Value = varMTinputs.(varNamesMTinputs{8}).voltage;
app.InputBoxs.genVoltage.FontSize = fontSizeNumbers;
y = y+25;

%Diameter Bool
y = y-50;
x = x-150;

%% Structural Member

%Title
app.Labels.(varNamesMTinputs{1}) = uilabel(app.UITabs.(T));
app.Labels.(varNamesMTinputs{1}).Parent = app.UITabs.(T);
app.Labels.(varNamesMTinputs{1}).Text = 'Structural Member';
app.Labels.(varNamesMTinputs{1}).Position = [x y width+50 height];
app.Labels.(varNamesMTinputs{1}).FontSize = fontSizeLabel+2;
y = y - 25;

%Wire Diameter
x = x+150;
app.Labels.(varNamesMTinputs{1}) = uilabel(app.UITabs.(T));
app.Labels.(varNamesMTinputs{1}).Parent = app.UITabs.(T);
app.Labels.(varNamesMTinputs{1}).Text = 'Diameter';
app.Labels.(varNamesMTinputs{1}).Position = [x y width+50 height];
app.Labels.(varNamesMTinputs{1}).FontSize = fontSizeLabel;
y = y-25;
app.InputBoxs.(varNamesMTinputs{1}) = uieditfield(app.UITabs.(T),'numeric');
app.InputBoxs.(varNamesMTinputs{1}).Parent = app.UITabs.(T);
app.InputBoxs.(varNamesMTinputs{1}).Position = [x y width height];
app.InputBoxs.(varNamesMTinputs{1}).Value = varMTinputs.(varNamesMTinputs{1}).Diameter.default;
app.InputBoxs.(varNamesMTinputs{1}).FontSize = fontSizeNumbers;
y = y+25;

%Diameter Bool
x = x+160;
% app.Labels.(varNamesMTinputs{1}) = uilabel(app.UITabs.(T));
% app.Labels.(varNamesMTinputs{1}).Parent = app.UITabs.(T);
% app.Labels.(varNamesMTinputs{1}).Text = 'Structural';
% app.Labels.(varNamesMTinputs{1}).Position = [x y width+50 height];
% app.Labels.(varNamesMTinputs{1}).FontSize = fontSizeLabel;
y = y-25;
% app.SliderSwitch.SlidSwitch.(varNamesMTinputs{1}) = uiswitch(app.UITabs.(T));
% app.SliderSwitch.SlidSwitch.(varNamesMTinputs{1}).Items = {'On ','Off'};
% app.SliderSwitch.SlidSwitch.(varNamesMTinputs{1}).Position = [x y 60 60];
% app.SliderSwitch.SlidSwitch.(varNamesMTinputs{1}).FontSize = fontSizeNumbers;
% app.SliderSwitch.SlidSwitch.(varNamesMTinputs{1}).Value = {'On '};
y = y-25;
x = x-310;

%% Wire 

%Title
app.Labels.(varNamesMTinputs{2}) = uilabel(app.UITabs.(T));
app.Labels.(varNamesMTinputs{2}).Parent = app.UITabs.(T);
app.Labels.(varNamesMTinputs{2}).Text = 'Wire';
app.Labels.(varNamesMTinputs{2}).Position = [x y width+50 height];
app.Labels.(varNamesMTinputs{2}).FontSize = fontSizeLabel+2;
y = y-25;

%Helix Angle
app.Labels.(varNamesMTinputs{2}) = uilabel(app.UITabs.(T));
app.Labels.(varNamesMTinputs{2}).Parent = app.UITabs.(T);
app.Labels.(varNamesMTinputs{2}).Text = 'Helix Ang °';
app.Labels.(varNamesMTinputs{2}).Position = [x y width+50 height];
app.Labels.(varNamesMTinputs{2}).FontSize = fontSizeLabel;
y = y-25;
app.InputBoxs.helixAngleWire = uieditfield(app.UITabs.(T),'numeric');
app.InputBoxs.helixAngleWire.Position = [x y 50 height];
app.InputBoxs.helixAngleWire.Value = varMTinputs.(varNamesMTinputs{2}).helixAngle;
app.InputBoxs.helixAngleWire.FontSize = fontSizeNumbers;
y = y+25;

%Num Wires
x = x+90;
app.Labels.(varNamesMTinputs{2}) = uilabel(app.UITabs.(T));
app.Labels.(varNamesMTinputs{2}).Parent = app.UITabs.(T);
app.Labels.(varNamesMTinputs{2}).Text = 'Number';
app.Labels.(varNamesMTinputs{2}).Position = [x y width+50 height];
app.Labels.(varNamesMTinputs{2}).FontSize = fontSizeLabel;
y = y-25;
app.InputBoxs.numWires = uieditfield(app.UITabs.(T),'numeric');
app.InputBoxs.numWires.Position = [x y 50 height];
app.InputBoxs.numWires.Value = varMTinputs.(varNamesMTinputs{2}).number;
app.InputBoxs.numWires.FontSize = fontSizeNumbers;
y = y+25;

%Wire Diameter
x = x+60;
app.Labels.(varNamesMTinputs{2}) = uilabel(app.UITabs.(T));
app.Labels.(varNamesMTinputs{2}).Parent = app.UITabs.(T);
app.Labels.(varNamesMTinputs{2}).Text = 'Diameter';
app.Labels.(varNamesMTinputs{2}).Position = [x y width+50 height];
app.Labels.(varNamesMTinputs{2}).FontSize = fontSizeLabel;
y = y-25;
app.InputBoxs.(varNamesMTinputs{2}) = uieditfield(app.UITabs.(T),'numeric');
app.InputBoxs.(varNamesMTinputs{2}).Parent = app.UITabs.(T);
app.InputBoxs.(varNamesMTinputs{2}).Position = [x y width height];
app.InputBoxs.(varNamesMTinputs{2}).Value = varMTinputs.(varNamesMTinputs{2}).Diameter.default;
app.InputBoxs.(varNamesMTinputs{2}).FontSize = fontSizeNumbers;
y = y+25;

%Diameter Bool
x = x+160;
% app.Labels.(varNamesMTinputs{2}) = uilabel(app.UITabs.(T));
% app.Labels.(varNamesMTinputs{2}).Parent = app.UITabs.(T);
% app.Labels.(varNamesMTinputs{2}).Text = 'Structural';
% app.Labels.(varNamesMTinputs{2}).Position = [x y width+50 height];
% app.Labels.(varNamesMTinputs{2}).FontSize = fontSizeLabel;
y = y-25;
% app.SliderSwitch.SlidSwitch.(varNamesMTinputs{2}) = uiswitch(app.UITabs.(T));
% app.SliderSwitch.SlidSwitch.(varNamesMTinputs{2}).Items = {'On ','Off'};
% app.SliderSwitch.SlidSwitch.(varNamesMTinputs{2}).Position = [x y 60 60];
% app.SliderSwitch.SlidSwitch.(varNamesMTinputs{2}).FontSize = fontSizeNumbers;
% app.SliderSwitch.SlidSwitch.(varNamesMTinputs{2}).Value = {'On '};

%% Fiber Optic
y = y-25;
x = x-310;
%Title
app.Labels.(varNamesMTinputs{4}) = uilabel(app.UITabs.(T));
app.Labels.(varNamesMTinputs{4}).Parent = app.UITabs.(T);
app.Labels.(varNamesMTinputs{4}).Text = 'Fiber Optic';
app.Labels.(varNamesMTinputs{4}).Position = [x y width+50 height];
app.Labels.(varNamesMTinputs{4}).FontSize = fontSizeLabel+2;
y = y - 25;

%Helix Angle
app.Labels.(varNamesMTinputs{4}) = uilabel(app.UITabs.(T));
app.Labels.(varNamesMTinputs{4}).Parent = app.UITabs.(T);
app.Labels.(varNamesMTinputs{4}).Text = 'Helix Ang °';
app.Labels.(varNamesMTinputs{4}).Position = [x y width+50 height];
app.Labels.(varNamesMTinputs{4}).FontSize = fontSizeLabel;
y = y-25;
app.InputBoxs.helixAngleFiber = uieditfield(app.UITabs.(T),'numeric');
app.InputBoxs.helixAngleFiber.Position = [x y 50 height];
app.InputBoxs.helixAngleFiber.Value = varMTinputs.(varNamesMTinputs{4}).helixAngle;
app.InputBoxs.helixAngleFiber.FontSize = fontSizeNumbers;
y = y+25;

%Num Wires
x = x+90;
app.Labels.(varNamesMTinputs{4}) = uilabel(app.UITabs.(T));
app.Labels.(varNamesMTinputs{4}).Parent = app.UITabs.(T);
app.Labels.(varNamesMTinputs{4}).Text = 'Number';
app.Labels.(varNamesMTinputs{4}).Position = [x y width+50 height];
app.Labels.(varNamesMTinputs{4}).FontSize = fontSizeLabel;
y = y-25;
app.InputBoxs.numFiberOptic = uieditfield(app.UITabs.(T),'numeric');
app.InputBoxs.numFiberOptic.Position = [x y 50 height];
app.InputBoxs.numFiberOptic.Value = varMTinputs.(varNamesMTinputs{4}).number;
app.InputBoxs.numFiberOptic.FontSize = fontSizeNumbers;
y = y+25;

%Wire Diameter
x = x+60;
app.Labels.(varNamesMTinputs{4}) = uilabel(app.UITabs.(T));
app.Labels.(varNamesMTinputs{4}).Parent = app.UITabs.(T);
app.Labels.(varNamesMTinputs{4}).Text = 'Diameter';
app.Labels.(varNamesMTinputs{4}).Position = [x y width+50 height];
app.Labels.(varNamesMTinputs{4}).FontSize = fontSizeLabel;
y = y-25;
app.InputBoxs.(varNamesMTinputs{4}) = uieditfield(app.UITabs.(T),'numeric');
app.InputBoxs.(varNamesMTinputs{4}).Parent = app.UITabs.(T);
app.InputBoxs.(varNamesMTinputs{4}).Position = [x y width height];
app.InputBoxs.(varNamesMTinputs{4}).Value = varMTinputs.fiberOptic.Diameter.default;
app.InputBoxs.(varNamesMTinputs{4}).FontSize = fontSizeNumbers;
y = y+25;

%Diameter Bool
x = x+160;
% app.Labels.(varNamesMTinputs{4}) = uilabel(app.UITabs.(T));
% app.Labels.(varNamesMTinputs{4}).Parent = app.UITabs.(T);
% app.Labels.(varNamesMTinputs{4}).Text = 'Structural';
% app.Labels.(varNamesMTinputs{4}).Position = [x y width+50 height];
% app.Labels.(varNamesMTinputs{4}).FontSize = fontSizeLabel;
y = y-25;
% app.SliderSwitch.SlidSwitch.(varNamesMTinputs{4}) = uiswitch(app.UITabs.(T));
% app.SliderSwitch.SlidSwitch.(varNamesMTinputs{4}).Items = {'On ','Off'};
% app.SliderSwitch.SlidSwitch.(varNamesMTinputs{4}).Position = [x y 60 60];
% app.SliderSwitch.SlidSwitch.(varNamesMTinputs{4}).FontSize = fontSizeNumbers;
% app.SliderSwitch.SlidSwitch.(varNamesMTinputs{4}).Value = {'On '};


%% Run Button
% Run Button for overall Optimization
Bttn = 'updateTool';
app.Buttons.Bttn = uibutton(app.UITabs.(T));
app.Buttons.Bttn.Text = ('Run');
app.Buttons.Bttn.Position = [700 50 120 40];
app.Buttons.Bttn.FontSize = 20;
app.Buttons.Bttn.FontName = 'Arial Narrow';
app.Buttons.Bttn.ButtonPushedFcn = @(btn,event) updateTool(app);

%% Graph and Values
[support_Force, strain_Percent, power_Loss_Percent, outer_Diameter, failure_Strain_Percent,maxStrain_Percent_Over_Failure,maxStrain_Percent_Over_Failure_Componets] = createTabPlots(app);

%% Output Start
width = 130; height = 25;
x = 500; y = 700;

app.Labels.SlidSwitch = uilabel(app.UITabs.(T));
app.Labels.SlidSwitch.Text = 'Results';
app.Labels.SlidSwitch.Position = [x y 320 30];
app.Labels.SlidSwitch.FontSize = fontSizeLabel+5;

%% Support Force
y = y-40;
app.Labels.supportForce = uilabel(app.UITabs.(T));
app.Labels.supportForce.Text = 'Support Force (N)';
app.Labels.supportForce.Position = [x y width+50 height];
app.Labels.supportForce.FontSize = fontSizeLabel;

y = y-25;
app.InputBoxs.(varNamesMToutputs{1}) = uieditfield(app.UITabs.(T),'numeric');
app.InputBoxs.(varNamesMToutputs{1}).Position = [x y width height];
app.InputBoxs.(varNamesMToutputs{1}).Value = support_Force;
app.InputBoxs.(varNamesMToutputs{1}).FontSize = fontSizeNumbers;
app.InputBoxs.(varNamesMToutputs{1}).Editable = 'off';

%% Strain Percent
y = y-40;
app.Labels.supportForce = uilabel(app.UITabs.(T));
app.Labels.supportForce.Text = 'Total Strain (%)';
app.Labels.supportForce.Position = [x y width+50 height];
app.Labels.supportForce.FontSize = fontSizeLabel;

y = y-25;
app.InputBoxs.(varNamesMToutputs{2}) = uieditfield(app.UITabs.(T),'numeric');
app.InputBoxs.(varNamesMToutputs{2}).Position = [x y width height];
app.InputBoxs.(varNamesMToutputs{2}).Value = strain_Percent;
app.InputBoxs.(varNamesMToutputs{2}).FontSize = fontSizeNumbers;
app.InputBoxs.(varNamesMToutputs{2}).Editable = 'off';

%% Power Loss Percent
y = y-40;
app.Labels.supportForce = uilabel(app.UITabs.(T));
app.Labels.supportForce.Text = 'Power Loss (%)';
app.Labels.supportForce.Position = [x y width+50 height];
app.Labels.supportForce.FontSize = fontSizeLabel;

y = y-25;
app.InputBoxs.(varNamesMToutputs{3}) = uieditfield(app.UITabs.(T),'numeric');
app.InputBoxs.(varNamesMToutputs{3}).Position = [x y width height];
app.InputBoxs.(varNamesMToutputs{3}).Value = power_Loss_Percent;
app.InputBoxs.(varNamesMToutputs{3}).FontSize = fontSizeNumbers;
app.InputBoxs.(varNamesMToutputs{3}).Editable = 'off';

%% Power Loss Percent
y = y-40;
app.Labels.supportForce = uilabel(app.UITabs.(T));
app.Labels.supportForce.Text = 'Outer Diameter (mm)';
app.Labels.supportForce.Position = [x y width+50 height];
app.Labels.supportForce.FontSize = fontSizeLabel;

y = y-25;
app.InputBoxs.(varNamesMToutputs{3}) = uieditfield(app.UITabs.(T),'numeric');
app.InputBoxs.(varNamesMToutputs{3}).Position = [x y width height];
app.InputBoxs.(varNamesMToutputs{3}).Value = outer_Diameter*1000;
app.InputBoxs.(varNamesMToutputs{3}).FontSize = fontSizeNumbers;
app.InputBoxs.(varNamesMToutputs{3}).Editable = 'off';

%% Failure Strain/Member
y = y-40;
app.Labels.supportForce = uilabel(app.UITabs.(T));
app.Labels.supportForce.Text = 'Failure Strain % Over';
app.Labels.supportForce.Position = [x y width+50 height];
app.Labels.supportForce.FontSize = fontSizeLabel;

y = y-25;
app.InputBoxs.strainFailComp = uieditfield(app.UITabs.(T),'numeric');
app.InputBoxs.strainFailComp.Position = [x y width height];
if maxStrain_Percent_Over_Failure <= 0
    app.InputBoxs.strainFailComp.Value = 0;
else
    app.InputBoxs.strainFailComp.Value = maxStrain_Percent_Over_Failure;
end
app.InputBoxs.strainFailComp.FontSize = fontSizeNumbers;
app.InputBoxs.strainFailComp.Editable = 'off';

y = y-40;
app.Labels.strainFailCompLabel = uilabel(app.UITabs.(T));
app.Labels.strainFailCompLabel.Text = 'Failure Strain Member(s)';
app.Labels.strainFailCompLabel.Position = [x y width+50 height];
app.Labels.strainFailCompLabel.FontSize = fontSizeLabel;

y = y-100;
x = x+10;
app.Labels.strainFailComp = uilabel(app.UITabs.(T));
app.Labels.strainFailComp.Text = strcat('-',maxStrain_Percent_Over_Failure_Componets');
app.Labels.strainFailComp.Position = [x y width+50 height+100];
app.Labels.strainFailComp.FontSize = fontSizeLabel;
x = x-10;

end
