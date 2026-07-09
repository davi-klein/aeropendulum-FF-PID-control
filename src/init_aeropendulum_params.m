function p = init_aeropendulum_params()
% INIT_AEROPENDULUM_PARAMS Initializes properties of the aeropendulum.
%
% Creates a structured parameter set encapsulating mechanical, aerodynamic,
% and actuator properties to prevent base workspace pollution.

    % Mechanical Parameters
    p.m_p = 1.26094;           % Pendulum mass (kg)
    p.m_l = 0;             % Load mass (kg)
    p.m = p.m_p + p.m_l;   % Total mass (kg)
    p.g = 9.81;            % Gravity (m/s^2)
    p.L_cm_p = 0.06828;       % Center of mass of the pendulum (m)
    p.r = 0;               % Distance from the load to the pivot (m)
    p.L_cm = ((p.m_p * p.L_cm_p) + (p.m_l * p.r)) / p.m; % Center of mass (m)
    p.J_p = 0.0564501;          % Inertia of the pendulum (kg*m^2)
    p.J_l = p.m_l * p.r^2; % Inertia of the load (kg*m^2)
    p.J = p.J_p + p.J_l;   % Total inertia
    p.L_p = 0.25;           % Propeller distance (m)
    
    % Aerodynamic & Friction Parameters
    p.k_T = 0.062;         % Thrust coeff (Olivares et al. (2023))
    p.k_adv = 0;           % Advance ratio coeff
    p.B_eq = 0.009013;     % Linear damping (Olivares et al. (2023))
    p.C_d = 0.000;         % Aero drag coeff

    % Actuator (Motor) Parameters
    p.K_v = 96.34;         % Motor gain
    p.tau_m = 0.05;        % Motor time constant

    % Simulation Parameters
    p.stpt = 8;           % Stop Time (s)
    p.type = 'trapezoidal';      % Type of Reference Trajectory (sine or trapezoidal)
    p.f = 1e+03;          % Sampling Frequency (Hz)
    p.dt = 1/p.f;         % Trajectory Sampling Time (s)
    p.N = 50;             % Derivative Filter Coefficient 
    p.use_ff = 1;         % 1 = Enable Gravity FF, 0 = Pure PID

    % Controller gain limits
    p.f_t = 10;            % Target frequency for ressonance avoidance in Hz
    p.w_n = 2*pi*p.f_t;    % Natural frequency
    p.Kp_max = p.J*p.w_n^2;% Maximum proportional gain
    
    p.zeta = 1;            % Damping
    p.Kd_max = (2 * p.zeta * p.w_n * p.J) - p.B_eq; % Maximum derivative gain

    p.wind_t = 2;          % Windup preventing time constant
    p.Ki_max = p.Kp_max/p.wind_t; % Maximum integral gain

end