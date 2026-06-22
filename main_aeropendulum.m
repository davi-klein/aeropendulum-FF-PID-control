%=========================================================================%
% main_aeropendulum.m
% Orchestrator for the Aeropendulum Forward Dynamics and Control.
%=========================================================================%
clc; close all; clear; format short eng;
addpath('src');

disp('Loading physical parameters...');
params = init_aeropendulum_params();

disp('Configuring Simulink environment...');
model_name = 'aeropendulum_dynamics';
load_system(model_name);

% Create a simulation input object
simIn = Simulink.SimulationInput(model_name);

% Inject the 'params' struct safely into the simulation workspace
simIn = simIn.setVariable('p', params);

disp('Running Simulation...');
simOut = sim(simIn);

disp('Simulation finished successfully.');
% Here you can plot your results using simOut (e.g., simOut.tout)