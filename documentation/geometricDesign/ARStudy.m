classdef ARStudy < matlab.apps.AppBase
    
    % Properties that correspond to app components
    properties (Access = public)
        UIFigure      matlab.ui.Figure
        PowerAxes     matlab.ui.control.UIAxes
        PowerSurfAxes matlab.ui.control.UIAxes
        EffAxes       matlab.ui.control.UIAxes
        Sliders       struct
        SliderLabels  struct
        ValueLabels   struct
        UnitLabels    struct
        PowerPlot     struct
        PowerSurf     struct
        OptPowerPlot  struct
        EffPlot       struct
        Legend        matlab.graphics.illustration.Legend
    end
    
    % Component initialization
    methods (Access = private)
        
        % Create UIFigure and components
        function createComponents(app)
            
            % Create structs to hold handles of plots
            app.SliderLabels    = struct;
            app.Sliders         = struct;
            app.ValueLabels     = struct;
            app.UnitLabels      = struct;

            % Script to create struct of simParam objects containing
            % defaults, min/max, etc.
            createDefaultParams
            
            % Margins around elements of the figure, in % width or height
            xMargin = 0.01;
            yMargin = 0.05;
            
            % Font size of plot axes, not slides
            fontSize = 16;
            
            % Create UIFigure and hide until all components are created
            app.UIFigure = uifigure('Visible', 'off');
            app.UIFigure.Name = 'Geometric Design Tool';
            app.UIFigure.Color = [1 1 1];
            app.UIFigure.Visible = 'on';
            app.UIFigure.WindowState = 'maximized';

            % Get screen dimensions
            d = get(0,'screensize');
            x = round(linspace(round(xMargin*d(3)),round(d(3)-xMargin*d(3)),100));
            y = round(linspace(round(yMargin*d(4)),round(d(4)-yMargin*d(4)),numel(varNames)+1));
            
            % Create Power Axes and Plots
            app.PowerAxes = uiaxes(app.UIFigure);
            app.PowerAxes.NextPlot = 'add';
            app.PowerAxes.BackgroundColor = [1 1 1];
            xlabel(app.PowerAxes, '$AR_w$', 'Interpreter', 'latex')
            ylabel(app.PowerAxes, 'P [kW]', 'Interpreter', 'latex')
            app.PowerAxes.LineStyleOrder = '-';
            app.PowerAxes.TickLabelInterpreter = 'tex';
            app.PowerAxes.Position = [x(30) round(d(4)/2) x(60)-x(30) round(d(4)*(0.9-yMargin-0.5))];
            app.PowerAxes.FontSize = fontSize;

            app.PowerPlot = struct;
            app.PowerPlot.Plot = plot(app.PowerAxes,linspace(1,20,150),nan(size(linspace(1,20,150))),...
                'Color','k','LineWidth',1,'DisplayName','$\alpha=$ Specified');
            app.PowerPlot.OptMarker = plot(app.PowerAxes,[nan nan nan],[nan nan nan],'Color',[0 0 0],'LineStyle','--');
            app.PowerPlot.OptMarker.HandleVisibility = 'off';
            app.OptPowerPlot = struct;
            app.OptPowerPlot.Plot = plot(app.PowerAxes,linspace(1,20,150),nan(size(linspace(1,20,150))),...
                'Color',[0.75 0 0],'LineWidth',1,'DisplayName','$\alpha=$ Optimal');
            app.OptPowerPlot.OptMarker = plot(app.PowerAxes,[nan nan nan],[nan nan nan],'Color',0.75*[1 0 0],'LineStyle','--');
            app.OptPowerPlot.OptMarker.HandleVisibility = 'off';
            app.PowerPlot.Title = title(app.PowerAxes,'');
%             app.PowerPlot.Title.Interpreter = 'tex';
            app.Legend = legend(app.PowerAxes);
            app.Legend.FontSize = fontSize;
            app.Legend.Box = 'off';
            
            % Create Power Surface Axes and Plots
            app.PowerSurfAxes = uiaxes(app.UIFigure);
            app.PowerSurfAxes.NextPlot = 'add';
            app.PowerSurfAxes.BackgroundColor = [1 1 1];
            xlabel(app.PowerSurfAxes, '$\alpha$ [$^{\circ}$]', 'Interpreter', 'latex')
            ylabel(app.PowerSurfAxes, '$AR_w$', 'Interpreter', 'latex')
            zlabel(app.PowerSurfAxes, 'P [kW]', 'Interpreter', 'latex')
            app.PowerSurfAxes.LineStyleOrder = '-';
