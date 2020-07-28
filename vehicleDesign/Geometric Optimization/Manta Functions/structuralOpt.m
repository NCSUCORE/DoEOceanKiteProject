function [exitflag, Mw_out] = structuralOpt(AR, S, Vol,Fz, Df, Lf)
    %% Main Wing Structure Optimization Function
    % u(1) = A
    % u(2) = B
    % u(3) = T1
    % u(4) = T2
    global Mw E defper Span ChrdL ChrdT rhow Ixx Iyy Amax Bmax T1Brat T2Arat rho
    global Volw Voltot eff_fuse Volfuse
    global tar_buoy wmassrat

    % Fz = 5.5045*(10^5)/2
    Fy = 0.1367*(10^5)/2; %force on kite wing?

    % Input parameters
    tar_buoy = 1.0; %Number for Bryant Boyancy inequality condition (1)
    wmassrat = 0.3; %Ratio for Vermillion Boyancy inequality condition (0.3)
    rho = 1000.0;   %Density of water
    E = 69*(10^9);  %Aluminium modulus of elasticity
    rhow = 2710;    %Aluminium density
    Span = S/2;     %Length of beam (beam is  half length of span)
    defper = 5;     %Percentage Deflection at centroid (Note:5.0 == 5%)
    delx = defper*Span/100; %Magnitude of deflection
    ChrdT = 12;   %Chord Thickness (m) (Airfoil parameters)
    ChrdL = S/AR; %Chord Length (Airfoil parameters)

    % Ixx calculation
    Ixx = 5*Fz*(Span^3)/(48*E*delx); %Ixx from force vertical
    Iyy = 5*Fy*0.1*(Span^3)/(48*E*delx); %Iyy from force horizontal
    Ix = Ixx*(39.37^4); %First Moments of area (Not used in code, mainly
    Iy = Iyy*(39.37^4); %for shear in beams)

    % Constraints on height and width of I beam
    Amax = 0.11; %Height of I beam is 11% thick
    Bmax = 0.28; %Width of I beam is 28% thick

    % Constraints on T1 and T2
    T1Brat = 0.3; % 30% - Max ratio of T1 and Max value of B
    T2Arat = 0.1; % 10% - Max ratio of T2 and Max value of A

    % Mass of wing
    Mw = Vol*rhow/2.0;
    Mw_out = Vol*rhow;

    % Total Volume and Volume of wing
    Volw = Vol; %Volume of the wings
    eff_fuse = 0.8;
    Volfuse = (pi*Df*Lf*eff_fuse); %Volume of fusealoge based on .8 shape

    % Adding a while loop for multiple beam generation
    Ixx_lim = 0;
    exitflag = 1;
    %Whiel the Force MOI is more than the "Limit"
    while Ixx_lim < Ixx
        %Calculating MoI at upper limits of all dimensions
        A_lim = Amax*ChrdL;
        B_lim = Bmax*ChrdL;
        T1_lim = T1Brat*Bmax*ChrdL;
        T2_lim = T2Arat*Amax*ChrdL;
        
        %Finds area moment of inertia of beam
        [Ixx_lim,Iyy_lim] = AMoICalc(A_lim, B_lim, T1_lim, T2_lim);

        %Exitflag defined if cant converge and there should be two beams
        if (Ixx_lim <= Ixx/2)
            exitflag =-4;
            break;
        end

        Ixx = Ixx - Ixx_lim;
        Amax = Amax*0.9;%ChrdT/100; % This is basically the chord thickness
        Bmax = Bmax*0.9;%0.3;       % 35% - Max value of B can be X% of Chord length
        T1Brat = T1Brat*1.7;
        T2Arat = T2Arat*1.7;
    end

    if exitflag == -4
        return;
    end

    % Optimization
    %u0 = 0.5*ones(4,1); % Initial guess
    u0 = [0.5 0.5 0.3 0.3]';
    lb = 0.01*ones(4,1); % Lower limits
    ub = 4.0*ones(4,1);   % upper limits
    options = optimoptions('fmincon','Display','iter','Algorithm','sqp');%;,'MaxFunctionEvaluations',10000000);
    [uopt Jopt exitflag] = fmincon(@costfunc,u0,[],[],[],[],lb,ub,@constraintfunc,options);

    %Wt_opt = rhow*Span*(2*(uopt(4)*uopt(2))+(uopt(3)*(uopt(1)-(2*(uopt(4))))));
    [Ixx_opt,Iyy_opt] = AMoICalc(uopt(1), uopt(2), uopt(3), uopt(4));
    Ixx_1 = Ixx_opt*(39.37^4);
end

%% Cost function for Mass
function [J] = costfunc(u)
    global Span rhow

    % Cost = Weight of beam
    area = 2*(u(4)*u(2))*(u(3)*(u(1)-(2*(u(4))))); %beam cross-sect area
    vol = area*Span; %beam total volume

    J = rhow*vol; %Beam mass (based on material)
end

%% Constraint functions
function [c_ineq, c_eq] = constraintfunc(u)
    global Span ChrdL Ixx Amax Bmax T1Brat T2Arat rho rhow Volfuse Volw Voltot Mw tar_buoy wmassrat

    % Constraints
    ineq3 = u(3) - (T1Brat*Bmax*ChrdL);
    ineq4 = u(4) - (T2Arat*Amax*ChrdL);
    ineq5 = -eye(4)*u;

    area = 2*(u(4)*u(2))*(u(3)*(u(1)-(2*(u(4)))));
    vol = area*Span;

    % Constraint type 1 (Dr. Bryant)
    %ineq6 = (((rho*Volw/(vol*rhow)) - tar_buoy)^2.0) - 0.1;

    % Constraint type 2 (Dr. Vermillion)
    ineq6 = wmassrat - (rho*(Volfuse+vol)/(vol*rhow));

    [Ixx_calc,Iyy_calc] = AMoICalc(u(1),u(2),u(3),u(4));
    eq1 = Ixx_calc - Ixx;
    eq2 = u(1) - (Amax*ChrdL);
    eq3 = u(2) - (Bmax*ChrdL);


    c_ineq=[ineq3;ineq4;ineq5;ineq6];
    c_eq= [eq1;eq2;eq3];
end

%% Area Moment of Inertia Function
function [Ixx,Iyy] = AMoICalc(A,B,T1,T2)
    a = A - (2*T2);
    b = B - T1;
    Ixx = (B*(A^3)/12) - (b*(a^3)/12);
    Iyy = (A*(B^3)/12) - (a*(b^3)/12);
end

%%  Airfoil data read function NOT USED
function [airx,airy] = getairfoil()
    T = readtable('aftools2412_12per.txt');
    Tarr = table2array(T);
    airx = Tarr(:,1)*39.37;
    airy = Tarr(:,2)*39.37;
end


