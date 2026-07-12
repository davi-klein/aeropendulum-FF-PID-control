function [K_opt, f_evals, exec_time] = FMA(p, model_name, th_ref_ts)
    % FMA Tunes PID gains using the Firefly Metaheuristic Algorithm
    % Returns optimal gains, number of function evaluations, and execution time.
    % This algorithm is based on the one from Yang, et. al.
    
    % Start the timer
    tic;
    
    % Initialize evaluation counter
    f_evals = 0;
    
    % FA Parameters
    n_fireflies = 15;     % Population size
    max_iter = 50;        % Maximum generations
    alpha = 0.8;          % Randomness parameter
    beta0 = 1.0;          % Attractiveness at distance r=0
    gamma = 0.1;          % Light absorption coefficient
    
    % PID Bounds: [Kp, Ki, Kd]
    lb = [0.1, 0.0, 0.01]; 
    ub = [p.Kp_max, p.Ki_max, p.Kd_max];
    dim = 3;

    % Stagnation Criterion Parameters
    N_stall = 10;         % Number of generations without improvement to trigger stop
    delta = 1e-4;         % Minimum required improvement in ITAE
    stall_count = 0;      % Initialize counter
    prev_best_cost = inf; % Initialize previous best
    
    % Initialize population randomly within bounds
    fireflies = repmat(lb, n_fireflies, 1) + rand(n_fireflies, dim) .* repmat((ub - lb), n_fireflies, 1);
    fitness = zeros(n_fireflies, 1);
    
    fprintf('Evaluating initial population...\n');
    for i = 1:n_fireflies
        fitness(i) = cost_function(fireflies(i,:), model_name, th_ref_ts);
        f_evals = f_evals + 1; % Increment counter for initial population
    end
    
    % Main FA Loop
    for iter = 1:max_iter
        for i = 1:n_fireflies
            for j = 1:n_fireflies
                if fitness(j) < fitness(i) % Move firefly i towards j
                    r = norm(fireflies(i,:) - fireflies(j,:));
                    beta = beta0 * exp(-gamma * r^2);
                    
                    % Movement equation
                    epsilon = rand(1, dim) - 0.5;
                    fireflies(i,:) = fireflies(i,:) + beta * (fireflies(j,:) - fireflies(i,:)) + alpha * epsilon;
                    
                    % Enforce boundaries
                    fireflies(i,:) = max(fireflies(i,:), lb);
                    fireflies(i,:) = min(fireflies(i,:), ub);
                    
                    % Update fitness
                    fitness(i) = cost_function(fireflies(i,:), model_name, th_ref_ts);
                    f_evals = f_evals + 1; % Increment counter for each movement
                end
            end
        end
        
        % Decay randomness to improve convergence over time
        alpha = alpha * 0.95;
        
        [best_cost, idx] = min(fitness);
        improvement = prev_best_cost - best_cost;
        
        % Stall counter
        if improvement < delta
            stall_count = stall_count + 1;
        else
            stall_count = 0; 
            prev_best_cost = best_cost;
        end
        
        fprintf('Iter %d/%d | Best ITAE: %.4f | Stall: %d/%d | Kp: %.2f, Ki: %.2f, Kd: %.2f\n', ...
            iter, max_iter, best_cost, stall_count, N_stall, fireflies(idx, 1), fireflies(idx, 2), fireflies(idx, 3));

        if stall_count >= N_stall
            fprintf('\n>>> Optimization terminated early: ITAE stagnated for %d generations. <<<\n', N_stall);
            break; 
        end
    end
    
    % Return the best gains found
    [~, best_idx] = min(fitness);
    K_opt = fireflies(best_idx, :);
    
    % Stop the timer
    exec_time = toc;
end