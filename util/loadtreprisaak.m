function [xRaw, yRaw, yRuns, Param] = loadtreprisaak(filename)
    if isstring(filename)
        filename = char(filename);
    end
    [dirPath, measName, ~] = fileparts(filename);
    % Split again if there are two '.' in the filename e.g. *.s0001.gz
    tempstr = strsplit(measName, '.');
    measName = tempstr{1};
    fullBaseName = fullfile(dirPath, measName);

    % Parameters and axes B, t
    paramPath = [fullBaseName '.meta'];
    if isfile(paramPath)
        Param = loadparamsisaak(paramPath);
        Param.meas_name = measName;
        xRaw{1} = linspace(0, Param.slicelength, Param.npoints);
        xRaw{2} = Param.bstart:Param.bstep:Param.bstop;
        xRaw{2} = xRaw{2}';
    else
        warning('loadtreprisaak: .meta file not found.')
    end
    
    % Transients
    fileExt = '.s*.gz';
    runsPath = [fullBaseName fileExt];
    loadDir = dir(runsPath);
    loadDir = sortstructurebyfield(loadDir, 'name');
    if isempty(loadDir)
        error('loadtreprisaak: .gz file not found.')
    end
    nRun = numel(loadDir);
    for ii = 1:nRun
        filePath = fullfile(loadDir(ii).folder, loadDir(ii).name);
        yRuns{ii} = loadzipfile(filePath); 
        yRuns{ii} = yRuns{ii}';
    end

    % Average the spectra
    yRaw = zeros(size(yRuns{1}));
    for ii = 1:nRun
        yRaw = yRaw + yRuns{ii};
    end
    yRaw = yRaw/nRun;
end

function Param = loadparamsisaak(paramPath)
    params = fileread(paramPath);
    pLines = strsplit(params, '%');
    nLine = numel(pLines);

    for ii = 1:nLine
        if startsWith(pLines{ii}, '!')
            tempstr = strsplit(pLines{ii});
            tempstr2 = strsplit(tempstr{2}, ':');
            fieldName = tempstr2{1};
            Param.(fieldName) = str2double(tempstr{3});
        elseif startsWith(pLines{ii}, '.')
            tempstr = strsplit(pLines{ii});
            tempstr2 = strsplit(tempstr{2}, ':');
            fieldName = tempstr2{1};
            Param.(fieldName) = tempstr{3};
        end
    end
    calibData = load(paramPath);
    try
        Param.mw_frequency_start = calibData(:, 1);
        Param.mw_frequency_end = calibData(:, 2);
        Param.laser_mean_power = calibData(:, 3);
        Param.laser_rms = calibData(:, 4);
        Param.laser_mean_power_avg = mean(Param.laser_mean_power);
    catch
        warning('loadtreprisaak: laser calibration data not present.')
    end
    tempstr = strsplit(pLines{3}, '? ');
    Param.timestamp = tempstr{2};
end

function out = loadzipfile(filePath)
    unzipedFile = gunzip(filePath);
    out = load(unzipedFile{1, 1});
    delete(unzipedFile{1, 1}) % Delete the unziped file from the folder
end