%=========================================================================%
% main_aeropendulum.m
% Orchestrator for the Aeropendulum Forward Dynamics and Control.
%=========================================================================%
clc; close all; clear; format short eng;
addpath('src');

disp('Loading physical parameters...');
p = init_aeropendulum_params();
assignin('base', 'p', p)

fprintf('Generating %s trajectory...', p.type);
th_ref_ts = generate_aeropendulum_refs(p.type, p.stpt, p.dt);

disp('Configuring Simulink environment...');
model_name = 'aeropendulum_dynamics';
load_system(model_name);

disp('======================================================');
disp('-------------Starting Firefly Optimization------------');
disp('======================================================');

warning('off', 'Simulink:Commands:SimulationsWithErrors');

% Pass the sine wave for tuning 
[K_opt, f_evals, exec_time] = FMA(model_name, th_ref_ts);

warning('on', 'Simulink:Commands:SimulationsWithErrors');

fprintf('\n=== Optimization Results ===\n');
fprintf('Kp = %.4f\nKi = %.4f\nKd = %.4f\n', K_opt(1), K_opt(2), K_opt(3));
fprintf('----------------------------\n');
fprintf('Function Evaluations : %d\n', f_evals);
fprintf('Total Execution Time : %.2f seconds\n', exec_time);
fprintf('Time per Evaluation  : %.4f seconds\n\n', exec_time / f_evals);

% Simulate and plot optimal response
opt_metrics.f_evals = f_evals;
opt_metrics.exec_time = exec_time;
opt_metrics.time_per_eval = exec_time / f_evals;

post_process_results(p.type, model_name, K_opt, th_ref_ts, opt_metrics)