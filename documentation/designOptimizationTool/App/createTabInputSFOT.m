       function createTabInputSFOT(app)
            
            listInputVarsSFOT;
           
           fontSize = 18;
            
            % ------------------------------------------------------
            T = 'SFOT';
            
            SlidSwitch = 'HydCoeff';
            
            app.Labels.SlidSwitch = uilabel(app.UITabs.(T));
            app.Labels.SlidSwitch.Text = 'Hydrodynamic Coefficients Values';
            app.Labels.SlidSwitch.Position = [30 700 320 25];
            app.Labels.SlidSwitch.FontSize = fontSize;
            
            
            app.SliderSwitch.SlidSwitch = uiswitch(app.UITabs.(T));
            app.SliderSwitch.SlidSwitch.Items = {'Predefined','Input'};
            app.SliderSwitch.SlidSwitch.Position = [130 670 40 40];
            app.SliderSwitch.SlidSwitch.FontSize = fontSize;
            app.SliderSwitch.SlidSwitch.Value = {'Input'};
            
            app.Labels.SlidSwitch = uilabel(app.UITabs.(T));
            app.Labels.SlidSwitch.Text = '________________________________';
            app.Labels.SlidSwitch.Position = [30 640 400 25];
            app.Labels.SlidSwitch.FontSize = fontSize;
            
            
            fontSize = 16;
            DDown = 'AirfoilDD';
            
            app.Labels.DDwown = uilabel(app.UITabs.(T));
            app.Labels.DDwown.Text = 'Choose Airfoil';
            app.Labels.DDwown.Position = [30 600 320 25];
            app.Labels.DDwown.FontSize = fontSize;
            
            app.DropDownBox.SlidSwitch = uidropdown(app.UITabs.(T));
            app.DropDownBox.SlidSwitch.Items = {'10%','12%','14%'};
            app.DropDownBox.SlidSwitch.Position = [30 560 100 30];
            app.DropDownBox.SlidSwitch.FontSize = fontSize;
            app.DropDownBox.SlidSwitch.Value = {'12%'};
            
            fontSize = 18;
            
            app.Labels.SlidSwitch = uilabel(app.UITabs.(T));
            app.Labels.SlidSwitch.Text = '________________________________';
            app.Labels.SlidSwitch.Position = [30 530 400 25];
            app.Labels.SlidSwitch.FontSize = fontSize;
            

            fontSize = 14;
            % Input box/slider dimensions and location
            width = 130; height = 25;
            x = 40;y = 480;
            
            for varind = 1:7
                % Creating labels for inputs boxes
                app.Labels.(varNamesSFOT{varind}) = uilabel(app.UITabs.(T));
                app.Labels.(varNamesSFOT{varind}).Text = varSFOT.(varNamesSFOT{varind}).symbol;
                app.Labels.(varNamesSFOT{varind}).Position = [x y width+50 height];
                app.Labels.(varNamesSFOT{varind}).FontSize = fontSize;
                
                x = x-5; y = y-25;
                % Creating input boxes
                app.InputBoxs.(varNamesSFOT{varind}) = uieditfield(app.UITabs.(T),'numeric');
                app.InputBoxs.(varNamesSFOT{varind}).Position = [x y width height];
                app.InputBoxs.(varNamesSFOT{varind}).Limits = [varSFOT.(varNamesSFOT{varind}).min varSFOT.(varNamesSFOT{varind}).max];
                app.InputBoxs.(varNamesSFOT{varind}).Value = varSFOT.(varNamesSFOT{varind}).default;
                
                x = x+5; y = y- 30;

            end
            
            y = 480; x = 300;       
            for varind = 8:length(varNamesSFOT)
                %Create labels for sliders
                app.Labels.(varNamesSFOT{varind}) = uilabel(app.UITabs.(T));
                app.Labels.(varNamesSFOT{varind}).Text = varSFOT.(varNamesSFOT{varind}).symbol;
                app.Labels.(varNamesSFOT{varind}).Position = [x y width+50 height];
                app.Labels.(varNamesSFOT{varind}).FontSize = fontSize;
                
                x = x-5; y = y-10;
                
                %Create sliders
                ticks = linspace(varSFOT.(varNamesSFOT{varind}).min,varSFOT.(varNamesSFOT{varind}).max,9);
                app.Sliders.(varNamesSFOT{varind}) = uislider(app.UITabs.(T));
                app.Sliders.(varNamesSFOT{varind}).Position = [x y width+50 height] ;
                app.Sliders.(varNamesSFOT{varind}).Limits = [varSFOT.(varNamesSFOT{varind}).min varSFOT.(varNamesSFOT{varind}).max];
                app.Sliders.(varNamesSFOT{varind}).Value = varSFOT.(varNamesSFOT{varind}).default;
                app.Sliders.(varNamesSFOT{varind}).MajorTicks = ticks(1:2:end);
                app.Sliders.(varNamesSFOT{varind}).MinorTicks = ticks(2:2:end);
                app.Sliders.(varNamesSFOT{varind}).Tooltip = varSFOT.(varNamesSFOT{varind}).description;
                
                x = x+5; y = y- 60;
            end
            
            
            % Run Button for overall Optimization
            Bttn = 'RunSFOT';
            app.Buttons.Bttn = uibutton(app.UITabs.(T));
            app.Buttons.Bttn.Text = ('Run Tab');
            app.Buttons.Bttn.Position = [700 50 120 40];
            app.Buttons.Bttn.FontSize = 20;
            app.Buttons.Bttn.FontName = 'Arial Narrow';

            
        end