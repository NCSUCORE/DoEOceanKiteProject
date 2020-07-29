classdef signalcontainer < dynamicprops
    %SIGNALCONTAINER Custom class used to store and organize timesignal
    %objects.
    
    properties
        
    end
    
    methods
        function obj = signalcontainer(objToParse,varargin)
            % Parse inputs
            p = inputParser;
            %             addOptional(p,'logsout',[],@(x) isa(x,'Simulink.SimulationData.Dataset'))
            addOptional(p,'structBlockPath',[],@(x) isa(x,'Simulink.SimulationData.BlockPath')||isempty(x))
            addParameter(p,'Verbose',true,@islogical);
            parse(p,varargin{:});
            switch class(objToParse)
                case {'Simulink.SimulationData.Dataset','Simulink.sdi.DatasetRef'}
                    % Add metadata to the signal container at highest level
                    obj.addprop('metadata');
                    obj.metadata = metadata(p.Results.Verbose);
                    % get names of signals
                    names = objToParse.getElementNames;
                    % get rid of unnamed signals (empty strings)
                    names = names(cellfun(@(x) ~isempty(x),names));
                    % get rid of duplicate signal names
                    names = unique(names);
                    % add each signal to the signalcontainer
                    for ii = 1:length(names)
                        % Get element from logsout
                        ts = objToParse.getElement(names{ii});
                        % Get the name of the name and make it a valid
                        % property name
                        if ~isempty(ts.Name)
                            propName = genvarname(ts.Name);
                        else
                            propName = genvarname(names{ii});
                        end
                        % Deal with duplicate signal names
                        if isa(ts,'Simulink.SimulationData.Dataset')
                            if p.Results.Verbose
                                warning('Duplicate signal names: ''%s''.  Taking first found signal.',ts{1}.Name)
                            end
                            ts = ts{1};
                        end
                        % Add a new field by this name
                        obj.addprop(propName);
                        % Preallocate with empty structure
                        obj.(propName) = struct.empty(numel(ts.Values),0);
                        % Loop through each signal stored in ts.Values
                        for jj = 1:numel(ts.Values)
                            switch class(ts.Values(jj))
                                case 'timeseries'
                                    obj.(propName) = timesignal(ts.Values(jj),'BlockPath',ts.BlockPath);
                                case 'struct'
                                    obj.(propName) = signalcontainer(ts.Values(jj),'structBlockPath',ts.BlockPath);
                            end
                        end
                    end
                    % Print out power summary for the user
                    if p.Results.Verbose
                        obj.powersummary
                    end
                case 'struct'
                    % Add metadata to the signal container at highest level
                    obj.addprop('metadata');
                    obj.metadata = metadata(p.Results.Verbose);
                    % get names of signals
                    names = fieldnames(objToParse);
                    % get rid of unnamed signals (empty strings)
                    names = names(cellfun(@(x) ~isempty(x),names));
                    % get rid of duplicate signal names
                    names = unique(names);
                    % add each signal to the signalcontainer
                    for ii = 1:length(names)
                        % Get element from logsout
                        ts = objToParse.(names{ii});
                        % Get the name of the name and make it a valid
                        % property name
                        if isa(ts,'struct')
                            propName = genvarname(names{ii});
                        elseif ~isempty(ts.Name)
                            propName = genvarname(ts.Name);
                        else
                            propName = genvarname(names{ii});
                        end
                        % Deal with duplicate signal names
                        if isa(ts,'Simulink.SimulationData.Dataset')
                            if p.Results.Verbose
                                warning('Duplicate signal names: ''%s''.  Taking first found signal.',ts{1}.Name)
                            end
                            ts = ts{1};
                        end
                        % Add a new field by this name
                        obj.addprop(propName);
                        % Loop through each signal stored in ts.Values
                        switch class(ts)
                            case {'timeseries','timesignal'}
                                obj.(propName) = timesignal(ts,'BlockPath',p.Results.structBlockPath);
                            case 'struct'
                                obj.(propName) = signalcontainer(ts,'structBlockPath',p.Results.structBlockPath);
                        end
                    end
                case 'signalcontainer'
                    obj.addprop('metadata');
                    obj.metadata = objToParse.metadata;
                    propNames = properties(objToParse);
                    propNames = propNames(cellfun(@(x) ~strcmp(x,'metadata'),propNames));
                    for ii = 1:numel(propNames)
                        obj.addprop(propNames{ii});
                        switch class(objToParse.(propNames{ii}))
                            case {'timesignal','timeseries'}
                                obj.(propNames{ii}) = timesignal(objToParse.(propNames{ii}));
                            case {'signalcontainer','struct'}
                                obj.(propNames{ii}) = signalcontainer(objToParse.(propNames{ii}));
                        end
                    end
                otherwise
                    error('Unknown data type to parse')
            end
        end
        function plotEuler(obj,vhcl,env,varargin)
            p = inputParser;
            addOptional(p,'plot1Lap',false,@islogical);
            addOptional(p,'plotS',false,@islogical);
            addOptional(p,'Vapp',false,@islogical);
            addOptional(p,'plotBeta',false,@islogical);
            addOptional(p,'LiftDrag',false,@islogical);
            addOptional(p,'Color',[0 0 1],@isnumeric);
            parse(p,varargin{:})
            color = p.Results.Color;
            data = squeeze(obj.currentPathVar.Data);
            time = obj.lapNumS.Time;
            lap = p.Results.plot1Lap;
            con = p.Results.plotS;
            %  Determine Single Lap Indices
            if lap
                lapNum = squeeze(obj.lapNumS.Data);
                Idx1 = find(lapNum > 0,1,'first');
                Idx2 = find(lapNum > 1,1,'first');
                if isempty(Idx1) || isempty(Idx2)
                    error('Lap 1 was never started or finished. Simulate longer or reassess the meaning to your life')
                end
                ran = Idx1:Idx2-1;
                lim = [time(Idx1) time(Idx2)];
            else
                lim = [time(1) time(end)];
            end
            roll = squeeze(obj.eulerAngles.Data(1,1,:))*180/pi;
            pitch = squeeze(obj.eulerAngles.Data(2,1,:))*180/pi;
            yaw = squeeze(obj.eulerAngles.Data(3,1,:))*180/pi;
            hold on; grid on
            if lap
                if con
                    plot(data(ran),roll(ran),'b-');  ylabel('Euler [deg]');
                    plot(data(ran),pitch(ran),'r-');  ylabel('Euler [deg]');
                    plot(data(ran),yaw(ran),'g-');  ylabel('Euler [deg]');  legend('roll','pitch','yaw')
                else
                    plot(time(ran),energy(ran)-energy(Idx1),'-','color',color);  ylabel('Energy [kWh]');  xlim(lim)
                end
            else
                plot(time,energy,'-','color',color);  ylabel('Energy [kWh]');  xlim(lim)
            end
        end
        function plotLift(obj,vhcl,env,varargin)
            p = inputParser;
            addOptional(p,'plot1Lap',false,@islogical);
            addOptional(p,'plotS',false,@islogical);
            addOptional(p,'Vapp',false,@islogical);
            addOptional(p,'plotBeta',false,@islogical);
            addOptional(p,'LiftDrag',false,@islogical);
            addOptional(p,'Color',[0 0 1],@isnumeric);
            parse(p,varargin{:})
            color = p.Results.Color;
            data = squeeze(obj.currentPathVar.Data);
            time = obj.lapNumS.Time;
            lap = p.Results.plot1Lap;
            con = p.Results.plotS;
            %  Determine Single Lap Indices
            if lap
                lapNum = squeeze(obj.lapNumS.Data);
                Idx1 = find(lapNum > 0,1,'first');
                Idx2 = find(lapNum > 1,1,'first');
                if isempty(Idx1) || isempty(Idx2)
                    error('Lap 1 was never started or finished. Simulate longer or reassess the meaning to your life')
                end
                ran = Idx1:Idx2-1;
                lim = [time(Idx1) time(Idx2)];
            else
                lim = [time(1) time(end)];
            end
            FLiftBdyX = squeeze(obj.FLiftBdy.Data(1,1,:));
            FLiftBdyY = squeeze(obj.FLiftBdy.Data(2,1,:));
            FLiftBdyZ = squeeze(obj.FLiftBdy.Data(3,1,:));
            hold on; grid on
            if lap
                if con
                    plot(data(ran),FLiftBdyX(ran),'b-');
                    plot(data(ran),FLiftBdyY(ran),'r-');
                    plot(data(ran),FLiftBdyZ(ran),'g-');  ylabel('Lift [N]');  legend('X','Y','Z')
                else
                    plot(time(ran),energy(ran)-energy(Idx1),'-','color',color);  ylabel('Energy [kWh]');  xlim(lim)
                end
            else
                plot(time,energy,'-','color',color);  ylabel('Energy [kWh]');  xlim(lim)
            end
        end
        function plotDrag(obj,vhcl,env,varargin)
            p = inputParser;
            addOptional(p,'plot1Lap',false,@islogical);
            addOptional(p,'plotS',false,@islogical);
            addOptional(p,'Vapp',false,@islogical);
            addOptional(p,'plotBeta',false,@islogical);
            addOptional(p,'LiftDrag',false,@islogical);
            addOptional(p,'Color',[0 0 1],@isnumeric);
            parse(p,varargin{:})
            color = p.Results.Color;
            data = squeeze(obj.currentPathVar.Data);
            time = obj.lapNumS.Time;
            lap = p.Results.plot1Lap;
            con = p.Results.plotS;
            %  Determine Single Lap Indices
            if lap
                lapNum = squeeze(obj.lapNumS.Data);
                Idx1 = find(lapNum > 0,1,'first');
                Idx2 = find(lapNum > 1,1,'first');
                if isempty(Idx1) || isempty(Idx2)
                    error('Lap 1 was never started or finished. Simulate longer or reassess the meaning to your life')
                end
                ran = Idx1:Idx2-1;
                lim = [time(Idx1) time(Idx2)];
            else
                lim = [time(1) time(end)];
            end
            FDragBdyX = squeeze(obj.FDragBdy.Data(1,1,:));
            FDragBdyY = squeeze(obj.FDragBdy.Data(2,1,:));
            FDragBdyZ = squeeze(obj.FDragBdy.Data(3,1,:));
            hold on; grid on
            if lap
                if con
                    plot(data(ran),FDragBdyX(ran),'b-');
                    plot(data(ran),FDragBdyY(ran),'r-');
                    plot(data(ran),FDragBdyZ(ran),'g-');  ylabel('Drag [N]');  legend('X','Y','Z')
                else
                    plot(time(ran),energy(ran)-energy(Idx1),'-','color',color);  ylabel('Energy [kWh]');  xlim(lim)
                end
            else
                plot(time,energy,'-','color',color);  ylabel('Energy [kWh]');  xlim(lim)
            end
        end
        function plotLiftDrag(obj,vhcl,env,varargin)
            p = inputParser;
            addOptional(p,'plot1Lap',false,@islogical);
            addOptional(p,'plotS',false,@islogical);
            addOptional(p,'Vapp',false,@islogical);
            addOptional(p,'plotBeta',false,@islogical);
            addOptional(p,'LiftDrag',false,@islogical);
            addOptional(p,'Color',[0 0 1],@isnumeric);
            parse(p,varargin{:})
            color = p.Results.Color;
            data = squeeze(obj.currentPathVar.Data);
            time = obj.lapNumS.Time;
            lap = p.Results.plot1Lap;
            con = p.Results.plotS;
            %  Determine Single Lap Indices
            if lap
                lapNum = squeeze(obj.lapNumS.Data);
                Idx1 = find(lapNum > 0,1,'first');
                Idx2 = find(lapNum > 1,1,'first');
                if isempty(Idx1) || isempty(Idx2)
                    error('Lap 1 was never started or finished. Simulate longer or reassess the meaning to your life')
                end
                ran = Idx1:Idx2-1;
                lim = [time(Idx1) time(Idx2)];
            else
                lim = [time(1) time(end)];
            end
            FLiftBdyX = sqrt(squeeze(obj.FLiftBdy.Data(1,1,:).^2));
            FLiftBdyY = sqrt(squeeze(obj.FLiftBdy.Data(2,1,:).^2));
            FLiftBdyZ = sqrt(squeeze(obj.FLiftBdy.Data(3,1,:).^2));
            FDragBdyX = sqrt(squeeze(obj.FDragBdy.Data(1,1,:).^2));
            FDragBdyY = sqrt(squeeze(obj.FDragBdy.Data(2,1,:).^2));
            FDragBdyZ = sqrt(squeeze(obj.FDragBdy.Data(3,1,:).^2));
            hold on; grid on
            if lap
                if con
                    plot(data(ran),FLiftBdyX(ran)./FDragBdyX(ran),'b-');
                    plot(data(ran),FLiftBdyY(ran)./FDragBdyY(ran),'r:');
                    plot(data(ran),FLiftBdyZ(ran)./FDragBdyZ(ran),'g-');  ylim([0 50]);  ylabel('L/D');  legend('X','Y','Z')
                else
                    plot(time(ran),FLiftBdyX(ran)./FDragBdyX(ran),'b-');
                    plot(time(ran),FLiftBdyY(ran)./FDragBdyY(ran),'r:');
                    plot(time(ran),FLiftBdyZ(ran)./FDragBdyZ(ran),'g-');  ylim([0 50]);  ylabel('L/D');  legend('X','Y','Z')
                end
            else
                plot(time(ran),FLiftBdyX(ran)./FDragBdyX(ran),'b-');
                plot(time(ran),FLiftBdyY(ran)./FDragBdyY(ran),'r:');
                plot(time(ran),FLiftBdyZ(ran)./FDragBdyZ(ran),'g-');  ylim([0 50]);  ylabel('L/D');  legend('X','Y','Z')
            end
        end
        function [CLsurf,CDtot] = getCLCD(obj,vhcl)
            Aref = vhcl.fluidRefArea.Value;
            Afuse = squeeze(obj.Afuse.Data);
            CDfuse = squeeze(obj.CDfuse.Data).*Afuse/Aref;
            CDsurf = squeeze(sum(obj.CD.Data(1,1:3,:),2));
            CDtot = CDfuse+CDsurf;
            CLsurf = squeeze(sum(obj.CL.Data(1,1:3,:),2));
        end
    end
end

