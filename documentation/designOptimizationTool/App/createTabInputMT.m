function createTabInputMT(app)
            listInputVarsMT;

            T = 'MT';            

            fontSize = 20;
            x = 120; y = 700;
            
            app.Labels.SlidSwitch = uilabel(app.UITabs.(T));
            app.Labels.SlidSwitch.Text = 'Aspect Ratio';
            app.Labels.SlidSwitch.Position = [x y 320 30];
            app.Labels.SlidSwitch.FontSize = fontSize;
            
            
            width = 130; height = 25;
            x = x-80;y = y -30;
            for varind = 1:2
                fontSize = 14;
                %Create input box labels
                app.Labels.(varNamesMTinputs{varind}) = uilabel(app.UITabs.(T));
                app.Labels.(varNamesMTinputs{varind}).Parent = app.UITabs.(T);              
                app.Labels.(varNamesMTinputs{varind}).Text = join([varMTinputs.(varNamesMTinputs{varind}).symbol,' (',varMTinputs.(varNamesMTinputs{varind}).unit,')']);
                app.Labels.(varNamesMTinputs{varind}).Position = [x y width height];
                app.Labels.(varNamesMTinputs{varind}).FontSize = fontSize;
                
                
                x = x-5; y = y -25;
                % Creating input boxes
                app.InputBoxs.(varNamesMTinputs{varind}) = uieditfield(app.UITabs.(T),'numeric');
                app.InputBoxs.(varNamesMTinputs{varind}).Parent = app.UITabs.(T);
                app.InputBoxs.(varNamesMTinputs{varind}).Position = [x y width height];
                app.InputBoxs.(varNamesMTinputs{varind}).Limits = [varMTinputs.(varNamesMTinputs{varind}).min varMTinputs.(varNamesMTinputs{varind}).max];
                app.InputBoxs.(varNamesMTinputs{varind}).Value = varMTinputs.(varNamesMTinputs{varind}).default;
                app.InputBoxs.(varNamesMTinputs{varind}).FontSize = fontSize;
                
                x = x+ 180;y = y + 25;
                
            end
            
            fontSize = 20;
            x = x - 250; y = y - 70;
            
            app.Labels.SlidSwitch = uilabel(app.UITabs.(T));
            app.Labels.SlidSwitch.Text = 'Wing Span';
            app.Labels.SlidSwitch.Position = [x y 320 30];
            app.Labels.SlidSwitch.FontSize = fontSize;
            fontSize = 16;
            
            x = x-100;y = y -30;
            for varind = 3:4
                fontSize = 14;
                %Create input box labels
                app.Labels.(varNamesMTinputs{varind}) = uilabel(app.UITabs.(T));
                app.Labels.(varNamesMTinputs{varind}).Parent = app.UITabs.(T);
                app.Labels.(varNamesMTinputs{varind}).Text = join([varMTinputs.(varNamesMTinputs{varind}).symbol,' (',varMTinputs.(varNamesMTinputs{varind}).unit,')']);
                app.Labels.(varNamesMTinputs{varind}).Position = [x y width height];
                app.Labels.(varNamesMTinputs{varind}).FontSize = fontSize;
                
                
                x = x-5; y = y -25;
                % Creating input boxes
                app.InputBoxs.(varNamesMTinputs{varind}) = uieditfield(app.UITabs.(T),'numeric');
                app.InputBoxs.(varNamesMTinputs{varind}).Parent = app.UITabs.(T);
                app.InputBoxs.(varNamesMTinputs{varind}).Position = [x y width height];
                app.InputBoxs.(varNamesMTinputs{varind}).Limits = [varMTinputs.(varNamesMTinputs{varind}).min varMTinputs.(varNamesMTinputs{varind}).max];
                app.InputBoxs.(varNamesMTinputs{varind}).Value = varMTinputs.(varNamesMTinputs{varind}).default;
                app.InputBoxs.(varNamesMTinputs{varind}).FontSize = fontSize;
                
                x = x+ 180;y = y + 25;
                
            end
            
            x = x - 320; y = y - 30;
            fontSize = 20;
            SlidSwitch  = 'OptiType';            
            x = x+5; y = y- 60;
            app.Labels.SlidSwitch = uilabel(app.UITabs.(T));
            app.Labels.SlidSwitch.Text = 'Type of Optimization';
            app.Labels.SlidSwitch.Position = [x y 320 30];
            app.Labels.SlidSwitch.FontSize = fontSize;
            
            x = x +70;y = y -40;
            fontSize = 20;
            app.SliderSwitch.SlidSwitch = uiswitch(app.UITabs.(T));
            app.SliderSwitch.SlidSwitch.Items = {'Max Power','Min Volume'};
            app.SliderSwitch.SlidSwitch.Position = [x y 60 60];
            app.SliderSwitch.SlidSwitch.FontSize = fontSize;
            app.SliderSwitch.SlidSwitch.Value = {'Min Volume'};
            
            width = 130; height = 25;
            x = x - 50;y = y -70;
            
            for varind = 5:(length(varNamesMTinputs))
                % Creating labels for inputs boxes
                fontSize = 14;
                app.Labels.(varNamesMTinputs{varind}) = uilabel(app.UITabs.(T));
                app.Labels.(varNamesMTinputs{varind}).Parent = app.UITabs.(T);
                app.Labels.(varNamesMTinputs{varind}).Text = join([varMTinputs.(varNamesMTinputs{varind}).symbol,' (',varMTinputs.(varNamesMTinputs{varind}).unit,')']);;
                app.Labels.(varNamesMTinputs{varind}).Position = [x y width+50 height];
                app.Labels.(varNamesMTinputs{varind}).FontSize = fontSize;
                
                
                x = x-5; y = y-25;
                % Creating input boxes
                app.InputBoxs.(varNamesMTinputs{varind}) = uieditfield(app.UITabs.(T),'numeric');
                app.InputBoxs.(varNamesMTinputs{varind}).Parent = app.UITabs.(T);
                app.InputBoxs.(varNamesMTinputs{varind}).Position = [x y width height];
                app.InputBoxs.(varNamesMTinputs{varind}).Limits = [varMTinputs.(varNamesMTinputs{varind}).min varMTinputs.(varNamesMTinputs{varind}).max];
                app.InputBoxs.(varNamesMTinputs{varind}).Value = varMTinputs.(varNamesMTinputs{varind}).default;
                app.InputBoxs.(varNamesMTinputs{varind}).FontSize = fontSize;
                
                x = x+5; y = y- 40;

            end
            
            % Run Button for overall Optimization
            Bttn = 'RunMT';
            app.Buttons.Bttn = uibutton(app.UITabs.(T));
            app.Buttons.Bttn.Text = ('Run');
            app.Buttons.Bttn.Position = [700 50 120 40];
            app.Buttons.Bttn.FontSize = 20;
            app.Buttons.Bttn.FontName = 'Arial Narrow';
            app.Buttons.Bttn.ButtonPushedFcn = @(btn,event) runOptimization(app);
            
            
        end
