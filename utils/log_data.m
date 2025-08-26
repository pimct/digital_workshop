pause(1); 
% Define serial port and board type and other variables
setDefault('port', 'COM3');
setDefault('duration', 180);  % Total duration in seconds
setDefault('interval', 2);    % Sampling interval in seconds
setDefault('change_threshold', 0.15);   % Voltage change threshold for LED trigger
setDefault('board', 'Mega2560');
% Create sensor object
setDefault('MQpins', ["A0","A1","A2"]);
setDefault('MQnames', ["MQ135","MQ2","MQ5"]);
setDefault('dhtPin', 'D7');
setDefault('LEDpin', 'D9');

addLibrary = 'Adafruit/DHTxx';
setDefault('a', arduino(port, board, 'Libraries', addLibrary));
setDefault('dht_sensor', addon(a, 'Adafruit/DHTxx', dhtPin,'DHT11')); %DHTtype Added

num_sensors = numel(MQpins) + 2;

%% Ask User if This is a Blank Test
isBlankTest = false;

%% Initialize variables
num_samples = duration / interval; % Number of data points

% Initialize data storage
time_stamps = zeros(1, num_samples);
sensor_data = zeros(num_sensors, num_samples);

%% Create figure for real-time plotting
figure;
hold on;
sensorColors = lines(num_sensors); % Assign distinct colors for each sensor
sensorPlots = gobjects(1, num_sensors); % Store plot handles

for j = 1:num_sensors
    if j == num_sensors - 1
        sensorPlots(j) = plot(nan, nan, 'Color', sensorColors(j, :), 'LineWidth', 1.5, 'DisplayName', "Temperature");
    elseif j == num_sensors
        sensorPlots(j) = plot(nan, nan, 'Color', sensorColors(j, :), 'LineWidth', 1.5, 'DisplayName', "Humidity");
    else
        sensorPlots(j) = plot(nan, nan, 'Color', sensorColors(j, :), 'LineWidth', 1.5, 'DisplayName', MQnames(j));
    end

end

xlabel("Time (s)");
ylabel("Voltage (V)");
title("Real-Time MQ Sensor Data");
legend('Location', 'BestOutside');
ylim([0 5]); % Set y-axis limits for MQ sensors
xlim([0 duration]); % Set x-axis range for total duration
grid on;
hold off;

%% Start data collection
disp('Collecting data...');

for i = 1:num_samples
    time_stamps(i) = (i - 1) * interval; % Store time

    % Read Gas Sensor Data
    for j = 1:num_sensors
        if j == num_sensors - 1
            sensor_data(j, i) = readTemperature(dht_sensor);
        elseif j == num_sensors
            sensor_data(j, i) = readHumidity(dht_sensor);
        else
            sensor_data(j, i) = readVoltage(a, MQpins(j)); 
        end
    end

    % Display readings dynamically in Command Window
    fprintf('Time: %d sec | ', time_stamps(i));
    for j = 1:num_sensors - 2
        fprintf('%s: %.2fV | ', MQnames(j), sensor_data(j, i));
    end
    fprintf('\n'); % New line after printing all sensor data

    % **Only Pause for Sample Test (Not for Blank Test)**
    if ~isBlankTest
        % Pause at 20s → Ask user to place the sample
        if time_stamps(i) == 20
            disp('🛑 Please PLACE the sample on the sensors. Press Enter to continue...');
            pause; % Wait for user confirmation
        end

        % Pause at 120s → Ask user to remove the sample
        if time_stamps(i) == 120
            disp('🛑 Please REMOVE the sample from the sensors. Press Enter to continue...');
            pause; % Wait for user confirmation
        end
    end

    % Check for significant voltage change & blink LED
    if i > 5
        significant_change = any(abs(sensor_data(:, i) - sensor_data(:, 1)) > change_threshold);
        if significant_change
            writeDigitalPin(a, LEDpin, 1);
            pause(0.5);
            writeDigitalPin(a, LEDpin, 0);
        end
    end

    % Update plots in real-time
    for j = 1:num_sensors
        set(sensorPlots(j), 'XData', time_stamps(1:i), 'YData', sensor_data(j, 1:i));
    end

    drawnow; % Ensure immediate update of the figure

    pause(interval); % Wait before next reading
end

disp('✅ Data collection completed.');

sensordata = sensor_data';
sensordata = sensordata(:, all(~isnan(sensordata)));



%% Helper functions

function setDefault(varName, defaultValue)
    if ~evalin('caller', sprintf('exist(''%s'',''var'') && ~isempty(%s)', varName, varName))
        assignin('caller', varName, defaultValue);
    end
end