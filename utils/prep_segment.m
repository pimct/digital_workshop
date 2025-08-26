function segment = prep_segment(matFiles)
        % Load the .mat file
        dat = load(matFiles);
        sensordata = dat.sensor_data';
        sensordata = sensordata(:, all(~isnan(sensordata)));
        segment = {sensordata};
end