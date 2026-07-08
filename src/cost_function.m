function J = cost_function(K, model_name, th_ref_ts)
    % PID_COST_FUNCTION Evaluates the fitness of a PID gain set using ITAE.
    % K = [Kp, Ki, Kd]
    
    % Create simulation input object
    simIn = Simulink.SimulationInput(model_name);
    
    % Inject parameters and gains
    simIn = simIn.setVariable('Kp', K(1));
    simIn = simIn.setVariable('Ki', K(2));
    simIn = simIn.setVariable('Kd', K(3));
    
    % Inject the reference trajectory.
    simIn = simIn.setVariable('th_ref', th_ref_ts);
    
    % Suppress visual output for speed
    simIn = simIn.setModelParameter('SimulationMode', 'accelerator');
    
    try
        % Run simulation
        out = sim(simIn, 'UseFastRestart', 'on', 'ShowProgress', 'off');
        
        % Extract logged error
        error_sig = out.logsout.get('tracking_error').Values;
        t = error_sig.Time;
        e = error_sig.Data;
        
        % Extract logged unconstrained control signal
        u_sig = out.logsout.get('u_total').Values;
        u = u_sig.Data;
        
        % 1. Calculate Primary Cost: ITAE
        ITAE = trapz(t, t .* abs(e));
        
        % 2. Calculate Penalty for Voltage Violation (0 to 12V)
        u_max_violation = max(0, u - 12); 
        u_min_violation = max(0, 0 - u);  
        
        % Quadratic penalty integration
        penalty = trapz(t, u_max_violation.^2 + u_min_violation.^2);
        
        % 3. Total Cost Function
        lambda = 100; % Penalty weight
        J = ITAE + (lambda * penalty);
        
    catch ME
        fprintf('Simulation failed: %s\n', ME.message);
        % If simulation fails (e.g., severe instability), discard this firefly
        J = 1e6; 
    end
end