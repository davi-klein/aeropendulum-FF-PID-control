function [th_ref_ts] = generate_aeropendulum_refs(type, t_end, dt)
    % GENERATE_AEROPENDULUM_REFS Generates smooth reference trajectories
    % type: type of trajectory (accepted args: 'sine' or 'trapezoidal')
    % t_end: Total simulation time
    % dt: Sample time
    
    t = 0:dt:t_end;
    
    % Parameters
    amp = pi/6;         % Amplitude
    freq = 0.25;         % Frequency
    
    t_trans = 0.5;        % Transient duration
    t_hold = 1;         % Hold duration at top and bottom
    
    if strcmp('sine',type)
        % 1. Sine Wave Reference
        th_sine = (amp)*sin(2*pi*freq*t);
        th_ref_ts = timeseries(th_sine', t');
    elseif strcmp('trapezoidal', type)
        % 2. Bipolar Differentiable Trapezoidal Reference
        t_cycle = 4*t_trans + 2*t_hold; 
        th_trap = zeros(size(t));
        
        for i = 1:length(t)
            if t(i) < t_trans
          
                th_trap(i) = (amp/2) * (1 - cos(pi * t(i) / t_trans));
            else
   
                t_periodic = t(i) - t_trans;
                t_c = mod(t_periodic, t_cycle); 
                
                if t_c < t_hold
                    th_trap(i) = amp;
                    
                elseif t_c < (t_hold + 2*t_trans)
                    t_fall = t_c - t_hold;
                    th_trap(i) = amp * cos(pi * t_fall / (2*t_trans));
                    
                elseif t_c < (2*t_hold + 2*t_trans)
                    th_trap(i) = -amp;
                    
                else
                    t_rise = t_c - (2*t_hold + 2*t_trans);
                    th_trap(i) = -amp * cos(pi * t_rise / (2*t_trans));
                end
            end
        end
        th_ref_ts = timeseries(th_trap', t');
    else
        disp('Unidentified Trajectory.')
    end
end