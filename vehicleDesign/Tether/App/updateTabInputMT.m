function createTabInputMT(app)
listInputVarsMT;
listOutputVarsMT;

T = 'MT';

[support_Force, strain_Percent, power_Loss_Percent, outer_Diameter, failure_Strain_Percent,maxStrain_Percent_Over_Failure,maxStrain_Percent_Over_Failure_Componets] = createTabPlots(app);

%% Outputs
fontSize = 16;
width = 130; height = 25;
x = 500; y = 635;

app.InputBoxs.(varNamesMToutputs{1}) = uieditfield(app.UITabs.(T),'numeric');
app.InputBoxs.(varNamesMToutputs{1}).Position = [x y width height];
app.InputBoxs.(varNamesMToutputs{1}).Value = support_Force;
app.InputBoxs.(varNamesMToutputs{1}).FontSize = fontSize;
y = y- 65;

app.InputBoxs.(varNamesMToutputs{1}) = uieditfield(app.UITabs.(T),'numeric');
app.InputBoxs.(varNamesMToutputs{1}).Position = [x y width height];
app.InputBoxs.(varNamesMToutputs{1}).Value = strain_Percent;
app.InputBoxs.(varNamesMToutputs{1}).FontSize = fontSize;
y = y- 65;

app.InputBoxs.(varNamesMToutputs{1}) = uieditfield(app.UITabs.(T),'numeric');
app.InputBoxs.(varNamesMToutputs{1}).Position = [x y width height];
app.InputBoxs.(varNamesMToutputs{1}).Value = power_Loss_Percent;
app.InputBoxs.(varNamesMToutputs{1}).FontSize = fontSize;
y = y- 65;

app.InputBoxs.(varNamesMToutputs{3}) = uieditfield(app.UITabs.(T),'numeric');
app.InputBoxs.(varNamesMToutputs{3}).Position = [x y width height];
app.InputBoxs.(varNamesMToutputs{3}).Value = outer_Diameter*1000;
app.InputBoxs.(varNamesMToutputs{3}).FontSize = fontSize;


%% Strain Failures
y = y-40;

y = y-25;
app.InputBoxs.strainFailComp = uieditfield(app.UITabs.(T),'numeric');
app.InputBoxs.strainFailComp.Position = [x y width height];
if maxStrain_Percent_Over_Failure <= 0
    app.InputBoxs.strainFailComp.Value = 0;
else
    app.InputBoxs.strainFailComp.Value = maxStrain_Percent_Over_Failure;
end
app.InputBoxs.strainFailComp.FontSize = fontSize;

y = y-40;

y = y-100;
x = x+10;
app.Labels.strainFailComp.delete
app.Labels.strainFailComp = uilabel(app.UITabs.(T));
app.Labels.strainFailComp.Text = strcat('-',maxStrain_Percent_Over_Failure_Componets');
app.Labels.strainFailComp.Position = [x y width+50 height+100];
app.Labels.strainFailComp.FontSize = fontSize;
x = x-10;

%% Run Button
% Run Button for overall Optimization
Bttn = 'updateTool';
app.Buttons.Bttn.delete
app.Buttons.Bttn = uibutton(app.UITabs.(T));
app.Buttons.Bttn.Text = ('Run');
app.Buttons.Bttn.Position = [700 50 120 40];
app.Buttons.Bttn.FontSize = 20;
app.Buttons.Bttn.FontName = 'Arial Narrow';
app.Buttons.Bttn.ButtonPushedFcn = @(btn,event) updateTool(app);

end
