classdef ilcParamSpace < dynamicprops
    %UNTITLED3 Summary of this class goes here
    %   Detailed explanation goes here

    properties
        learningGain
        trustRegion
        excitationAmp
        initBasisParams
        upperLim
        lowerLim
        spaceName
    end

    methods
        function obj = ilcParamSpace(lrn,trust,amp,init,upperLim,lowerLim,name)
            %ilcParamSpace - Constructor for a parameter space instance of
            % an ILC controller. Upper level controller design will combine
            % all parameter spaces into a switching formulation or a single
            % class instance.

            %Build cell of parameters to enable looping
            paramSpace = {init,lrn,trust,amp,upperLim,lowerLim};

            % Calculate the number of elements of each parameter
            n = ones(6,1);
            for i = 1:6
                n(i) = numel(paramSpace{i});
            end
            paramName = {'Basis','Learning Gain','Trust Region','Excitation Amplitude','Upper Limit','Lower Limit'};

            % Parse and guarantee appropriate parameter dimensions
            for i = 2:6
                if n(i) == 1
                    paramSpace{i} = paramSpace{i}*ones(1,n(1));
                elseif n(i) ~= n(1)
                    error('Size of %s does not match number of parameters in design space.\nAll parameters should be scalar or match size',paramName{i})
                end
            end

            obj.initBasisParams.Value = paramSpace{1};
            obj.initBasisParams.Desc = 'Initial Basis Parameters';
            obj.learningGain.Value = paramSpace{2};
            obj.learningGain.Desc = 'Learning Gain for ILC update Law';
            obj.trustRegion.Value = paramSpace{3};
            obj.trustRegion.Desc = 'Trust Region Bounds';
            obj.excitationAmp.Value = paramSpace{4};
            obj.excitationAmp.Desc = 'Persistent Excitation Amplitude';
            obj.upperLim.Value = paramSpace{5};
            obj.upperLim.Desc = 'Parameter upper limit';
            obj.lowerLim.Value = paramSpace{6};
            obj.lowerLim.Desc = 'Parameter lower limit';
            obj.spaceName = name;
        end

        function modifyILC(obj,varargin)
            %METHOD1 Method to change ILC parameters
            %   Modify parameter subspace. Function will validate
            %   that the appropriate size or will error out

            p = inputParser;

            addParameter(p,'lrn',obj.learningGain.Value)
            addParameter(p,'init',obj.initBasisParams.Value)
            addParameter(p,'amp',obj.excitationAmp.Value)
            addParameter(p,'trust',obj.trustRegion.Value)
            addParameter(p,'upperLim',obj.upperLim.Value)
            addParameter(p,'lowerLim',obj.lowerLim.Value)

            parse(p,varargin{:})

            %Build cell of parameters to enable looping
            paramSpace = {p.Results.init,p.Results.lrn,p.Results.trust,...
                p.Results.amp,p.Results.upperLim,p.Results.lowerLim};

            % Calculate the number of elements of each parameter
            n = ones(6,1);
            for i = 1:6
                n(i) = numel(paramSpace{i});
            end
            paramName = {'Basis','Learning Gain','Trust Region','Excitation Amplitude','Upper Lim','Lower Lim'};

            % Parse and guarantee appropriate parameter dimensions
            for i = 2:5
                if n(i) == 1
                    paramSpace{i} = paramSpace{i}*ones(1,n(1));
                elseif n(i) ~= n(1)
                    error('Size of %s does not match number of parameters in design space.\nAll parameters should be scalar or match size',paramName{i})
                end
            end

            obj.initBasisParams.Value = p.Results.init;
            obj.learningGain.Value = p.Results.lrn;
            obj.trustRegion.Value = p.Results.trust;
            obj.excitationAmp.Value = p.Results.amp;
            obj.upperLim.Value = p.Results.upperLim;
            obj.lowerLim.Value = p.Results.lowerLim;
        end
    end
end