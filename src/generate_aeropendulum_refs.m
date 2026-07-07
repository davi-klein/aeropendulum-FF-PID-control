function [ts_sine, ts_trap] = generate_aeropendulum_refs(t_end, dt)
    % GENERATE_AEROPENDULUM_REFS Generates smooth reference trajectories
    % t_end: Total simulation time
    % dt: Sample time
    
    t = 0:dt:t_end;
    
    % Parameters
    amp = pi/6;         % Amplitude
    freq = 0.5;         % Frequency
    
    t_trans = 2;        % Transient duration
    t_hold = 2;         % Hold duration at top and bottom
    t_cycle = 2*t_trans + 2*t_hold; % Total time for one full trapezoid cycle
    
    % 1. Sine Wave Reference
    th_sine = (amp/2) - (amp/2)*cos(2*pi*freq*t);
    
   % 2. Differentiable Trapezoidal Reference
    th_trap = zeros(size(t));
    
    for i = 1:length(t)
        t_c = mod(t(i), t_cycle); 
        
        if t_c < t_trans
            th_trap(i) = (amp/2) * (1 - cos(pi * t_c / t_trans));
            
        elseif t_c < (t_trans + t_hold)
            th_trap(i) = amp;
            
        elseif t_c < (2*t_trans + t_hold)
            t_fall = t_c - (t_trans + t_hold);
            th_trap(i) = (amp/2) * (1 + cos(pi * t_fall / t_trans));
            
        else
            th_trap(i) = 0;
        end
    end
    
    % Create timeseries objects for Simulink
    ts_sine = timeseries(th_sine', t');
    ts_trap = timeseries(th_trap', t');
end