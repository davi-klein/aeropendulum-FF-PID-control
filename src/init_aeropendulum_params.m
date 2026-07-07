function p = init_aeropendulum_params()
% INIT_AEROPENDULUM_PARAMS Initializes properties of the aeropendulum.
%
% Creates a structured parameter set encapsulating mechanical, aerodynamic,
% and actuator properties to prevent base workspace pollution.

    % Mechanical Parameters
    p.m_p = 0.5;           % Pendulum mass (kg)
    p.m_l = 0;             % Load mass (kg)
    p.m = p.m_p + p.m_l;   % Total mass (kg)
    p.g = 9.81;            % Gravity (m/s^2)
    p.L_cm_p = 0.15;       % Center of mass of the pendulum (m)
    p.r = 0;               % Distance from the load to the pivot (m)
    p.L_cm = ((p.m_p * p.L_cm_p) + (p.m_l * p.r)) / p.m; % Center of mass (m)
    p.J_p = 0.02;          % Inertia of the pendulum (kg*m^2)
    p.J_l = p.m_l * p.r^2; % Inertia of the load (kg*m^2)
    p.J = p.J_p + p.J_l;   % Total inertia
    p.L_p = 0.3;           % Propeller distance (m)

    % Aerodynamic & Friction Parameters
    p.k_T = 1.2e-5;        % Thrust coeff
    p.k_adv = 0;           % Advance ratio coeff
    p.B_eq = 0.005;        % Linear damping
    p.C_d = 0.001;         % Aero drag coeff

    % Actuator (Motor) Parameters
    p.K_v = 96.34;         % Motor gain
    p.tau_m = 0.05;        % Motor time constant

    % Simulation Parameters
    p.stpt = 20;           % Stop Time (s)
    p.type = 'sine';        % Type of Reference Trajectory (sine or trapezoidal)
    p.f = 10e+03;          % Sampling Frequency (Hz)
    p.dt = 1/p.f;          % Trajectory Sampling Time (s)
    p.N = 50;              % Derivative Filter Coefficient 

end