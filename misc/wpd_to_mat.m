clearvars

% pathFolder = "/home/gianlum33/files/inbox/"
% pathFolder = "/net/storage/gianlum33/";
pathFolder = "/home/gianluca/files/projects/ciss-tr-model/data/digitized/";
pathFile1 = pathFolder + "eckvahl_2024_detectingChirality_fig7%s_0%i";
% pathFile0 = pathFolder + "expData_zech_aStructuralModelFor_qBand";
pathFile1Ext = pathFile1 + ".csv";

%
saveToMat = true;
%

figure(10101)
clf;
tL = tiledlayout(3, 2, "TileSpacing", "compact", "Padding", "compact");
for iplot = 1:6
    nexttile; hold on; box on;
    pathFile = sprintf(pathFile1Ext, 'a', iplot);
    importedData = readtable(pathFile);
    x1 = importedData{:, 1}';
    y1 = importedData{:, 2}';
    
    % plot(x1, y1, '-')
    
    [x2, ix] = unique(x1, 'stable');
    y2 = y1(ix);
    
    % Interpolate every spectrum to the same x-axis
    nPoint = 301;
    xx{iplot} = linspace(min(x2), max(x2), nPoint);
    yy{iplot} = interp1(x2, y2, xx{iplot});
    
    plot(xx{iplot}, yy{iplot}, '.-')

    xlim(setaxlim(xx{iplot}))
    % Check if sum of components equals y{1} (red vs light blue trace)
    % plot(xx{iplot, 1}, yy{iplot, 2} + yy{iplot, 3}, 'r')

end
% -------------------------------------------------------------------------
% I am not going to apply any additional normalization
% -------------------------------------------------------------------------

% -------------------------------------------------------------------------
% SAVE
% -------------------------------------------------------------------------
pathSave1Ext = pathFile1 + ".mat";
if saveToMat
    for iplot = 1:6
        pathSave = sprintf(pathSave1Ext, 'a', iplot);
        x = xx{iplot};
        y = yy{iplot};
        save(pathSave, 'x', 'y')
    end
end

