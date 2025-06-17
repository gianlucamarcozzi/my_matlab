function [x, y, Param] = averagetreprscanselexsys(folder, nScans, freqCorr, iTimeCorr)
arguments
    folder
    nScans = 0
    freqCorr = 9.6
    iTimeCorr = 0
end

dirFolder = dir(append(folder, '/*.DTA'));
nMeas = numel(dirFolder);

if nMeas == 0
    error("averagetreprscanselexsys: empty folder!")
end
if nScans == 0
    nScans = nMeas;
end

for ii = 1:nScans
    filename = fullfile(dirFolder(ii).folder, dirFolder(ii).name);
    [x0{ii}, y0{ii}, Param0{ii}] = eprload(filename);
end

%% FREQUENCY CORRECTION AND INTERPOLATION

xCorr = x0;
for ii = 1:nScans
    % Correct frequency to freqCorr
    xCorr{ii}{2} = ...
        x0{ii}{2}*(freqCorr./Param0{ii}.MWFQ*1e9);
end

% Interpolate wrt the first field-axis
x = xCorr{1};
for ii = 1:nScans
    yCorr0{ii} = interp2(xCorr{ii}{2}, xCorr{ii}{1}, y0{ii}, x{2}, x{1});
end

% Correct field-axis for different length of the frequency-shifted axis
for ii = 1:nScans
    minFields(ii) = min(xCorr{ii}{2});
    maxFields(ii) = max(xCorr{ii}{2});
end
lowField = max(minFields);
highField = min(maxFields);
[~, iLowField] = min(abs(x{2} - lowField));
[~, iHighField] = min(abs(x{2} - highField));

x{2} = x{2}(iLowField:iHighField);
for ii = 1:nScans
    yCorr1{ii} = yCorr0{ii}(:, iLowField:iHighField);
end

% Take out columns of nan values
for ii = 1:nScans
    idx(:, ii) = isnan(yCorr1{ii}(1, :));
end
idxFin = sum(idx, 2);
for ii = 1:nScans
    yCorr{ii} = yCorr1{ii}(:, ~idxFin);
end
x{2} = x{2}(~idxFin);

% Average the scans and store in yOut
y = zeros(size(yCorr{1}));
for iScan = 1:nScans
    y = y + yCorr{iScan}/nScans;
end

Param = Param0{1};
tempTitle = strsplit(Param.TITL, '-');
Param.TITL = strjoin(tempTitle(1:end-1), '-');

end