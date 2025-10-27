function z = arif(x)
% x(1)=10.993811;%Number of Battery %example value
% x(2)=3085.8186;%Number Of biomass KG used per hour %example value
% x(3)=9125.7649;%PV modules in parallel %example value
% x(4)= 1; %number of wind turbines %example value
NominalCapacity = 2000; % Nominal capacity of the battery (Ah)^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^cost depends
SelfDischargeRate = 0.002; % Self-discharge rate of the battery (% per hour)
ChargingEfficiency = 0.95; % Battery charging efficiency
DischargingEfficiency = 0.90; % Battery discharging efficiency
MinSOC = 0.1; % Minimum SOC (20%)
MaxSOC = 0.9; % Maximum SOC (90%)
DCBusVoltage = 480; % DC Bus Voltage (V)
BatteryVoltage = 12; % Nominal voltage of each battery (V)

% Biomass Power Calculation
CV = 18; % Calorific value of biomass (MJ/kg)
eta = 0.3; % Efficiency of the system (0 to 1)
conversion_rate = 0.000278; % Energy-to-power conversion rate (MW/MJ)

% Calculate biomass energy and power output
E_out = x(2) * CV * eta; % Total energy output (MJ)
Pbio = E_out * conversion_rate; % Total power output (MW)

% PV Power Calculation
Voc_stc = 37.5; % Open circuit voltage at standard test conditions (V)
Isc_stc = 8.21; % Short circuit current at standard test conditions (A)
FF = 0.75; % Fill factor
Ns = 2; % Number of PV modules in series
Kv = -0.123; % Open circuit voltage temperature coefficient (V/°C)
Ki = 0.0032; % Short circuit current temperature coefficient (A/°C)
NCOT = 45; % Nominal cell operating temperature (°C)
Ta = 25; % Ambient temperature (°C)
G_stc = 1000; % Solar irradiance at standard test conditions (W/m^2)

% Load solar irradiance data from .csv file
data_table = readtable('C:\My files\matlab\research\codes\data.csv', 'VariableNamingRule', 'preserve');
G_data = data_table{:, 2}; % Extract solar irradiance data
n = 8760; % Number of time steps
wind_speeds = data_table.WS10m; % Extract the 'WS10m' column

% Initialize array to store power output
Ppv = zeros(1, n);

% Compute Ppv directly in loop
for t = 1:n
    Ppv(t) = (Ns * x(3) * (Voc_stc + Kv * ((Ta + (NCOT - 20) * (G_data(t) / 800)) - 25)) * ...
              (Isc_stc + Ki * ((Ta + (NCOT - 20) * (G_data(t) / 800)) - 25) * (G_data(t) / G_stc)) * FF) / 1e6; % Convert to MW
end




% Wind turbine parameters
cut_in_speed = 1.5; % Cut-in wind speed (m/s)
rated_speed = 17; % Rated wind speed (m/s)
cut_out_speed = 25; % Cut-out wind speed (m/s)
rated_power = 1; % Rated power of the turbine (MW)^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^cost depends

a = rated_power / (rated_speed^3 - cut_in_speed^3); % Coefficient a
b = cut_in_speed^3 / (rated_speed^3 - cut_in_speed^3); % Coefficient b
h_ref = 10; % Reference height (m)
alpha = 1 / 7; % Power-law exponent
hub_height = 50; %height of the hub
Pwind = zeros(8760, 1);

for t = 1:8760
    wind_speed = wind_speeds(t) * (hub_height / h_ref)^alpha;
    if wind_speed < cut_in_speed
        Pwind(t) = 0;
    elseif wind_speed >= cut_in_speed && wind_speed <= rated_speed
        Pwind(t) = x(4) * a * wind_speed^3 - b * rated_power;
    elseif wind_speed > rated_speed && wind_speed <= cut_out_speed
        Pwind(t) = x(4) * rated_power;
    else
        Pwind(t) = 0;
    end
end





% Load Data from CSV
load_data_table = readtable('C:\My files\matlab\research\codes\hourlyload_processed.csv', 'VariableNamingRule', 'preserve');
LoadData = table2array(load_data_table(:, 2:end)); % Extract numerical load data (already in MW)

