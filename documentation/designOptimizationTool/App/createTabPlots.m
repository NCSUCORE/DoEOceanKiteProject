function createTabPlots(app)
            T = 'MT';
            
            x = 700; y = 120;
            width = 600; height = 600;
            
            DrawPlot = 'KiteDes';
            app.PlotAxes.DrawPlot = uiaxes(app.UITabs.(T));
            app.PlotAxes.DrawPlot.Position  = [x y width height];
            app.PlotAxes.DrawPlot.XLim  = [-1 12];
            app.PlotAxes.DrawPlot.YLim  = [-8 8];
            app.PlotAxes.DrawPlot.ZLim  = [-1 3];

            AR_ini = 6.5000;
            Span_ini = 7.5384;
            D_ini = 0.7000;
            L_ini = 8.2750;
            
            
%             app.Plots.DrawPlot.Plot = surf(app.PlotAxes.DrawPlot, xtest,ytest,ztest1);
%             app.Plots.DrawPlot.Plot = surf(app.PlotAxes.DrawPlot, xtest,ytest,ztest2);
            hold(app.PlotAxes.DrawPlot,'on');
            daspect(app.PlotAxes.DrawPlot,[1 1 1]);
            A_kitePlot(app,AR_ini,Span_ini,D_ini,L_ini);

            
            T = 'SFOT';
            
            x = 700; y = 120;
            width = 600; height = 600;
            
            DrawPlot2 = 'SFlight';
            app.PlotAxes.DrawPlot2 = uiaxes(app.UITabs.(T));
            app.PlotAxes.DrawPlot2.Position  = [x y width height];
            app.PlotAxes.DrawPlot2.XLim = [-15 15];
            app.PlotAxes.DrawPlot2.YLim = [-300 300];
            xlabel(app.PlotAxes.DrawPlot2, 'Angle of Attack (AoA)','FontSize',16);
            ylabel(app.PlotAxes.DrawPlot2, 'Performance CL^3/CD^2','FontSize',16);
            
            hold(app.PlotAxes.DrawPlot2,'on');
            A_optAoAplot(app,AR_ini,Span_ini,D_ini,L_ini)


            T = 'SWDT';
            
            x = 700; y = 120;
            width = 600; height = 600;
            
            DrawPlot3 = 'WingDes';
            app.PlotAxes.DrawPlot3 = uiaxes(app.UITabs.(T));
            app.PlotAxes.DrawPlot3.Position  = [x y width height];
%             xlim = [0 10];
%             ylim = [0 10];
            app.PlotAxes.DrawPlot3.XLim = [-0.1 1.1];
            app.PlotAxes.DrawPlot3.YLim = [-0.3 0.3];
            
            hold(app.PlotAxes.DrawPlot3,'on');
            A_wingDesignPlot(app,AR_ini,Span_ini,0.15, 0.08, 0.06, 0.06)

end