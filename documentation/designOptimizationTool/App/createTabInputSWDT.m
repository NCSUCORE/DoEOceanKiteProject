        function createTabInputSWDT(app)
            listInputVarsSWDT;
            
            %-----------------------------------------------------------
            %Tab Name
            T = 'SWDT';
            fontSize = 20;
            width = 130; height = 25;
            x = 40; y = 700;
            
            app.Labels.DDwown = uilabel(app.UITabs.(T));
            app.Labels.DDwown.Text = 'User Inputs';
            app.Labels.DDwown.Position = [x y 320 25];
            app.Labels.DDwown.FontSize = fontSize;
            
            fontSize = 14;
            DDown = 'Material';
            
            y = y-35;
            app.Labels.DDwown = uilabel(app.UITabs.(T));
            app.Labels.DDwown.Text = 'Choose Material of Wing';
            app.Labels.DDwown.Position = [x y 320 25];
            app.Labels.DDwown.FontSize = fontSize;
            
            y = y -35;
            app.DropDownBox.SlidSwitch = uidropdown(app.UITabs.(T));
            app.DropDownBox.SlidSwitch.Items = {'Steel','Aluminum'};
            app.DropDownBox.SlidSwitch.Position = [x y 100 30];
            app.DropDownBox.SlidSwitch.FontSize = fontSize;
            app.DropDownBox.SlidSwitch.Items = {'Aluminum'};
            
            DDown = 'NumSpars';
            y = y -35;
            app.Labels.DDwown = uilabel(app.UITabs.(T));
            app.Labels.DDwown.Text = 'Number of Spars';
            app.Labels.DDwown.Position = [x y 320 25];
            app.Labels.DDwown.FontSize = fontSize;
            
            y = y -35;
            app.DropDownBox.SlidSwitch = uidropdown(app.UITabs.(T));
            app.DropDownBox.SlidSwitch.Items = {'1','2','3'};
            app.DropDownBox.SlidSwitch.Position = [x y 100 30];
            app.DropDownBox.SlidSwitch.FontSize = fontSize;
            app.DropDownBox.SlidSwitch.Value = {'3'};
            
            InBox = 'MaxThickSpar';
            y = y -35;
            app.Labels.InBox = uilabel(app.UITabs.(T));
            app.Labels.InBox.Text = 'Maximum % Thickness of Spars';
            app.Labels.InBox.Position = [x  y 320 25];
            app.Labels.InBox.FontSize = fontSize;
            
            y = y -35;
            app.InputBoxs.InBox = uieditfield(app.UITabs.(T),'numeric');
            app.InputBoxs.InBox.Position = [x y 60 25];
            app.InputBoxs.InBox.Value = 10;
            app.InputBoxs.InBox.FontSize = fontSize;
            
            Slid = varNamesSWDT{1}; 
            y = y -35;
            app.Labels.(varNamesSWDT{1}) = uilabel(app.UITabs.(T));
            app.Labels.(varNamesSWDT{1}).Text = 'Maximum % Wing Deflection';
            app.Labels.(varNamesSWDT{1}).Position = [x  y 320 25];
            app.Labels.(varNamesSWDT{1}).FontSize = fontSize;
            
            y = y -20;
            ticks = linspace(0,20,9);
            app.Sliders.(varNamesSWDT{1}) = uislider(app.UITabs.(T));
            app.Sliders.(varNamesSWDT{1}).Position = [x y width+50 height+5];
            app.Sliders.(varNamesSWDT{1}).Limits = [0 20];
            app.Sliders.(varNamesSWDT{1}).Value = 5;
            app.Sliders.(varNamesSWDT{1}).MajorTicks = ticks(1:2:end);
            app.Sliders.(varNamesSWDT{1}).MinorTicks = ticks(2:2:end);
%             app.Sliders.Slid.Tooltip = varSWDT.(varNamesSWDT{varind}).description;
            
            
            fontSize = 20;
            y = y -80;
            app.Labels.DDwown = uilabel(app.UITabs.(T));
            app.Labels.DDwown.Text = 'From SFOT';
            app.Labels.DDwown.Position = [x y 320 25];
            app.Labels.DDwown.FontSize = fontSize;
            
            % Input box/slider dimensions and location
            
            fontSize = 14;
            y = y - 30;
            
            for varind = 2:(length(varNamesSWDT))
                % Creating labels for inputs boxes
                app.Labels.(varNamesSWDT{varind}) = uilabel(app.UITabs.(T));
                app.Labels.(varNamesSWDT{varind}).Text = varSWDT.(varNamesSWDT{varind}).symbol;
                app.Labels.(varNamesSWDT{varind}).Position = [x y width height];
                app.Labels.(varNamesSWDT{varind}).FontSize = fontSize;
                
                x = x-5; y = y-25;
                % Creating input boxes
                app.InputBoxs.(varNamesSWDT{varind}) = uieditfield(app.UITabs.(T),'numeric');
                app.InputBoxs.(varNamesSWDT{varind}).Position = [x y width height];
                app.InputBoxs.(varNamesSWDT{varind}).Limits = [varSWDT.(varNamesSWDT{varind}).min varSWDT.(varNamesSWDT{varind}).max];
                app.InputBoxs.(varNamesSWDT{varind}).Value = varSWDT.(varNamesSWDT{varind}).default;
                
                x = x+5; y = y- 30;

            end
            
            % Run Button for overall Optimization
            Bttn = 'RunSWDT';
            app.Buttons.Bttn = uibutton(app.UITabs.(T));
            app.Buttons.Bttn.Text = ('Run Tab');
            app.Buttons.Bttn.Position = [700 50 120 40];
            app.Buttons.Bttn.FontSize = 20;
            app.Buttons.Bttn.FontName = 'Arial Narrow';
            
        end
   