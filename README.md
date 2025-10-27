# Hybrid Renewable Energy System Optimization using Hippopotamus Optimization Algorithm

This project implements a nature-inspired metaheuristic optimization approach to design and optimize a hybrid renewable energy system using the Hippopotamus Optimization (HO) algorithm.

## Project Overview

The system models a hybrid power generation setup combining four energy sources:
- **Photovoltaic (PV) solar power**
- **Wind turbine generation** 
- **Biomass power plant**
- **Battery energy storage**

The optimization aims to find the optimal configuration that minimizes total system cost while maintaining reliability constraints.

## Mathematical Model

### System Components

#### PV Power Generation
- Models solar irradiance using real meteorological data
- Accounts for temperature effects on voltage and current
- Calculates power output based on PV module parameters and configuration

#### Wind Power Generation
- Uses wind speed data with height correction
- Implements standard wind turbine power curve
- Models cut-in, rated, and cut-out wind speeds

#### Biomass Power Plant
- Calculates energy output based on biomass calorific value
- Considers system efficiency and conversion rates
- Models continuous fuel consumption

#### Battery Energy Storage
- Tracks state of charge (SOC) dynamics
- Models charging/discharging efficiencies
- Implements self-discharge and SOC limits

### Economic Model

**Capital Costs:**
- Battery storage cost per Ah
- PV modules with balance of system
- Wind turbines with installation
- Biomass plant capital cost

**Operational Costs:**
- Battery O&M (2% of capital)
- PV O&M (1.5% of capital) 
- Wind O&M (3% of capital)
- Biomass fuel and O&M costs

**Financial Analysis:**
- Net Present Value calculations
- Levelized Cost of Energy (LCOE)
- 20-year project life with 8% discount rate

### Optimization Objective

The objective function minimizes:
Total Cost = Capital Costs + NPV(Operational Costs) + Reliability Penalty



Reliability penalty applied if power shortage exceeds 30 hours annually.

## Algorithm Implementation

### Hippopotamus Optimization (HO)

The HO algorithm mimics hippopotamus behavior in three phases:

1. **Position Update in River/Pond** - Exploration phase simulating movement in water
2. **Defense Against Predators** - Balanced exploration using Levy flights
3. **Escaping from Predators** - Exploitation phase with local search

### Key Features

- **Population-based metaheuristic**
- **Adaptive exploration-exploitation balance**
- **Levy flight integration for global search**
- **Boundary constraint handling**

## File Structure
├── arif.m # Main objective function (hybrid system model)
├── HO.m # Hippopotamus Optimization algorithm
├── levy.m # Levy flight distribution function
├── fun_info.m # Function information and bounds
├── Main.m # Main optimization script
└── data/ # Data directory (not included in repo)
├── data.csv # Solar irradiance data
└── hourlyload_processed.csv # Electrical load data



## Requirements

- MATLAB
- Optimization Toolbox (recommended)
- Input data files for solar irradiance and load profiles

## Configuration

The optimization searches for optimal values of four decision variables:
1. Number of batteries
2. Biomass consumption rate (kg/hour) 
3. Number of PV modules in parallel
4. Number of wind turbines

## Results

The algorithm outputs:
- Best found solution (optimal system configuration)
- Convergence curve showing optimization progress
- Total system cost and component breakdown
- Reliability metrics and constraint satisfaction

## Citation

If you use this code in your research, please cite the original HO algorithm:
Amiri, M.H., Hashjin, N.M., Montazeri, M. et al. Hippopotamus Optimization Algorithm: a novel nature-inspired optimization algorithm. Sci Rep 14, 5032 (2024).
https://doi.org/10.1038/s41598-024-54910-3



## License

This project is intended for research and educational purposes.
