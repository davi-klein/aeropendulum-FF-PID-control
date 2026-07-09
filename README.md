# Aeropendulum Digital Twin & Metaheuristic PID Control

![MATLAB](https://img.shields.io/badge/MATLAB-R2023a%2B-blue.svg)
![Simulink](https://img.shields.io/badge/Simulink-Dynamic%20Simulation-orange.svg)
![Optimization](https://img.shields.io/badge/Optimization-Firefly%20Algorithm-success.svg)
![Architecture](https://img.shields.io/badge/Architecture-API%20Driven-lightgrey.svg)

This repository contains a production-ready simulation environment (Digital Twin) and an automated metaheuristic optimization architecture for an Aeropendulum system. It implements a non-linear forward dynamics model, actuator dynamics (DC Motor), and a hybrid control strategy that allows seamless toggling between a Pure PID controller and a PID with Gravity Feedforward Compensation.

The core of this project is an automated tuning pipeline that utilizes the **Firefly Metaheuristic Algorithm (FMA)** to optimize controller gains based on the Integral of Time-Weighted Absolute Error (ITAE) cost function, specifically designed to evaluate high-speed continuous tracking of sinusoidal and bipolar trapezoidal trajectories.

## Engineering & Software Highlights

Tailored for academic research and rigorous journal submissions, this project diverges from standard academic scripting by employing strict software engineering and advanced control theory principles:

* **Metaheuristic Optimization Engine:** Implements a custom Firefly Algorithm with exploration-forward parameters and smart stagnation-based early termination. The optimization landscape's search space boundaries are dynamically calculated based on third-order position error dynamics, strict bandwidth limits (10 Hz) to avoid resonance, and critical damping criteria ($\zeta = 1$).
* **API-Driven Co-Simulation:** The MATLAB-Simulink bridge is built using the `Simulink.SimulationInput` API. This isolates the simulation memory space, preventing Base Workspace pollution and enabling robust, automated multi-cycle evaluations.
* **Publication-Ready Pipeline:** Fully automated data extraction and formatting. The system automatically evaluates performance metrics (RMSE, Max Error), saves raw simulation data to `.mat` files, and generates precisely scaled, dual-axis vector graphics (`.pdf`) optimized for LaTeX double-column manuscript templates.
* **Non-Linear Dynamics Modeling:** The plant accurately models non-linear aerodynamic drag, static friction, viscous damping, and strict 12V actuator saturation limits, providing a highly realistic environment for control validation and anti-windup testing.

## Repository Architecture

```text
aeropendulum-simulation/
├── src/                             # Physics, Control, and Processing API
│   ├── init_aeropendulum_params.m   # Encapsulated physical data and solver config
│   ├── generate_aeropendulum_refs.m # Continuous sine and bipolar trapezoidal math
│   ├── FMA.m                        # Firefly Metaheuristic Algorithm logic
│   └── post_process_results.m       # Auto-generates metrics, .mat data, and LaTeX PDFs
├── data/                            # Auto-generated directory for .mat numerical results
├── figs/                            # Auto-generated directory for high-res vector graphics
├── aeropendulum_dynamics.slx        # Simulink model (Plant + Controller + Anti-Windup)
└── main_aeropendulum.m              # Orchestrator script
```

## Getting Started

1. Clone the repository to your local machine.
2. Open MATLAB and navigate to the project root directory.
3. Configure your desired trajectory and control topology (Pure PID vs. FF) in `init_aeropendulum_params.m`.
4. Run the orchestration script to begin the optimization and auto-generate your paper's figures:
   ```matlab
   run('main_aeropendulum.m')
   ```

## Author

**Davi Klein** M.Sc. Student in Computer Science | Control Systems & Software Engineering  
Federal University of Santa Maria (UFSM)
