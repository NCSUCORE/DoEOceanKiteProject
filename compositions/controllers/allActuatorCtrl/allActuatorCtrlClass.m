classdef allActuatorCtrlClass < handle
    
    properties
        %% nominal set points
        % nominal altitude setpoint
        altitudeSetpoint_m = 200;
        % set alti
        %         set_alti = k_scale*set_alti_nom;
        % set pitch
        pitchSetpoint_deg = 7;
        %         set_pitch = 7;
        %         set_pitch = set_pitch*(pi/180);
        
        % set roll
        %         set_roll = 0;
        %         set_roll = set_roll*(pi/180);
        rollSetpoint_deg = 0;
        
        %% controller parameters
        % winch saturation velocities
        %         nom_vel_up_lim = 0.4;
        %         vel_up_lim = sqrt(k_scale)*nom_vel_up_lim;
        %         winc_vel_up_lims = vel_up_lim*ones(3,1);
        winchSpeedLim_mPs = 0.4
        
        % winch time constant
        %         nom_t_winch = 1;
        %         t_winch = sqrt(k_scale)*nom_t_winch;
        %         winchTimeConst_s = 1;
        
        % Gains and time constants altitude
        %         Kp_z = 1*sqrt(k_scale)*0.05;
        %         Ki_z = 0;
        %         Kd_z = 5*Kp_z;
        %         cut_off_f_z = 0.005/sqrt(k_scale);
        %         wce_z = 2*pi*cut_off_f_z;
        
        altKp_Ps = 1;
        altKi_Ps3 = 0;
        altKd_Ps = 5;
        altFiltCutOffFreq_radPs = 0.0005*2*pi
        
        
        % Gains pitch
        %         Kp_p = 1*sqrt(k_scale)*1.5*0.5;
        %         Ki_p = 0.0;
        %         Kd_p = 2.5*sqrt(k_scale)*Kp_p;
        %         cut_off_f_p = 0.2/sqrt(k_scale);
        %         wce_p = 2*pi*cut_off_f_p;
        
        pitchKp_mPsrad = 1;
        pitchKi_mPrads2 = 0;
        pitchKd_msPrad = 2.5;
        pitchFiltCutOffFreq_radPs = 0.2*2*pi;
        
        
        % elevator gaines
        %         kp_elev = 1*10;
        %         ki_elev = 0.0*kp_elev;
        %         kd_elev = sqrt(k_scale)*3*kp_elev;
        %         t_elev = sqrt(k_scale)*0.05;
        
        % CHECK THESE UNITS AND CORRECT IN CONTROLLER
        elevatorKp_ = 10;
        elevatorKi_ = 0;
        elevatorKd_ = 30;
        elevatorFilterTimeConst_s = 0.05;
        
        aileronKp_  = 4;
        aileronKi_    = 0;
        aileronKd_  = 8;
        aileronFilterTimeConst_s = 0.2;
        
        %         kp_aileron = 1*4;
        %         ki_aileron = 0.0*kp_aileron;
        %         kd_aileron = 2*sqrt(k_scale)*kp_aileron;
        %         t_aileron = sqrt(k_scale)*0.2;
        
       
        %         elev_tf = tf([kd_elev kp_elev],[t_elev 1]);
        
        
        
        %         p_tf = tf([Kd_p Kp_p],[1/wce_p 1]);
        
        %         pitch_control.Kp_p = Kp_p;
        %         pitch_control.Ki_p = Ki_p;
        %         pitch_control.Kd_p = Kd_p;
        %         pitch_control.wce_p = wce_p;
        
        % Gains roll
        %         Kp_r = 1*(k_scale)*(Kp_p/(0.5*AR));
        %         Ki_r = 0.0;
        %         Kd_r = 2*sqrt(k_scale)*Kp_r;
        %
        %         cut_off_f_r = 0.2/sqrt(k_scale);
        %         wce_r = 2*pi*cut_off_f_r;
        %
        rollKp_mPsrad = 1;
        rollKi_mPrads3 = 0;
        rollKd_mPrad = 2;
        rollCutOffFreq_radPs = 0.2*2*pi;
        
        %         r_tf = tf([Kd_r Kp_r],[1/wce_r 1]);
        
        %         roll_control.Kp_r = Kp_r;
        %         roll_control.Ki_r = Ki_r;
        %         roll_control.Kd_r = Kd_r;
        %         roll_control.wce_r = wce_r;
        
        % co-ordinate transformation matrix
        pMat = [1.0000    0.5000   -0.5000;...
            1.0000   -0.5000         0;...
            1.0000    0.5000    0.5000];
        pCSMat = [-1 -1; -1 1];
        
        %         P_inv = inv(P_mat);
        elevonMaxDeflection_deg = 30;
        
        % Define dependent variables here 
        x
    end

    methods
        % Constructor
        function obj = allActuatorCtrlClass()
            % Calculate default value of dependent variables here, can be
            % overwritten later
            obj.x = 1;
        end
        % Function to scale all parameters
        function obj = scale(obj,scaleFactor)
            obj = scaleObj(obj,scaleFactor);
        end
    end
    
end