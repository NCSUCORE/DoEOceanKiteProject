classdef app1 < matlab.apps.AppBase
    
    % Properties that correspond to app components
    properties (Access = public)
        UIFigure                matlab.ui.Figure
        GridLayout              matlab.ui.container.GridLayout
        LeftPanel               matlab.ui.container.Panel
        MassSliderLabel         matlab.ui.control.Label
        MassSlider              matlab.ui.control.Slider
        BFSliderLabel           matlab.ui.control.Label
        BFSlider                matlab.ui.control.Slider
        FlowspeedSliderLabel    matlab.ui.control.Label
        FlowspeedSlider         matlab.ui.control.Slider
        KitespeedSliderLabel    matlab.ui.control.Label
        KitespeedSlider         matlab.ui.control.Slider
        AzimuthSliderLabel      matlab.ui.control.Label
        AzimuthSlider           matlab.ui.control.Slider
        ElevationSliderLabel    matlab.ui.control.Label
        ElevationSlider         matlab.ui.control.Slider
        HeadingSliderLabel      matlab.ui.control.Label
        HeadingSlider           matlab.ui.control.Slider
        xCBSliderLabel          matlab.ui.control.Label
        xCBSlider               matlab.ui.control.Slider
        xWingSliderLabel        matlab.ui.control.Label
        xWingSlider             matlab.ui.control.Slider
        xHstabSliderLabel       matlab.ui.control.Label
        xHstabSlider            matlab.ui.control.Slider
        zBridleSliderLabel      matlab.ui.control.Label
        zBridleSlider           matlab.ui.control.Slider
        elevatorDefSliderLabel  matlab.ui.control.Label
        elevatorDefSlider       matlab.ui.control.Slider
        RightPanel              matlab.ui.container.Panel
        buoyPlot                matlab.ui.control.UIAxes
        wingPlot                matlab.ui.control.UIAxes
        hstabPlot               matlab.ui.control.UIAxes
        thrPlot                 matlab.ui.control.UIAxes
        sumPlot                 matlab.ui.control.UIAxes
        AoAPlot                 matlab.ui.control.UIAxes
    end
    
    % Properties that correspond to apps with auto-reflow
    properties (Access = private)
        onePanelWidth = 576;
    end
    
    
    methods (Access = public)
        
        function results = func(app)
            % get all values from slides
            mass = app.MassSlider.Value;
            BF = app.BFSlider.Value;
            vFlow = app.FlowspeedSlider.Value;
            vKite = app.KitespeedSlider.Value;
            azimuth = app.AzimuthSlider.Value;
            elevation = app.ElevationSlider.Value;
            heading = app.HeadingSlider.Value;
            xCB = app.xCBSlider.Value;
            xWing = app.xWingSlider.Value;
            xhstab = app.xHstabSlider.Value;
            zbridle = app.zBridleSlider.Value;
            dElev = app.elevatorDefSlider.Value;
            
            gravAcc = 9.81;
            % fluid density
            density = 1e3;
            
            % wing
            wing.span = 10;                 % span
            wing.aspectRatio = 10;          % aspect ratio
            wing.oswaldEff = 0.8;           % oswald efficient < 1
            wing.ZeroAoALift = 0.1;         % zero angle of attack lift
            wing.ZeroAoADrag = 0.01;        % zero angle of attack drag
            
            % horizontal stabilizer
            hstab.span = 5;                 % span
            hstab.aspectRatio = 10;         % aspect ratio
            hstab.oswaldEff = 0.8;          % oswald efficient < 1
            hstab.ZeroAoALift = 0.0;        % zero angle of attack lift
            hstab.ZeroAoADrag = 0.01;       % zero angle of attack drag
            hstab.dcLbydElevator = 0.08;    % change in hstab CL per deg deflection of elevator           
            
            tangentPitch = (180/pi)*linspace(-30,30,100);
            
            % preallocate matrices
            mBuoy = NaN*tangentPitch;
            
            for ii = 1:numel(tangentPitch)
                
                op = pitchStatibilityAnalysis(vFlow,vKite,...
                    xCB,xWing,xhstab,...
                    zbridle,elevation,azimuth,tangentPitch(ii),heading,...
                    mass,gravAcc,density,BF,wing,hstab,dElev);
                % allot outputs
                mBuoy(ii) = op.buoyPitchMoment;
                
            end
            
            app.buoyPlot.Plot = plot(tangentPitch,mBuoy);
            
        end
    end
    
    
    % Callbacks that handle component events
    methods (Access = private)
        
        % Changes arrangement of the app based on UIFigure width
        function updateAppLayout(app, event)
            currentFigureWidth = app.UIFigure.Position(3);
            if(currentFigureWidth <= app.onePanelWidth)
                % Change to a 2x1 grid
                app.GridLayout.RowHeight = {763, 763};
                app.GridLayout.ColumnWidth = {'1x'};
                app.RightPanel.Layout.Row = 2;
                app.RightPanel.Layout.Column = 1;
            else
                % Change to a 1x2 grid
                app.GridLayout.RowHeight = {'1x'};
                app.GridLayout.ColumnWidth = {267, '1x'};
                app.RightPanel.Layout.Row = 1;
                app.RightPanel.Layout.Column = 2;
            end
        end
    end
    
    % Component initialization
    methods (Access = private)
        
        % Create UIFigure and components
        function createComponents(app)
            
            % Create UIFigure and hide until all components are created
            app.UIFigure = uifigure('Visible', 'off');
            app.UIFigure.AutoResizeChildren = 'off';
            app.UIFigure.Color = [0.94 0.94 0.94];
            app.UIFigure.Position = [100 100 1047 763];
            app.UIFigure.Name = 'MATLAB App';
            app.UIFigure.SizeChangedFcn = createCallbackFcn(app, @updateAppLayout, true);
            
            % Create GridLayout
            app.GridLayout = uigridlayout(app.UIFigure);
            app.GridLayout.ColumnWidth = {267, '1x'};
            app.GridLayout.RowHeight = {'1x'};
            app.GridLayout.ColumnSpacing = 0;
            app.GridLayout.RowSpacing = 0;
            app.GridLayout.Padding = [0 0 0 0];
            app.GridLayout.Scrollable = 'on';
            
            % Create LeftPanel
            app.LeftPanel = uipanel(app.GridLayout);
            app.LeftPanel.Layout.Row = 1;
            app.LeftPanel.Layout.Column = 1;
            
            % Create MassSliderLabel
            app.MassSliderLabel = uilabel(app.LeftPanel);
            app.MassSliderLabel.HorizontalAlignment = 'right';
            app.MassSliderLabel.Position = [39 729 34 22];
            app.MassSliderLabel.Text = 'Mass';
            
            % Create MassSlider
            app.MassSlider = uislider(app.LeftPanel);
            app.MassSlider.Position = [94 738 150 3];
            
            % Create BFSliderLabel
            app.BFSliderLabel = uilabel(app.LeftPanel);
            app.BFSliderLabel.HorizontalAlignment = 'right';
            app.BFSliderLabel.Position = [48 687 25 22];
            app.BFSliderLabel.Text = 'BF';
            
            % Create BFSlider
            app.BFSlider = uislider(app.LeftPanel);
            app.BFSlider.Position = [94 696 150 3];
            
            % Create FlowspeedSliderLabel
            app.FlowspeedSliderLabel = uilabel(app.LeftPanel);
            app.FlowspeedSliderLabel.HorizontalAlignment = 'right';
            app.FlowspeedSliderLabel.Position = [6 645 67 22];
            app.FlowspeedSliderLabel.Text = 'Flow speed';
            
            % Create FlowspeedSlider
            app.FlowspeedSlider = uislider(app.LeftPanel);
            app.FlowspeedSlider.Position = [94 654 150 3];
            
            % Create KitespeedSliderLabel
            app.KitespeedSliderLabel = uilabel(app.LeftPanel);
            app.KitespeedSliderLabel.HorizontalAlignment = 'right';
            app.KitespeedSliderLabel.Position = [6 603 67 22];
            app.KitespeedSliderLabel.Text = 'Kite speed';
            
            % Create KitespeedSlider
            app.KitespeedSlider = uislider(app.LeftPanel);
            app.KitespeedSlider.Position = [94 612 150 3];
            
            % Create AzimuthSliderLabel
            app.AzimuthSliderLabel = uilabel(app.LeftPanel);
            app.AzimuthSliderLabel.HorizontalAlignment = 'right';
            app.AzimuthSliderLabel.Position = [6 561 67 22];
            app.AzimuthSliderLabel.Text = 'Azimuth';
            
            % Create AzimuthSlider
            app.AzimuthSlider = uislider(app.LeftPanel);
            app.AzimuthSlider.Position = [94 570 150 3];
            
            % Create ElevationSliderLabel
            app.ElevationSliderLabel = uilabel(app.LeftPanel);
            app.ElevationSliderLabel.HorizontalAlignment = 'right';
            app.ElevationSliderLabel.Position = [11 519 62 22];
            app.ElevationSliderLabel.Text = 'Elevation';
            
            % Create ElevationSlider
            app.ElevationSlider = uislider(app.LeftPanel);
            app.ElevationSlider.Position = [94 528 150 3];
            
            % Create HeadingSliderLabel
            app.HeadingSliderLabel = uilabel(app.LeftPanel);
            app.HeadingSliderLabel.HorizontalAlignment = 'right';
            app.HeadingSliderLabel.Position = [6 477 67 22];
            app.HeadingSliderLabel.Text = 'Heading';
            
            % Create HeadingSlider
            app.HeadingSlider = uislider(app.LeftPanel);
            app.HeadingSlider.Position = [94 486 150 3];
            
            % Create xCBSliderLabel
            app.xCBSliderLabel = uilabel(app.LeftPanel);
            app.xCBSliderLabel.HorizontalAlignment = 'right';
            app.xCBSliderLabel.Position = [6 435 67 22];
            app.xCBSliderLabel.Text = 'xCB';
            
            % Create xCBSlider
            app.xCBSlider = uislider(app.LeftPanel);
            app.xCBSlider.Position = [94 444 150 3];
            
            % Create xWingSliderLabel
            app.xWingSliderLabel = uilabel(app.LeftPanel);
            app.xWingSliderLabel.HorizontalAlignment = 'right';
            app.xWingSliderLabel.Position = [6 393 67 22];
            app.xWingSliderLabel.Text = 'xWing';
            
            % Create xWingSlider
            app.xWingSlider = uislider(app.LeftPanel);
            app.xWingSlider.Position = [94 402 150 3];
            
            % Create xHstabSliderLabel
            app.xHstabSliderLabel = uilabel(app.LeftPanel);
            app.xHstabSliderLabel.HorizontalAlignment = 'right';
            app.xHstabSliderLabel.Position = [6 351 67 22];
            app.xHstabSliderLabel.Text = 'xHstab';
            
            % Create xHstabSlider
            app.xHstabSlider = uislider(app.LeftPanel);
            app.xHstabSlider.Position = [94 360 150 3];
            
            % Create zBridleSliderLabel
            app.zBridleSliderLabel = uilabel(app.LeftPanel);
            app.zBridleSliderLabel.HorizontalAlignment = 'right';
            app.zBridleSliderLabel.Position = [6 309 67 22];
            app.zBridleSliderLabel.Text = 'zBridle';
            
            % Create zBridleSlider
            app.zBridleSlider = uislider(app.LeftPanel);
            app.zBridleSlider.Position = [94 318 150 3];
            
            % Create elevatorDefSliderLabel
            app.elevatorDefSliderLabel = uilabel(app.LeftPanel);
            app.elevatorDefSliderLabel.HorizontalAlignment = 'right';
            app.elevatorDefSliderLabel.Position = [3 267 70 22];
            app.elevatorDefSliderLabel.Text = 'elevator Def';
            
            % Create elevatorDefSlider
            app.elevatorDefSlider = uislider(app.LeftPanel);
            app.elevatorDefSlider.Position = [94 276 150 3];
            
            % Create RightPanel
            app.RightPanel = uipanel(app.GridLayout);
            app.RightPanel.Layout.Row = 1;
            app.RightPanel.Layout.Column = 2;
            
            % Create buoyPlot
            app.buoyPlot = uiaxes(app.RightPanel);
            title(app.buoyPlot, 'Buyancy moment', 'Interpreter', 'latex')
            xlabel(app.buoyPlot, 'Tangent pitch angle (deg)', 'Interpreter', 'latex')
            ylabel(app.buoyPlot, 'M (N-m)', 'Interpreter', 'latex')
            app.buoyPlot.TickLabelInterpreter = 'tex';
            app.buoyPlot.Position = [1 577 300 185];
            
            % Create wingPlot
            app.wingPlot = uiaxes(app.RightPanel);
            title(app.wingPlot, 'Wing moment', 'Interpreter', 'latex')
            xlabel(app.wingPlot, 'Tangent pitch angle (deg)', 'Interpreter', 'latex')
            ylabel(app.wingPlot, 'M (N-m)', 'Interpreter', 'latex')
            app.wingPlot.TickLabelInterpreter = 'tex';
            app.wingPlot.Position = [315 577 300 185];
            
            % Create hstabPlot
            app.hstabPlot = uiaxes(app.RightPanel);
            title(app.hstabPlot, 'H-stab moment', 'Interpreter', 'latex')
            xlabel(app.hstabPlot, 'Tangent pitch angle (deg)', 'Interpreter', 'latex')
            ylabel(app.hstabPlot, 'M (N-m)', 'Interpreter', 'latex')
            app.hstabPlot.TickLabelInterpreter = 'tex';
            app.hstabPlot.Position = [1 377 300 185];
            
            % Create thrPlot
            app.thrPlot = uiaxes(app.RightPanel);
            title(app.thrPlot, 'Tether moment', 'Interpreter', 'latex')
            xlabel(app.thrPlot, 'Tangent pitch angle (deg)', 'Interpreter', 'latex')
            ylabel(app.thrPlot, 'M (N-m)', 'Interpreter', 'latex')
            app.thrPlot.TickLabelInterpreter = 'tex';
            app.thrPlot.Position = [316 377 300 185];
            
            % Create sumPlot
            app.sumPlot = uiaxes(app.RightPanel);
            title(app.sumPlot, 'Total moment', 'Interpreter', 'latex')
            xlabel(app.sumPlot, 'Tangent pitch angle (deg)', 'Interpreter', 'latex')
            ylabel(app.sumPlot, 'M (N-m)', 'Interpreter', 'latex')
            app.sumPlot.TickLabelInterpreter = 'tex';
            app.sumPlot.Position = [2 184 300 185];
            
            % Create AoAPlot
            app.AoAPlot = uiaxes(app.RightPanel);
            title(app.AoAPlot, 'Angle of attack', 'Interpreter', 'latex')
            xlabel(app.AoAPlot, 'Tangent pitch angle (deg)', 'Interpreter', 'latex')
            ylabel(app.AoAPlot, '$\alpha$ (deg)', 'Interpreter', 'latex')
            app.AoAPlot.TickLabelInterpreter = 'tex';
            app.AoAPlot.Position = [316 184 300 185];
            
            % Show the figure after all components are created
            app.UIFigure.Visible = 'on';
            
            func(app);
        end
    end
    
    % App creation and deletion
    methods (Access = public)
        
        % Construct app
        function app = app1
            
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
    end
end