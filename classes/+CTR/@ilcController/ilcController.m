classdef ilcController < dynamicprops
    %ILC Controller Class which defines the appropriates properties to
    % required for ILC control
    %

    properties (SetAccess = private)
        switching
        numInitLaps
        pathVarUpperLim
        pathVarLowerLim
        parameterSpace
        forgettingFactor
        initBasisParams
    end

    properties (Dependent)
        initParameters
        learningGain
        trustRegion
        excitationAmp
        subspaceDims
        upperLim
        lowerLim
    end

    methods
        function obj = ilcController()
            %ilcController Construct an instance of this class
            %   Add apprpriate properties
            obj.initBasisParams = SIM.parameter('Unit','','Description','Initial Path Parameters');
            obj.switching = SIM.parameter('Unit','','Description','seILC - 1, eILC - 0');
            obj.forgettingFactor = SIM.parameter('Unit','','Description','Exponential Forgetting Factor','Value',0.98);
            obj.numInitLaps = SIM.parameter('Unit','','Description','Number of laps allowed for transients to settle before ILC begins');
            obj.pathVarUpperLim = SIM.parameter('Unit','','Description','Upper limit on s for lap counter','Value',0.975);
            obj.pathVarLowerLim = SIM.parameter('Unit','','Description','Lower limit on s for lap counter','Value',0.025);
            obj.parameterSpace = {};
        end

        function addParameterSpace(obj,subspace)
            %METHOD1 Add a parameter subspace to the high level controller
            %   This function will append a new parameter subspace to the
            %   controller for exploration;
            obj.parameterSpace.(subspace.spaceName) = subspace;
        end

        function val = get.initParameters(obj)
            %Put sctructure into an array
            x = struct2array(obj.parameterSpace);

            % Get number of subspaces
            n = numel(x);

            %Loop through subspaces to build initial parameters
            val = [];
            for i = 1:n
                val = [val x(i).initBasisParams.Value];
            end
        end

        function val = get.upperLim(obj)
            %Put sctructure into an array
            x = struct2array(obj.parameterSpace);

            % Get number of subspaces
            n = numel(x);

            %Loop through subspaces to build initial parameters
            val = [];
            for i = 1:n
                val = [val x(i).upperLim.Value];
            end
        end

        function val = get.lowerLim(obj)
            %Put sctructure into an array
            x = struct2array(obj.parameterSpace);

            % Get number of subspaces
            n = numel(x);

            %Loop through subspaces to build initial parameters
            val = [];
            for i = 1:n
                val = [val x(i).lowerLim.Value];
            end
        end

        function val = get.excitationAmp(obj)
            %Put sctructure into an array
            x = struct2array(obj.parameterSpace);

            % Get number of subspaces
            n = numel(x);

            %Loop through subspaces to build initial parameters
            val = [];
            for i = 1:n
                val = [val x(i).excitationAmp.Value];
            end
        end

        function val = get.trustRegion(obj)
            %Put sctructure into an array
            x = struct2array(obj.parameterSpace);

            % Get number of subspaces
            n = numel(x);

            %Loop through subspaces to build initial parameters
            val = [];
            for i = 1:n
                val = [val x(i).trustRegion.Value];
            end
        end

        function val = get.learningGain(obj)
            %Put sctructure into an array
            x = struct2array(obj.parameterSpace);

            % Get number of subspaces
            n = numel(x);

            %Loop through subspaces to build initial parameters
            val = [];
            for i = 1:n
                val = [val x(i).learningGain.Value];
            end
        end

        function val = get.subspaceDims(obj)
            x = struct2array(obj.parameterSpace);

            % Get number of subspaces
            n = numel(x);

            for i = 1:n
                val(i) = numel(x(i).initBasisParams.Value);
            end
        end

    end
end