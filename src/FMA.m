function [K_opt, f_evals, exec_time] = FMA(model_name, th_ref_ts)
    % FMA Tunes PID gains using the Firefly Metaheuristic Algorithm
    % Returns optimal gains, number of function evaluations, and execution time.
    
    % Start the timer
    tic;
    
    % Initialize evaluation counter
    f_evals = 0;
    
    % FA Parameters
    n_fireflies = 15;     % Population size
    max_iter = 20;        % Maximum generations
    alpha = 0.5;          % Randomness parameter
    beta0 = 1.0;          % Attractiveness at distance r=0
    gamma = 1.0;          % Light absorption coefficient
    
    % PID Bounds: [Kp, Ki, Kd]
    lb = [0.1, 0.0, 0.01]; 
    ub = [20.0, 10.0, 5.0];
    dim = 3;
    
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
        fprintf('Iter %d/%d | Best ITAE Cost: %.4f | Kp: %.3f, Ki: %.3f, Kd: %.3f\n', ...
            iter, max_iter, best_cost, fireflies(idx, 1), fireflies(idx, 2), fireflies(idx, 3));
    end
    
    % Return the best gains found
    [~, best_idx] = min(fitness);
    K_opt = fireflies(best_idx, :);
    
    % Stop the timer
    exec_time = toc;
end