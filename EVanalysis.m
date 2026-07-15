clc;
close all;

%% Extract timeseries data
tV = batteryvoltage.Time(:);
V  = double(batteryvoltage.Data(:));

tI = batterycurrent.Time(:);
I  = double(batterycurrent.Data(:));

%% Match current data to voltage time
I = interp1(tI, I, tV, "linear", "extrap");
I = -I;
t = tV;

%% Battery power
Power_W = V .* I;

%% Separate consumed and regenerated power
DischargePower_W = max(Power_W, 0);
RegenPower_W     = max(-Power_W, 0);

%% Energy calculations
EnergyDrawn_Wh = trapz(t, DischargePower_W) / 3600;
RegenEnergy_Wh = trapz(t, RegenPower_W) / 3600;
NetEnergy_Wh   = EnergyDrawn_Wh - RegenEnergy_Wh;

%% SOC estimation using coulomb counting
InitialSOC = 100;       % %
BatteryCapacity_Ah = 100; % assumed battery capacity

ChargeUsed_Ah = cumtrapz(t, I) / 3600;

SOC = InitialSOC ...
    - (ChargeUsed_Ah / BatteryCapacity_Ah) * 100;

SOC = min(max(SOC, 0), 100);

%% Distance from your current simulation
Distance_km = 1.463;

EnergyConsumption_Whkm = NetEnergy_Wh / Distance_km;

%% Regenerative recovery percentage
if EnergyDrawn_Wh > 0
    RegenPercent = 100 * RegenEnergy_Wh / EnergyDrawn_Wh;
else
    RegenPercent = 0;
end

%% Display final results
fprintf("\n========== EV POWERTRAIN RESULTS ==========\n");
fprintf("Initial SOC              : %.2f %%\n", InitialSOC);
fprintf("Final SOC                : %.2f %%\n", SOC(end));
fprintf("SOC reduction            : %.2f %%\n", InitialSOC - SOC(end));
fprintf("Energy drawn             : %.2f Wh\n", EnergyDrawn_Wh);
fprintf("Regenerated energy       : %.2f Wh\n", RegenEnergy_Wh);
fprintf("Net energy consumed      : %.2f Wh\n", NetEnergy_Wh);
fprintf("Regenerative recovery    : %.2f %%\n", RegenPercent);
fprintf("Distance travelled       : %.3f km\n", Distance_km);
fprintf("Energy consumption       : %.2f Wh/km\n", EnergyConsumption_Whkm);
fprintf("Peak battery voltage     : %.2f V\n", max(V));
fprintf("Peak battery current     : %.2f A\n", max(abs(I)));
fprintf("Peak battery power       : %.2f kW\n", max(abs(Power_W))/1000);

%% Plot battery voltage
figure;
plot(t, V, "LineWidth", 1.2);
grid on;
xlabel("Time (s)");
ylabel("Battery Voltage (V)");
title("Battery Voltage vs Time");

%% Plot battery current
figure;
plot(t, I, "LineWidth", 1.2);
grid on;
xlabel("Time (s)");
ylabel("Battery Current (A)");
title("Battery Current vs Time");

%% Plot battery power
figure;
plot(t, Power_W/1000, "LineWidth", 1.2);
yline(0);
grid on;
xlabel("Time (s)");
ylabel("Battery Power (kW)");
title("Battery Power vs Time");

%% Plot SOC
figure;
plot(t, SOC, "LineWidth", 1.2);
grid on;
xlabel("Time (s)");
ylabel("SOC (%)");
title("Estimated Battery SOC vs Time");