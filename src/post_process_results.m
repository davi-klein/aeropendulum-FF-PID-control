function post_process_results(type, model_name, K_opt, th_ref_ts, opt_metrics, use_ff)
% POST_PROCESS_RESULTS Simulates, plots, and saves optimal aeropendulum data
% Args:
%   type: trajectory type ('sine' or 'trapezoidal')
%   model_name: name of the simulink model file
%   K_opt: vector with optimized PID gains
%   th_ref_ts: timeseries of the desired trajectory
%   opt_metrics: struct containing algorithm performance data
%   use_ff: 1 for Gravity FF enabled, 0 for Pure PID

    % 1. Determine Controller Labels for Titles and Filenames
    if use_ff == 1
        ctrl_title = 'PID + FF';
        ctrl_file  = 'PID_FF';
    else
        ctrl_title = 'Pure PID';
        ctrl_file  = 'purePID';
    end

    % Simulate Optimal Response
    fprintf('Simulating optimal %s response...\n', ctrl_title);
    
    simIn = Simulink.SimulationInput(model_name);
    simIn = simIn.setVariable('Kp', K_opt(1));
    simIn = simIn.setVariable('Ki', K_opt(2));
    simIn = simIn.setVariable('Kd', K_opt(3));
    simIn = simIn.setVariable('th_ref', th_ref_ts);
    
    simIn = simIn.setModelParameter('SimulationMode', 'normal');
    out = sim(simIn);
    
    % Extract Data and Calculate Metrics
    theta_out = out.logsout.get('theta_out').Values;
    error_sig = out.logsout.get('tracking_error').Values;
    control_sig = out.logsout.get('u_total').Values;
    
    % Convert error to degrees 
    e_deg = error_sig.Data * (180/pi);
    rmse_val = sqrt(mean(e_deg.^2));
    max_err = max(abs(e_deg));
    
    fprintf('\n=== Final Performance Metrics (%s | %s) ===\n', type, ctrl_title);
    fprintf('RMSE       : %.4f degrees\n', rmse_val);
    fprintf('Max Error  : %.4f degrees\n', max_err);
    fprintf('========================================\n\n');
    
    % 3. Generate Plots
    disp('Generating independent figures...');
    
    % RGB Color Palette
    modern_blue  = [0, 0.4470, 0.7410];
    modern_red   = [0.8500, 0.3250, 0.0980];
    modern_green = [0.4660, 0.6740, 0.1880];
    
    fig_pos = [100, 100, 520, 230]; 
    t_max = max(theta_out.Time);
    
    % --- FIGURE 1: Trajectory Tracking ---
    fig_track = figure('Name', 'Trajectory Tracking', 'Position', fig_pos, 'Color', 'w');
    plot(th_ref_ts, 'k--', 'LineWidth', 1.5); hold on;
    plot(theta_out, 'Color', modern_blue, 'LineWidth', 1.8);
    grid on; xlim([0, t_max]);
    xlabel('Time (s)', 'FontSize', 10); ylabel('\theta (rad)', 'FontSize', 10);
    legend('\theta_{ref}', '\theta', 'Location', 'best', 'FontSize', 9);
    title(sprintf('%s Trajectory Tracking (%s)', titleCase(type), ctrl_title), 'FontSize', 11, 'FontWeight', 'bold');
    set(gca, 'FontSize', 9);
    
    % --- FIGURE 2: Tracking Error ---
    fig_err = figure('Name', 'Tracking Error', 'Position', fig_pos, 'Color', 'w');
    plot(error_sig.Time, e_deg, 'Color', modern_red, 'LineWidth', 1.5);
    grid on; xlim([0, t_max]);
    xlabel('Time (s)', 'FontSize', 10); ylabel('Error (degrees)', 'FontSize', 10);
    title(sprintf('Tracking Error Profile (%s)', ctrl_title), 'FontSize', 11, 'FontWeight', 'bold');
    set(gca, 'FontSize', 9);
    
    % --- FIGURE 3: Control Action ---
    fig_ctrl = figure('Name', 'Control Action', 'Position', fig_pos, 'Color', 'w');
    plot(control_sig.Time, control_sig.Data, 'Color', modern_green, 'LineWidth', 1.5); hold on;
    yline(12, 'k--', 'LineWidth', 1); yline(-12, 'k--', 'LineWidth', 1); 
    grid on; xlim([0, t_max]); ylim([-14, 14]);
    xlabel('Time (s)', 'FontSize', 10); ylabel('Control Input (V)', 'FontSize', 10);
    title(sprintf('Controller Output Voltage (%s)', ctrl_title), 'FontSize', 11, 'FontWeight', 'bold');
    set(gca, 'FontSize', 9);
    
    drawnow; % Force full rendering
    
    % Export Data to .mat
    disp('Exporting optimal trajectory data to .mat file...');
    
    folder_name = 'data';
    if ~exist(folder_name, 'dir')
        mkdir(folder_name);
    end
    
    % Build the results structure
    sim_data.type = type;
    sim_data.control_type = ctrl_title; % Secure the label inside the data struct
    sim_data.K_opt = K_opt;
    sim_data.opt_metrics = opt_metrics;
    sim_data.performance.rmse_deg = rmse_val;
    sim_data.performance.max_err_deg = max_err;
    sim_data.time = theta_out.Time;
    sim_data.reference = th_ref_ts.Data;
    sim_data.actual = theta_out.Data;
    
    % Create a timestamped filename incorporating trajectory AND control type
    timestamp = char(datetime('now', 'Format', 'yyyy_MM_dd_HHmmss'));
    filename = sprintf('aeropendulum_opt_%s_%s_%s.mat', type, ctrl_file, timestamp);
    full_filepath = fullfile(folder_name, filename);
    
    save(full_filepath, '-struct', 'sim_data');
    fprintf('Data successfully secured in: %s\n\n', full_filepath);
    
    % Export Figure
    disp('Exporting separate PDFs for LaTeX...');
    figs_folder = 'figs';
    if ~exist(figs_folder, 'dir'), mkdir(figs_folder); end
    
    % Save paths injected with the control type
    path_track = fullfile(figs_folder, sprintf('aeropendulum_tracking_%s_%s.pdf', type, ctrl_file));
    path_error = fullfile(figs_folder, sprintf('aeropendulum_error_%s_%s.pdf', type, ctrl_file));
    path_control = fullfile(figs_folder, sprintf('aeropendulum_control_%s_%s.pdf', type, ctrl_file));
    
    % Vector export with auto-cropping
    exportgraphics(fig_track, path_track, 'ContentType', 'vector', 'BackgroundColor', 'none');
    exportgraphics(fig_err, path_error, 'ContentType', 'vector', 'BackgroundColor', 'none');
    exportgraphics(fig_ctrl, path_control, 'ContentType', 'vector', 'BackgroundColor', 'none');
    
    fprintf('All figures successfully exported to /%s/\n\n', figs_folder);
end

function str = titleCase(str)
    if isempty(str), return; end
    str(1) = upper(str(1));
end