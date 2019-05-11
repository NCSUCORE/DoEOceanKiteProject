classdef allActuatorCtrlClass < handle
    
    properties
        %% nominal set points
        % nominal altitude setpoint
        % set alti
        %         set_alti = k_scale*set_alti_nom;
        % set pitch
        %         set_pitch = 7;
        %         set_pitch = set_pitch*(pi/180);
        % set roll
        %         set_roll = 0;
        %         set_roll = set_roll*(pi/180);
        %% controller parameters
        % winch saturation velocities
        %         nom_vel_up_lim = 0.4;
        %         vel_up_lim = sqrt(k_scale)*nom_vel_up_lim;
        %         winc_vel_up_lims = vel_up_lim*ones(3,1);
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
        % Gains pitch
        %         Kp_p = 1*sqrt(k_scale)*1.5*0.5;
        %         Ki_p = 0.0;
        %         Kd_p = 2.5*sqrt(k_scale)*Kp_p;
        %         cut_off_f_p = 0.2/sqrt(k_scale);
        %         wce_p = 2*pi*cut_off_f_p;
        % elevator gaines
        %         kp_elev = 1*10;
        %         ki_elev = 0.0*kp_elev;
        %         kd_elev = sqrt(k_scale)*3*kp_elev;
        %         t_elev = sqrt(k_scale)*0.05;
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
        %         r_tf = tf([Kd_r Kp_r],[1/wce_r 1]);
        %         roll_control.Kp_r = Kp_r;
        %         roll_control.Ki_r = Ki_r;
        %         roll_control.Kd_r = Kd_r;
        %         roll_control.wce_r = wce_r;
        altitudeSetpoint
        pitchSetpoint
        rollSetpoint
        
        winchSpeedCmdLim
        elevonMaxDeflection
        
        altitudeKp
        altitudeKi
        altitudeKd
        altitudeFilterTimeConst
        
        pitchKp
        pitchKi
        pitchKd
        pitchFilterTimeConst
        
        elevatorKp
        elevatorKi
        elevatorKd
        elevatorFilterTimeConst
        
        aileronKp
        aileronKi
        aileronKd
        aileronFilterTimeConst
        
        rollKp
        rollKi
        rollKd
        rollFilterTimeConst
        
        pMat
        pCSMat
    end
    
    methods
        % Constructor
        function obj = allActuatorCtrlClass()
            % Constructor method that sets the "default" property values
            
            % Setpoints
            obj.altitudeSetpoint = simulinkProperty(200,'Unit','m','Description','altitude setpoint');
            obj.pitchSetpoint    = simulinkProperty(7,'Unit','deg','Description','pitch setpoint');
            obj.rollSetpoint     = simulinkProperty(0,'Unit','deg','Description','roll setpoint');

            % Elevator controller gains
            obj.elevatorKp              = simulinkProperty(10,'Description','elevator controller proportional gain');
            obj.elevatorKi              = simulinkProperty(0,'Unit','1/s','Description','elevator controller integral gain');
            obj.elevatorKd              = simulinkProperty(30,'Unit','s','Description','elevator controller derivative gain');
            obj.elevatorFilterTimeConst = simulinkProperty(0.05,'Unit','s','Description','elevator controller time constant');
            
            % Aileron controller gains
            obj.aileronKp              = simulinkProperty(4,'Description','aileron controller proportional gain');
            obj.aileronKi              = simulinkProperty(0,'Unit','1/s','Description','aileron controller integral gain');
            obj.aileronKd              = simulinkProperty(8,'Unit','s','Description','aileron controller derivative gain');
            obj.aileronFilterTimeConst = simulinkProperty(0.2,'Unit','s','Description','aileron controller time constant');
            
            % Altitude controller gains
            obj.altitudeKp               = simulinkProperty(1,'Unit','1/s','Description','altitude controller proportional gain');
            obj.altitudeKi               = simulinkProperty(0,'Unit','1/s^2','Description','altitude controller integral gain');
            obj.altitudeKd               = simulinkProperty(5,'Description','altitude derivative controller gain');
            obj.altitudeFilterTimeConst  = simulinkProperty(1/(0.0005*2*pi),'Unit','s','Description','altitude controller time constant');
            
            % Pitch controller gains
            obj.pitchKp              = simulinkProperty(1,'Unit','m/(deg*s)','Description','pitch controller proportional gain');
            obj.pitchKi              = simulinkProperty(0,'Unit','m/(deg*s^2)','Description','pitch controller integral gain');
            obj.pitchKd              = simulinkProperty(2.5,'Unit','m/deg','Description','pitch controller derivative gain');
            obj.pitchFilterTimeConst = simulinkProperty(1/(0.2*2*pi),'Unit','s','Description','pitch controller time constant');
            
            % Roll controller gains
            obj.rollKp              = simulinkProperty(1,'Unit','m/(deg*s)','Description','roll controller proportional gain');
            obj.rollKi              = simulinkProperty(0,'Unit','m/(deg*s^2)','Description','roll controller integral gain');
            obj.rollKd              = simulinkProperty(2,'m/rad','Description','roll controller derivative gain');
            obj.rollFilterTimeConst = simulinkProperty(1/(0.2*2*pi),'Unit','s','Description','roll controller time constant');
            
            % Actuator command saturations
            obj.winchSpeedCmdLim    = simulinkProperty(0.4,'Unit','m/s','Description','winch speed command limit');
            obj.elevonMaxDeflection = simulinkProperty(30,'Unit','deg','Description', 'elevon max deflection limit');
            
            % Matrix to combine controllers for tethers
            obj.pMat = simulinkProperty(...
                [1.0000    0.5000   -0.5000;...
                1.0000   -0.5000         0;...
                1.0000    0.5000    0.5000],'Description', 'matrix to combine controllers for tethers');
            % Matrix to combine controllers for ctrl surfaces
            obj.pCSMat = simulinkProperty([-1 -1; -1 1],'Description', 'matrix to combine controllers for control surfaces');
            
            
            
        end
        % Function to scale all parameters
        function obj = scale(obj,scaleFactor)
            obj = scaleObj(obj,scaleFactor);
        end
    end
    
end