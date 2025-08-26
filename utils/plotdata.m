function [sensordata,labels] = plotdata(folderPath)
    % Get a list of all .mat files in the folder
    matFiles = dir(fullfile(folderPath, '*.mat'));
    
    % List of file names in matFiles.name
    fileNames = {matFiles.name};
    % Extract unique prefixes
    prefixes = cellfun(@(x) regexp(x, '^\D+', 'match', 'once'), fileNames, 'UniformOutput', false);
    
    x = cell(length(matFiles),1);
    sensordata = [];
    labels = categorical();
    % Loop through each .mat file and load its contents
    for k = 1:length(matFiles)
        % Get full file path
        filePath = fullfile(folderPath, matFiles(k).name);
        
        % Load the .mat file
        dat = load(filePath);
        x{k} = dat.sensor_data;
        sensordata = [sensordata; x{k}'];
    end
    
    
    
    % Create a figure for signal plots
    
    % Identify unique dataset types (prefixes)
    uniquePrefixes = unique(prefixes, 'stable'); % Extract unique dataset types
    numPrefixes = length(uniquePrefixes);
    
    % Number of sensors
    numSensors = size(x{1,1}, 1); % Assuming all datasets have the same number of sensors
    
    % Generate colors for each sensor
    sensorColors = lines(numSensors); 
    
    % Loop through each dataset type (grouping by prefix)
    for prefixIdx = 1:numPrefixes
        
        % Get the current dataset type
        currentPrefix = uniquePrefixes{prefixIdx};   
    
        % Find dataset indices belonging to the current prefix
        datasetIndices = find(strcmp(prefixes, currentPrefix));
    
        % Create a figure for this dataset type
        figure;
        hold on;
        
        % Loop through each dataset belonging to this prefix
        for datasetIdx = datasetIndices
            labels = [labels; repmat(categorical(string(currentPrefix)),[length(x{1}) 1])];
            % Loop through each sensor
            for sensorIdx = 1:numSensors
                % Extract sensor signal
                signal = x{datasetIdx, 1}(sensorIdx, :);
                
                % Plot with different color per sensor
                plot(signal, 'Color', sensorColors(sensorIdx, :), 'LineWidth', 1.2);
            end
        end
    
        % Customize plot
        title(sprintf('Sensor Signals - %s', currentPrefix));
        xlabel('Time');
        ylabel('Signal Value');
        grid on;
        
        % Add legend for sensors
        legend(arrayfun(@(s) sprintf('Sensor %d', s), 1:numSensors, 'UniformOutput', false), 'Location', 'BestOutside');
        
        hold off;
    end
end