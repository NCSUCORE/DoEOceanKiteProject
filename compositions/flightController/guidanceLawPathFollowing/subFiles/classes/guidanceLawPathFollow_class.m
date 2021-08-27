classdef guidanceLawPathFollow_class
    %GUIDANCELAWPATHFOLLOW_CLASS Summary of this class goes here
    %   Detailed explanation goes here
    
    properties
        pathWidth_deg(1,1) double {mustBePositive} = 40
        pathHeight_deg(1,1) double {mustBePositive} = 12
        pathElevation_deg(1,1) double = 30
        normalizedLforward(1,1) double {mustBeNonnegative,mustBeLessThanOrEqual(normalizedLforward,0.25)} = 0.05
        kiteMass(1,1) double {mustBePositive} = 1
        maxTanRoll_deg(1,1) double {mustBePositive} = 30
        initPathParameter(1,1) double {mustBeNonnegative} = 0
        % aileron controller gains
        aileron_kp(1,1) double {mustBeNonnegative} = 1
        aileron_kd(1,1) double {mustBeNonnegative} = 0
        aileron_tau(1,1) double {mustBePositive} = 0.1
    end
    
    methods
        
        %% set methods
        % normalizedLforward
%         function obj = set.normalizedLforward(obj,val)
%             obj.normalizedLforward = val;
%         end
    end
end

