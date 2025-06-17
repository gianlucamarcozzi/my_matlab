function plotbaselinecorrection(data, baselineRegion)
    NROW = 2;
    NCOL = 2; % even number: one col for real, one for imag
    nDatas = numel(data);
    nFigs = nDatas/NROW;
    if mod(nFigs, 1)
        nFigs = fix(nFigs) + 1;
    end
    for iFig = 1:nFigs
        figure();
        tiledlayout(NROW, NCOL, ...
                    'TileSpacing', 'compact', 'Padding', 'compact')
        for iData = ((iFig - 1)*NROW + 1):(iFig*NROW)
            if iData > nDatas
                break
            end
            for iCol = 1:NCOL/2
                nexttile()
                x_ = data(iData).x;
                y_ = real(data(iData).DataPrep.yRaw);
                baseline_ = real(data(iData).DataPrep.baseline);
                plot(x_, y_, 'Color', 'k')
                hold on
                plot(x_, baseline_)
                xlim(setAxLim(x_, 0))
                ylim(setAxLim(y_, 0.05))

                baselineRange = getbaselinerange(x_, baselineRegion);
                xline(baselineRange(1,1));
                xline(baselineRange(1,2));
                xline(baselineRange(2,1));
                xline(baselineRange(2,2));
                title(strcat(data(iData).filename, ' (0° modulation)'))
                nexttile()
                try
                    x_ = data(iData).x;
                    y_ = imag(data(iData).DataPrep.yRaw);
                    baseline_ = imag(data(iData).DataPrep.baseline);
                    plot(x_, y_, 'Color', 'k')
                    hold on
                    plot(x_, baseline_)
                    xlim(setAxLim(x_, 0))
                    ylim(setAxLim(y_, 0.05))
                    xline(baselineRange(1,1));
                    xline(baselineRange(1,2));
                    xline(baselineRange(2,1));
                    xline(baselineRange(2,2));
                    title(strcat(data(iData).filename, ' (90° modulation)'))
                catch
                    
                end
            end
        end
    end
end

function baselineRange = getbaselinerange(x, baselineRegion)
    if numel(baselineRegion) == 1 % Opt.width parameter.
        width = (max(x) - min(x))*baselineRegion;
        [~, range12No] = min(abs(x - (min(x) + width)));
        [~, range21No] = min(abs(x - (max(x) - width)));
        baselineRange = [min(x), x(range12No); x(range21No), max(x)];
    else
        baselineRange = baselineRegion;
    end
end