% Time parameters
TimeStep = 1; % Time step (hours)
% Initialize variables
SOC = 0.5; % Initial State of Charge (50%)
NumBatteriesInSeries = ceil(DCBusVoltage / BatteryVoltage);
TotalBatteryCapacity = NominalCapacity * x(1) * DCBusVoltage / 1e6; % Convert to MWh
PowerShortageHours = 0;

% Loop through each time step
for t = 1:8760
    TotalGeneration = Ppv(t) + Pwind(t) + Pbio; % in MW
    LoadDemand = LoadData(t); % in MW
    
    if TotalGeneration > LoadDemand
        ExcessPower = TotalGeneration - LoadDemand;
        if SOC < MaxSOC
            ChargeEnergy = min(ExcessPower, (MaxSOC - SOC) * TotalBatteryCapacity / TimeStep);
            SOC = SOC + (ChargeEnergy * TimeStep * ChargingEfficiency) / TotalBatteryCapacity;
        else
            DumpLoad = ExcessPower;
        end
    else
        DeficitPower = LoadDemand - TotalGeneration;
        if SOC > MinSOC
            DischargeEnergy = min(DeficitPower, (SOC - MinSOC) * TotalBatteryCapacity / TimeStep);
            SOC = SOC - (DischargeEnergy * TimeStep / DischargingEfficiency) / TotalBatteryCapacity;
        else
            PowerShortage = DeficitPower;
            PowerShortageHours = PowerShortageHours + 1;
        end
    end
    
    SOC = SOC - SelfDischargeRate * TimeStep;
    SOC = max(MinSOC, min(SOC, MaxSOC));
end

% ================== Economic / Cost Modeling ==================
% Capital Costs
battery_cost_per_Ah = 800;                % BDT per Ah (market average)
battery_cost = NominalCapacity * x(1) * battery_cost_per_Ah; % BDT

pv_module_cost = 12000;                   % BDT/module (typical local price)
bos_factor = 1.25;                        % Balance of system multiplier
pv_cost = Ns * x(3) * pv_module_cost * bos_factor; % BDT

turbine_cost_per_MW = 80e6;               % BDT per MW capacity (small-scale turbine)
installation_factor = 1.15;               % Installation & commissioning factor
wind_cost = x(4) * rated_power * turbine_cost_per_MW * installation_factor; % BDT

biomass_capital_cost_per_MW = 100e6;       % BDT per MW installed capacity
biomass_capital_cost = Pbio * biomass_capital_cost_per_MW; % BDT

% Annual O&M Costs
battery_om_rate = 0.02;                   % 2% of capital cost per year
pv_om_rate = 0.015;                       % 1.5% of PV capital cost per year
wind_om_rate = 0.03;                      % 3% of wind capital cost per year
biomass_fuel_cost_per_kg = 1;           % BDT/kg biomass
annual_biomass_cost = x(2) * 8760 * biomass_fuel_cost_per_kg; % BDT/year
biomass_om_rate = 0.04;                   % 4% of biomass capital cost per year

annual_om_cost = (battery_cost * battery_om_rate) + ...
                 (pv_cost * pv_om_rate) + ...
                 (wind_cost * wind_om_rate) + ...
                 (biomass_capital_cost * biomass_om_rate) + ...
                 annual_biomass_cost; % BDT/year

% Project Economics
discount_rate = 0.08;                     % 8% discount rate
project_life = 20;                        % years

% Net Present Value of O&M
present_value_om = annual_om_cost * ((1 - (1 + discount_rate)^-project_life) / discount_rate);

% Total Costs
total_capital_cost = battery_cost + pv_cost + wind_cost + biomass_capital_cost;
total_cost = total_capital_cost + present_value_om;

% Levelized Cost of Energy (LCOE)
total_energy_generated = sum(Ppv) + sum(Pwind) + (Pbio * 8760); % MWh/year approx.
present_value_energy = total_energy_generated * ((1 - (1 + discount_rate)^-project_life) / discount_rate);
LCOE = total_cost / present_value_energy; % BDT per MWh

% Apply penalty for reliability violation
if PowerShortageHours > 30
    penalty = (max(0, PowerShortageHours - 30))^2 * 1e5;
else
    penalty = 0;
end

z = total_cost + penalty;
% Optionally, optimize based on LCOE instead:
%z = LCOE + penalty;
end
