function updateTabPlots(app,AR_ini,Span_ini,D_ini,L_ini,WingDim)
            T = 'MT';
            
            DrawPlot = 'KiteDes';
            A_kitePlot(app,AR_ini,Span_ini,D_ini,L_ini);

            
            DrawPlot2 = 'SFlight';
            A_optAoAplot(app,AR_ini,Span_ini,D_ini,L_ini)


            DrawPlot3 = 'WingDes';
            A_wingDesignPlot(app,AR_ini,Span_ini,...
                WingDim(1),WingDim(2),WingDim(3),WingDim(4));

end