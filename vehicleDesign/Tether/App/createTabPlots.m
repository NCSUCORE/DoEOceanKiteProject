function [support_Force, strain_Percent, power_Loss_Percent, outer_Diameter, failure_Strain_Percent,maxStrain_Percent_Over_Failure,maxStrain_Percent_Over_Failure_Componets] = createTabPlots(app)
            T = 'MT';
            listInputVarsMT
            
            x = 700; y = 120;
            width = 600; height = 600;
            
            DrawPlot = 'TetherDes';%'KiteDes';
            app.PlotAxes.DrawPlot = uiaxes(app.UITabs.(T));
            app.PlotAxes.DrawPlot.Position  = [x y width height];
            
            hold(app.PlotAxes.DrawPlot,'on');
            [support_Force, strain_Percent, power_Loss_Percent, outer_Diameter, failure_Strain_Percent,maxStrain_Percent_Over_Failure,maxStrain_Percent_Over_Failure_Componets] = A_tetherPlot(app,varMTinputs);
            
end