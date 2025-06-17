setMousePointer()

function sliderApp
fig = uifigure("Position",[100 100 300 250]);
g = uigridlayout(fig);
g.RowHeight = {'1x','fit'};
g.ColumnWidth = {'1x','fit','1x'};

cg = uigauge(g);
cg.Layout.Row = 1;
cg.Layout.Column = [1 3];

sld = uislider(g, ...
    "ValueChangedFcn",@(src, event)updateGauge(src, event, cg));
sld.Layout.Row = 2;
sld.Layout.Column = 2;
end

function updateGauge(src,event,cg)
cg.Value = event.Value;
end

function setMousePointer
fig = uifigure('Position',[500 500 375 275]);
fig.WindowButtonMotionFcn = @mouseMoved;

btn = uibutton(fig);
btnX = 50;
btnY = 50;
btnWidth = 100;
btnHeight = 22;
btn.Position = [btnX btnY btnWidth btnHeight];
btn.Text = 'Submit Changes';

    function mouseMoved(src,event)
        mousePos = fig.CurrentPoint;
        if (mousePos(1) >= btnX) && (mousePos(1) <= btnX + btnWidth) ...
                && (mousePos(2) >= btnY) && (mousePos(2) <= btnY + btnHeight)
              fig.Pointer = 'hand';
        else
              fig.Pointer = 'arrow';
        end
    end
end