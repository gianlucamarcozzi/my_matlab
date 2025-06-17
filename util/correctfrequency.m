function [xOut, yOut] = correctfrequency(x, y, Param, freqCorr)
%% Data correction
if numel(x) ~= numel(y)
    error("x and y must be cell arrays of the same length")
end
nMeas = numel(x);

% Interpolate wrt the field-axis of the first scan
switch class(x{1})
    case "double"
        % Correct frequency to freqCorr
        for ii = 1:nMeas
            % % Laser flash at t = 0
            % x1{ii}{1} = x{ii}{1} - x{ii}{1}(iTimeCorr);
            x1{ii} = x{ii}*(freqCorr./Param{ii}.MWFQ);
        end

        % Store the x-axes in xBase
        xBase = x1{1};

        % Interpolate
        for ii = 1:nMeas
            y1{ii} = interp1( ...
                x1{ii}, y{ii}, xBase);
        end

        % Correct field-axis for different length of the frequency-shifted axis
        [minFields, maxFields] = deal(zeros(1, nMeas));
        for ii = 1:nMeas
            minFields(ii) = min(x1{ii});
            maxFields(ii) = max(x1{ii});
        end
        lowField = max(minFields);
        highField = min(maxFields);
        [~, iLowField] = min(abs(xBase - lowField));
        [~, iHighField] = min(abs(xBase - highField));

        xOut = xBase(iLowField:iHighField);
        for ii = 1:nMeas
            yOut{ii} = y1{ii}(iLowField:iHighField);
        end

    case "cell"
        if numel(x{1}) ~= 2
            error("x should be a (1, nMeas) cell array of cells (1, 2)")
        end

        % Correct frequency to freqCorr
        for ii = 1:nMeas
            % % Laser flash at t = 0
            % x1{ii}{1} = x{ii}{1} - x{ii}{1}(iTimeCorr);
            % Correct frequency to freqCorr
            x1{ii}{2} = x{ii}{2}*(freqCorr./Param{ii}.MWFQ);
            x1{ii}{1} = x{ii}{1};
        end

        % Store the x-axes in xOut
        xBase = x1{1};

        % Interpolate
        for ii = 1:nMeas
            y1{ii} = interp2( ...
                x1{ii}{2}, x1{ii}{1}, y{ii}, xBase{2}, xBase{1});
        end

        % Correct field-axis for different length of the frequency-shifted axis
        [minFields, maxFields] = deal(zeros(1, nMeas));
        for ii = 1:nMeas
            minFields(ii) = min(x1{ii}{2});
            maxFields(ii) = max(x1{ii}{2});
        end
        lowField = max(minFields);
        highField = min(maxFields);
        [~, iLowField] = min(abs(xBase{2} - lowField));
        [~, iHighField] = min(abs(xBase{2} - highField));

        x2{1} = xBase{1};
        x2{2} = xBase{2}(iLowField:iHighField);
        for ii = 1:nMeas
            y2{ii} = y1{ii}(:, iLowField:iHighField);
        end

        % Eliminate rows with NaN values
        xOut = x2;
        yOut = y2;
        for ii = 1:nMeas
            iNan = isnan(yOut{ii}(1, :));
            if sum(iNan) > 0
                fprintf("Index %d had %d row(s) of NaN values", ii, sum(iNan))
                xOut{2} = xOut{2}(~iNan);
                for jj = 1:nMeas
                    yOut{jj} = yOut{jj}(:, ~iNan);
                end
            end
        end

    otherwise
        error("x must be a cell array of cells or a cell array of scalars")
end



%{
% Average the scans and store in yOut
yOut = zeros(size(yCorr{1}));
for ii = 1:nMeas
    yOut = yOut + yCorr{ii}/nMeas;
end

% Store average params in ParamOut
ParamOut = Param{1};
titleTemp = strsplit(measFolder(1).folder, '/');
if numel(titleTemp) == 1  % Windows
    titleTemp = strsplit(measFolder(1).folder, '\');
end
ParamOut.TITL = titleTemp(end);
ParamOut.FrequencyMon = '';
ParamOut.Power = '';
ParamOut.MWFQ = 0;
ParamOut.MWPW = 0;
for ii = 1:nMeas
    ParamOut.MWFQ = ParamOut.MWFQ + Param{ii}.MWFQ/nMeas;
    ParamOut.MWPW = ParamOut.MWPW + Param{ii}.MWPW/nMeas;
end
%}
