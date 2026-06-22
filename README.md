\# Aeropendulum Digital Twin \& PID Control



!\[MATLAB](https://img.shields.io/badge/MATLAB-R2023a%2B-blue.svg)

!\[Simulink](https://img.shields.io/badge/Simulink-Dynamic%20Simulation-orange.svg)

!\[Architecture](https://img.shields.io/badge/Architecture-API%20Driven-success.svg)



This repository contains a production-ready simulation environment (Digital Twin) and control architecture for an Aeropendulum system. It implements a non-linear forward dynamics model, actuator dynamics (DC Motor), and a hybrid control strategy combining a PID controller with Gravity Compensation (Feedforward).



\## Engineering \& Software Highlights



Tailored for scalability and reproducibility, this project diverges from standard academic scripting by employing strict software engineering principles:



\* \*\*API-Driven Co-Simulation:\*\* The MATLAB-Simulink bridge is built using the `Simulink.SimulationInput` API. This isolates the simulation memory space, preventing Base Workspace pollution and enabling parallel, headless execution for future AI/Reinforcement Learning training loops.

\* \*\*Single Source of Truth:\*\* All mechanical, aerodynamic, and actuator parameters are decoupled from the Simulink blocks and encapsulated within a single structural data model (`init\_aeropendulum\_params.m`).

\* \*\*Non-Linear Dynamics Modeling:\*\* The plant accurately models non-linear aerodynamic drag, static friction, and thrust-coefficient limits, providing a highly realistic environment for control validation.



\## Repository Architecture



```text

aeropendulum-simulation/

├── src/                        # Physics and Configuration API

│   └── init\_aeropendulum\_params.m  # Encapsulated physical data model

├── aeropendulum\_dynamics.slx   # Simulink model (Plant + Controller)

└── main\_aeropendulum.m         # Orchestrator script

```



\## Getting Started



1\. Clone the repository.

2\. Open MATLAB and navigate to the project root.

3\. Run the orchestration script:

&#x20;  ```matlab

&#x20;  run('main\_aeropendulum.m')

&#x20;  ```



\## Author



\*\*Davi Klein\*\*

M.Sc. Student in Computer Science | Control Systems \& Software Engineering

Federal University of Santa Maria (UFSM)

