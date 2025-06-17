clearvars

% pathFolder = "/home/gianlum33/files/inbox/"
% pathFolder = "/net/storage/gianlum33/";
pathFolder = "/home/gianluca/files/projects/oop-ciss-calculations/data/digitized/";
pathFile1 = pathFolder + "hore2023_conditionsForEPR_fig5_0%i_0%i";
% pathFile0 = pathFolder + "expData_zech_aStructuralModelFor_qBand";
pathFile1Ext = pathFile1 + ".csv";

%
saveToMat = true;
%

figure(10101)
clf;
tL = tiledlayout(2, 2, "TileSpacing", "compact", "Padding", "compact");
for iplot = 1:4
    nexttile; hold on; box on;
    for ii = 1:3
        pathFile = sprintf(pathFile1Ext, iplot, ii);
        importedData = readtable(pathFile);
        x1 = importedData{:, 1}';
        y1 = importedData{:, 2}';
        
        % plot(x1, y1, '-')
        
        [x2, ix] = unique(x1, 'stable');
        y2 = y1(ix);
        
        % Interpolate every spectrum to the same x-axis
        nPoint = 301;
        xx{iplot, ii} = linspace(min(x2), max(x2), nPoint);
        yy{iplot, ii} = interp1(x2, y2, xx{iplot, 1});
        
        plot(xx{iplot, 1}, yy{iplot, ii}, '.-')
    end
    xlim(setaxlim(xx{iplot, 1}))
    % Check if sum of components equals y{1} (red vs light blue trace)
    plot(xx{iplot, 1}, yy{iplot, 2} + yy{iplot, 3}, 'r')

end
% -------------------------------------------------------------------------
% I am not going to apply any additional normalization
% -------------------------------------------------------------------------

% -------------------------------------------------------------------------
% SAVE
% -------------------------------------------------------------------------
pathSave1Ext = pathFile1 + ".mat";
if saveToMat
    for iplot = 1:4
        for ii = 1:3
            pathSave = sprintf(pathSave1Ext, iplot, ii);
            x = xx{iplot, 1};
            y = yy{iplot, ii};
            save(pathSave, 'x', 'y')
        end
    end
end

