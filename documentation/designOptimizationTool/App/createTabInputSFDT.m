        function createTabInputSFDT(app)
            listInputVarsSFDT;
            
            %-----------------------------------------------------------
            %Tab Name
            T = 'SFDT';
            fontSize = 20;
            width = 130; height = 25;
            x = 50; y = 700;
            
            Label = 'UserIn';
            app.Labels.Label = uilabel(app.UITabs.(T));
            app.Labels.Label.Text = 'User Inputs';
            app.Labels.Label.Position = [x y 320 25];
            app.Labels.Label.FontSize = fontSize;
            
            fontSize = 14;
            
%             app.Labels.DDwown = uilabel(app.UITabs.(T));
%             app.Labels.DDwown.Text = 'User Inputs';
%             app.Labels.DDwown.Position = [x y 320 25];
%             app.Labels.DDwown.FontSize = fontSize;
%             
%             fontSize = 14;
%             DDown = 'Material';
%             
%             y = y-35;
%             app.Labels.DDwown = uilabel(app.UITabs.(T));
%             app.Labels.DDwown.Text = 'Choose Material of Wing';
%             app.Labels.DDwown.Position = [x y 320 25];
%             app.Labels.DDwown.FontSize = fontSize;
%             
%             y = y -35;
%             app.DropDownBox.SlidSwitch = uidropdown(app.UITabs.(T));
%             app.DropDownBox.SlidSwitch.Items = {'Steel','Aluminum'};
%             app.DropDownBox.SlidSwitch.Position = [x y 100 30];
%             app.DropDownBox.SlidSwitch.FontSize = fontSize;
%             
%             DDown = 'NumSpars';
%             y = y -35;
%             app.Labels.DDwown = uilabel(app.UITabs.(T));
%             app.Labels.DDwown.Text = 'Number of Spars';
%             app.Labels.DDwown.Position = [x y 320 25];
%             app.Labels.DDwown.FontSize = fontSize;
%             
%             y = y -35;
%             app.DropDownBox.SlidSwitch = uidropdown(app.UITabs.(T));
%             app.DropDownBox.SlidSwitch.Items = {'1','2','3'};
%             app.DropDownBox.SlidSwitch.Position = [x y 100 30];
%             app.DropDownBox.SlidSwitch.FontSize = fontSize;
%             
%             InBox = 'MaxThickSpar';
%             y = y -35;
%             app.Labels.InBox = uilabel(app.UITabs.(T));
%             app.Labels.InBox.Text = 'Maximum % Thickness of Spars';
%             app.Labels.InBox.Position = [x  y 320 25];
%             app.Labels.InBox.FontSize = fontSize;
%             
%             y = y -35;
%             app.InputBoxs.InBox = uieditfield(app.UITabs.(T),'numeric');
%             app.InputBoxs.InBox.Position = [x y 60 25];
%             app.InputBoxs.InBox.Value = 10;
%             app.InputBoxs.InBox.FontSize = fontSize;
%             
%             Slid = 'WingDef'; 
%             y = y -35;
%             app.Labels.InBox = uilabel(app.UITabs.(T));
%             app.Labels.InBox.Text = 'Maximum % Wing Deflection';
%             app.Labels.InBox.Position = [x  y 320 25];
%             app.Labels.InBox.FontSize = fontSize;
%             
%             y = y -20;
%             ticks = linspace(0,20,9);
%             app.Sliders.Slid = uislider(app.UITabs.(T));
%             app.Sliders.Slid.Position = [x y width+50 height+5];
%             app.Sliders.Slid.Limits = [0 20];
%             app.Sliders.Slid.Value = 5;
%             app.Sliders.Slid.MajorTicks = ticks(1:2:end);
%             app.Sliders.Slid.MinorTicks = ticks(2:2:end);
% %             app.Sliders.Slid.Tooltip = varSWDT.(varNamesSWDT{varind}).description;
%             
%             
%             fontSize = 20;
%             y = y -80;
%             app.Labels.DDwown = uilabel(app.UITabs.(T));
%             app.Labels.DDwown.Text = 'From SFOT';
%             app.Labels.DDwown.Position = [x y 320 25];
%             app.Labels.DDwown.FontSize = fontSize;
%             
%             % Input box/slider dimensions and location
%             
%             fontSize = 14;
%             y = y - 30;
            
            y = y - 40;
            for varind = 1:(length(varNamesSFDT))
                % Creating labels for inputs boxes
                app.Labels.(varNamesSFDT{varind}) = uilabel(app.UITabs.(T));
                app.Labels.(varNamesSFDT{varind}).Text = varSFDT.(varNamesSFDT{varind}).symbol;
                app.Labels.(varNamesSFDT{varind}).Position = [x y width+50 height];
                app.Labels.(varNamesSFDT{varind}).FontSize = fontSize;
                
                x = x-5; y = y-25;
                % Creating input boxes
                app.InputBoxs.(varNamesSFDT{varind}) = uieditfield(app.UITabs.(T),'numeric');
                app.InputBoxs.(varNamesSFDT{varind}).Position = [x y width height];
                app.InputBoxs.(varNamesSFDT{varind}).Limits = [varSFDT.(varNamesSFDT{varind}).min varSFDT.(varNamesSFDT{varind}).max];
                app.InputBoxs.(varNamesSFDT{varind}).Value = varSFDT.(varNamesSFDT{varind}).default;
                
                x = x+5; y = y- 35;

            end
            
            % Run Button for overall Optimization
            Bttn = 'RunSWDT';
            app.Buttons.Bttn = uibutton(app.UITabs.(T));
            app.Buttons.Bttn.Text = ('Run Tab');
            app.Buttons.Bttn.Position = [700 50 120 40];
            app.Buttons.Bttn.FontSize = 20;
            app.Buttons.Bttn.FontName = 'Arial Narrow';
            
        end
   