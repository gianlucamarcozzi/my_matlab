function [xRaw, yRaw, Param, yRawScan] = loadcweprlyra(filename, withScan)
    arguments
        filename
        withScan = 0
    end
    
    if withScan ~= 0 && withScan ~= 1
        warning("loadcweprlyra: scan by scan not in output because" + ...
            "withScan parameter is not equal to 1")
    end

    if isstring(filename)
        filename = char(filename);
    end
    [dirPath, measName, ~] = fileparts(filename);
    % Split again if there are two '.' in the filename e.g. *.s0001.gz
    tempstr = strsplit(measName, '.');
    measName = tempstr{1};
    measPath = fullfile(dirPath, [measName, '.akku2']);
    
    % TODO add search for .ch1 and .ch2 in case .akku2 file is not there
    if isfile(measPath)
        % Parameters
        Param = loadparamslyra(measPath);
        Param.meas_name = measName;
        % Magnetic field
        xRaw = Param.bstart:Param.bstep:Param.bstop;
        % Signal
        yRaw = loadsignallyra(measPath);
        % Adjustments:
        if numel(yRaw) ~= numel(xRaw)
            switch numel(yRaw) - numel(xRaw)
                case 1
                    % mwFreq is saved at the end of yRaw.
                    yRaw = yRaw(1:end - 1);
                case 3
                    % If gaussmeter is used, mwFreq, bstart and bstop are
                    % saved at the end of yRaw
                    xRaw = linspace(yRaw(end - 1), yRaw(end), numel(xRaw));
                    yRaw = yRaw(1:end - 3);
                otherwise
                    warning("loadcweprlyra: dimensions of xRaw and yRaw " + ...
                        "do not coincide")
            end
        end
        % Scan by scan
        if withScan == 1
            measPath = fullfile(dirPath, [measName, '.ch1']);
            ych1 = loadsignallyrachannel(measPath);
            measPath = fullfile(dirPath, [measName, '.ch2']);
            ych2 = loadsignallyrachannel(measPath);
            if size(ych1) ~= size(ych2)
                error('Not same size for ch1 and ch2 data.')
            end
            yRawScan = ych1 + 1i*ych2;
            
            if size(yRawScan, 2) ~= numel(xRaw)
                switch size(yRawScan, 2) - numel(xRaw)
                    case 1
                        % mwFreq is saved at the end of yRaw.
                        yRawScan = yRawScan(:, 1:end - 1);
                    case 3
                        % If gaussmeter is used, mwFreq, bstart and bstop are
                        % saved at the end of yRaw
                        % What happens here?
                        % xRaw = linspace(yRaw(end - 1), yRaw(end), numel(xRaw));
                        yRawScan = yRawScan(:, 1:end - 3);
                    otherwise
                        warning("loadcweprlyra: dimensions of xRaw and yRawScan " + ...
                            "do not coincide")
                end
            end
        else
            yRawScan = [];
        end
    else
        warning('loadcweprlyra: .akku2 file not found.')
    end
end

function Param = loadparamslyra(paramPath)
    params = fileread(paramPath);
    pLines = strsplit(params, '\n');
    nLine = numel(pLines);

    for ii = 1:nLine
        try
            % Some lines are empty caracters (e.g. newline)
            if strcmp(pLines{ii}(1:2), '%!')
                tempstr = strsplit(pLines{ii});
                tempstr2 = strsplit(tempstr{2}, ':');
                fieldName = tempstr2{1};
                Param.(fieldName) = str2double(tempstr{3});
            end
        catch
            continue
        end
    end
    % Timestamp
    tempstr = strsplit(pLines{2}, '? ');
    Param.timestamp = tempstr{2};
    % Comment
    tempstr = strsplit(pLines{4}, '. ');
    Param.comment = tempstr{2};
end

function yRaw = loadsignallyra(paramPath)
    importedFile = fileread(paramPath);
    pLines = strsplit(importedFile, '\n');
    nLine = numel(pLines);

    iyr = 0;  % Line where real y is
    for ii = nLine:-1:1
        if startsWith(pLines{ii}, '%!')
            iyr = ii + 1;
            break
        end
    end
    yr = str2double(strsplit(pLines{iyr}, ' '));
    yi = str2double(strsplit(pLines{iyr + 1}, ' '));
    yRaw = yr + 1i*yi;
end

function ych = loadsignallyrachannel(chPath)
    importedFile = fileread(chPath);
    pLines = strsplit(importedFile, '\n');
    nLine = numel(pLines);

    iych = 1;
    for ii = 1:nLine - 1
        if ~startsWith(pLines{ii}, '%')
            ych(iych, :) = str2double(strsplit(pLines{ii}, ' '));
            iych = iych + 1;
        end
    end
end