%             app.PowerSurfAxes.TickLabelInterpreter = 'tex';
            app.PowerSurfAxes.Position = [x(61) round(d(4)/2) x(91)-x(61) round(d(4)*(0.9-yMargin-0.5))];
            app.PowerSurfAxes.FontSize = fontSize;
            % view(app.PowerSurfAxes,-27.1281,44) % Setting view angles
            % seems to break things.
            colormap(app.PowerSurfAxes,[linspace(0,1)' zeros(100,1) linspace(0.4,0)']);
            app.PowerSurf = struct;
            app.PowerSurf.Surf = surf(app.PowerSurfAxes,nan(2,2),nan(2,2),nan(2,2));
            app.PowerSurf.Surf.EdgeColor = 'none';
            
            
            % Create Aerodynamic Efficiency Axes and Plots
            app.EffAxes = uiaxes(app.UIFigure,'NextPlot','add');
            app.EffAxes.BackgroundColor = [1 1 1];
            xlabel(app.EffAxes, '$AR_w$', 'Interpreter', 'latex')
            ylabel(app.EffAxes, '$C_L^3/C_D^2$', 'Interpreter', 'latex')
            app.EffAxes.LineStyleOrder = '-';
            app.EffAxes.TickLabelInterpreter = 'tex';
            app.EffAxes.Position = [x(30) round(d(4)*yMargin) x(60)-x(30) round(d(4)*(0.9-yMargin-0.5))];
            app.EffAxes.FontSize = fontSize;
            app.EffPlot = struct;
            app.EffPlot.Plot = plot(app.EffAxes,linspace(1,20,150),nan(size(linspace(1,20,150))),'Color','k','LineWidth',1);
            
            for ii =1:numel(varNames)
                % Create sliders down the left hand side
                ticks = linspace(p.(varNames{ii}).min,p.(varNames{ii}).max,9);
                app.Sliders.(varNames{ii}) = uislider(app.UIFigure);
                app.Sliders.(varNames{ii}).Position(1) = x(6);
                app.Sliders.(varNames{ii}).Position(2) = y(numel(varNames)+1-ii);
                app.Sliders.(varNames{ii}).Position(3) = x(25)-x(6);
                app.Sliders.(varNames{ii}).Limits(1) = p.(varNames{ii}).min;
                app.Sliders.(varNames{ii}).Limits(2) = p.(varNames{ii}).max;
                app.Sliders.(varNames{ii}).Value = p.(varNames{ii}).default;
                app.Sliders.(varNames{ii}).MajorTicks = ticks(1:2:end);
                app.Sliders.(varNames{ii}).MinorTicks = ticks(2:2:end);
                app.Sliders.(varNames{ii}).Tooltip = p.(varNames{ii}).description;
                app.Sliders.(varNames{ii}).ValueChangedFcn = @(sld,event) updatePlots(app);
                app.Sliders.(varNames{ii}).BusyAction = 'cancel';
                
                % Create name label to the left of the sliders
                app.SliderLabels.(varNames{ii}) = uilabel(app.UIFigure);
                app.SliderLabels.(varNames{ii}).Position(1) = x(1);
                app.SliderLabels.(varNames{ii}).Position(2) = y(numel(varNames)+1-ii);
                app.SliderLabels.(varNames{ii}).Position(3) = x(5)-x(1);
                app.SliderLabels.(varNames{ii}).HorizontalAlignment = 'right';
                app.SliderLabels.(varNames{ii}).Text = p.(varNames{ii}).symbol;
                app.SliderLabels.(varNames{ii}).VerticalAlignment = 'bottom';
                app.SliderLabels.(varNames{ii}).Tooltip = p.(varNames{ii}).description;
                
                % Create value label to the right hand side
                app.ValueLabels.(varNames{ii}) = uilabel(app.UIFigure);
                app.ValueLabels.(varNames{ii}).Position(1) = x(25);
                app.ValueLabels.(varNames{ii}).Position(2) = y(numel(varNames)+1-ii);
                app.ValueLabels.(varNames{ii}).Position(3) = x(28)-x(25);
                app.ValueLabels.(varNames{ii}).HorizontalAlignment = 'right';
                app.ValueLabels.(varNames{ii}).Text = num2str(p.(varNames{ii}).default);
                app.ValueLabels.(varNames{ii}).VerticalAlignment = 'bottom';
                app.ValueLabels.(varNames{ii}).Tooltip = p.(varNames{ii}).description;
                
                % Create unit label to the right hand side
                app.UnitLabels.(varNames{ii}) = uilabel(app.UIFigure);
                app.UnitLabels.(varNames{ii}).Position(1) = x(28);
                app.UnitLabels.(varNames{ii}).Position(2) = y(numel(varNames)+1-ii);
                app.UnitLabels.(varNames{ii}).Position(3) = x(30)-x(28);
                app.UnitLabels.(varNames{ii}).HorizontalAlignment = 'left';
                app.UnitLabels.(varNames{ii}).Text = [' [' p.(varNames{ii}).unit ']'];
                app.UnitLabels.(varNames{ii}).VerticalAlignment = 'bottom';
                app.UnitLabels.(varNames{ii}).Tooltip = p.(varNames{ii}).unit;
            end
            
            % Initialize the plots with the values from the sliders
            updatePlots(app)
        end
    end
    
    % App creation and deletion
    methods (Access = public)
        
        % Construct app
        function app = ARStudy
            
            % Create UIFigure and components
            createComponents(app)
            
            % Register the app with App Designer
            registerApp(app, app.UIFigure)
            
            if nargout == 0
                clear app
            end
        end
        
        % Code that executes before app deletion
        function delete(app)
            
            % Delete UIFigure when app is deleted
            delete(app.UIFigure)
        end
        
        % Code to update the plots
        function updatePlots(app)
            updatePowerPlot(app);
        end
        
        % Code to update the plot of power
        function updatePowerPlot(app)
            % Extract parameter values
            ARw = app.PowerPlot.Plot.XData(:);
            paramNames = fieldnames(app.Sliders);
            for ii = 1:numel(paramNames)
                eval(sprintf('%s = app.Sliders.%s.Value;',paramNames{ii},paramNames{ii}))
            end
            
            % Udate text sliders
            for ii = 1:numel(paramNames)
                app.ValueLabels.(paramNames{ii}).Text = num2str(app.Sliders.(paramNames{ii}).Value);
            end
            
            % Calculate at the optimal alpha (this repeats a lot of the
            % code above, this could be optimized)
            a = sort(cat(2,(pi/180)*alphaw,(pi/180).*linspace(1,30) ));
            [a,ARw] = meshgrid(a,ARw);
            
            Sw = (bw.^2)./ARw;
            Sh = (bh.^2)./ARh;
            Sf = pi*rf.^2;
            
            CLaw = 2*pi*gammaw./(1+((2.*pi.*gammaw)./(pi.*eLw.*ARw)));
            CLah = 2*pi*gammah./(1+((2.*pi.*gammah)./(pi.*eLh.*ARh)));
            
            CLw =            CLaw.*a + CLa0w;
            CLh = (Sh./Sw).*(CLah.*a + CLa0h);
            
            CDw =            CD0w + (CLw.^2)./(pi*eDw.*ARw);
            CDh = (Sh./Sw).*(CD0h + (CLh.^2)./(pi*eDh.*ARh));
            CDf = (Sf./Sw).*(CD0f + CDaf*a.^2);
            
            CL = CLw + CLh;
            CD = CDw + CDh + CDf;
            
            P = 0.001*(2/27).*eta.*1000.*vw.^3.*Sw.*(CL.^3)./(CD.^2);
            
            % Convert angles of attack back to degrees
            a = a*180/pi;
            
            % Update surface plot
            app.PowerSurf.Surf.XData = a;
            app.PowerSurf.Surf.YData = ARw;
            app.PowerSurf.Surf.ZData = P;
            
            % Find max over all alphas and plot
            maxPOverAlpha = max(P,[],2);
            app.OptPowerPlot.Plot.XData = ARw(:,1);
            app.OptPowerPlot.Plot.YData = maxPOverAlpha;
            
            % Find user-specified value and plot
            mask = (a == app.Sliders.alphaw.Value);
            app.PowerPlot.Plot.XData = ARw(:,1);
            app.PowerPlot.Plot.YData = P(mask);

            % Get plot limits and update opimal markers
            xLims = app.PowerAxes.XLim;
            yLims = app.PowerAxes.YLim;
            
            % Update marker lines
            [PwrOptUsr,AROptIndUsr] = max(app.PowerPlot.Plot.YData);
            AROptUsr = app.PowerPlot.Plot.XData(AROptIndUsr);
            
            [PwrOptOpr,AROptOprInd] = max(app.OptPowerPlot.Plot.YData);
            AROptOpt = app.OptPowerPlot.Plot.XData(AROptOprInd);
            
            app.PowerPlot.OptMarker.XData = [xLims(1) AROptUsr AROptUsr];
            app.PowerPlot.OptMarker.YData = [PwrOptUsr PwrOptUsr yLims(1)];
            
            app.OptPowerPlot.OptMarker.XData = [xLims(1) AROptOpt AROptOpt];
            app.OptPowerPlot.OptMarker.YData = [PwrOptOpr PwrOptOpr yLims(1)];
            
            % Make new titles to reflect numerical data
            app.PowerPlot.Title.Interpreter = 'tex';
            app.PowerPlot.Title.String = ...
                {['(',num2str(AROptUsr,3),', ',num2str(PwrOptUsr,3),' kW), ',...
                sprintf('\\color[rgb]{%f, %f, %f}%s', [0.8 0 0], ['(',num2str(AROptOpt,3),', ',num2str(PwrOptOpr,3),' kW)'])]};
             app.PowerPlot.Title.Interpreter = 'tex';
             
             
            drawnow
        end
        
    end
end