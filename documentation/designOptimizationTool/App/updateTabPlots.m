function updateTabPlots(app,AR,Span,D,L,Wingdim, NSp)
            T = 'MT';
            
            DrawPlot = 'KiteDes';
            A_kitePlot(app,AR,Span,D,L);

            
            DrawPlot2 = 'SFlight';
            A_optAoAplot(app,AR,Span,D,L)

            DrawPlot3 = 'WingDes';
            if NSp == 0
                A_wingDesignPlot(app,AR,Span,Wingdim(1), 0, 0, 0);            
            elseif NSp == 1
                A_wingDesignPlot(app,AR,Span,Wingdim(1), Wingdim(2), 0, 0);
            elseif NSp == 2
                A_wingDesignPlot(app,AR,Span,Wingdim(1), Wingdim(2), Wingdim(2), 0);
            elseif NSp == 3
                A_wingDesignPlot(app,AR,Span,Wingdim(1), Wingdim(2), Wingdim(2), Wingdim(2));
            end

            drawnow;
end