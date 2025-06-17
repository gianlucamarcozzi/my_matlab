function [] = labelaxesfig(axRef, xLab, yLab)
%Summary of this function goes here
%   Detailed explanation goes here

% Font for label to use when the graph has more than one tile
TILEDLAYOUT_LABEL_FONT = 14;
SINGLETILE_LABEL_FONT = 16;

isTiledLayout = isa(axRef, 'matlab.graphics.layout.TiledChartLayout');

if isTiledLayout
    gridSize = axRef.GridSize;
    nr = gridSize(1);
    nc = gridSize(2);

    for ir = 1:nr
        iTile = (ir - 1)*nc + 1;
        ax = nexttile(iTile);
        if checkLatex(yLab)
            ax.YLabel.Interpreter = 'latex';
        end
        if numel(yLab) > 1
            ax.YLabel.String = yLab(ir);
        else
            ax.YLabel.String = yLab;
        end
    end
    for ic = 1:nc
        iTile = (nr - 1)*nc + ic;
        ax = nexttile(iTile);
        ax.XLabel.String = xLab;
        if checkLatex(xLab)
            ax.XLabel.Interpreter = 'latex';
        end
    end
    if nr*nc > 1
        labelFontSize = TILEDLAYOUT_LABEL_FONT;
    else
        labelFontSize = SINGLETILE_LABEL_FONT;
    end
    for iTile = 1:nr*nc
        ax = nexttile(iTile);
        setLabelFontSize(ax, labelFontSize)
    end
else
    if checkLatex(yLab)
        axRef.YLabel.Interpreter = 'latex';
    end
    axRef.YLabel.String = yLab;
    if checkLatex(xLab)
        axRef.XLabel.Interpreter = 'latex';
    end
    axRef.XLabel.String = xLab;
    
    axRef.FontSize = SINGLETILE_LABEL_FONT - 3;
    axRef.YLabel.FontSize = SINGLETILE_LABEL_FONT;
    axRef.XLabel.FontSize = SINGLETILE_LABEL_FONT;
end
end

function isLatex = checkLatex(strIn)
    isLatex = false;
    if contains(strIn, '$')
        isLatex = true;
    end
end

function [] = setLabelFontSize(ax, LabelFontSize)
    ax.FontSize = LabelFontSize - 3;
    ax.YLabel.FontSize = LabelFontSize;
    ax.XLabel.FontSize = LabelFontSize;
end
