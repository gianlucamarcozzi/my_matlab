function correctphaseslider(x, y, harmonic)
arguments
    x
    y  % Structure
    harmonic = 1
end

%% CREATE FIGURE
fig = uifigure('Name', 'Phase slider', 'Scrollable', 'on');
figpos = fig.Position;

%% CALCULATE PHASE CORRECTED SPECTRA
y = y/max(abs(y));
if size(y, 2) < size(y, 1)
    y = transpose(y);
end
shiftphase = @(yy,p)yy*exp(1i*p*pi/180);
yph = zeros(361, size(y, 2));
for jj = 1:361
    yph(jj, :) = shiftphase(y, jj - 1);
end


axpos = [20, 20, figpos(3)*4/5, figpos(4)*4/5];
ax = uiaxes(fig, "Position", axpos);
ax.Box = 'on';

shiftphase = @(yy,p)yy*exp(1i*p*pi/180);
yph = zeros(361, size(y, 2));
for jj = 1:361
    yph(jj, :) = shiftphase(y, jj - 1);
end


axpos = [20, 20, figpos(3)*4/5, figpos(4)*4/5];
ax = uiaxes(fig, "Position", axpos);
ax.Box = 'on';

%% Create sliders
sldPhPos(1) = mean([axpos(1) + axpos(3), figpos(3)]);
sldPhPos(2:4) = [axpos(2) + axpos(4)/15, 3, axpos(4)*14/15];
sldPh = uislider(fig, 'Orientation', 'vertical', 'Position', sldPhPos);
sldPh.Limits = [0 360];
sldPh.Value = 0;

%{
sldFieldPos = [axpos(1), sldPhPos(2) + sldPhPos(4) + 10, axpos(3), 3];
sldField = uislider(fig, 'Position', sldFieldPos);
sldField.Limits = [min(x) max(x)];
sldField.MajorTicks = [];
sldField.MinorTicks = [];
sldField.Value = mean(x);
%}

%% Create buttons
btnLen = 20;
btnu = uibutton(fig, "Text", "^");
btnu.Position = [sldPhPos(1), sldPhPos(2) + sldPhPos(4) + 0.2*btnLen, ...
    btnLen, btnLen];
btnd = uibutton(fig, "Text", "v");
btnd.Position = [sldPhPos(1), sldPhPos(2) - 1.2*btnLen, btnLen, btnLen];

%% Create text boxes
txtInfoPos = [axpos(1), figpos(4), axpos(3), (figpos(4) - axpos(4))/2.5];
txtInfoPos(2) = txtInfoPos(2) - txtInfoPos(4);
% txt1Pos = [axpos(1), figpos(4) - 100, 100, 100];
txtInfo = uitextarea(fig, 'Position', txtInfoPos, ...
    'Value', 'Integral Imag = ', 'FontSize', 20);
txtSldPos = [sldPhPos(1), txtInfoPos(2), 53, txtInfoPos(4)];
txtSld = uitextarea(fig, 'Position', txtSldPos, ...
    'Value', num2str(sldPh.Value), 'FontSize', 20);
% txt2 = uitextarea(fig, 'Position', [200 10 100 30], 'Value', '2500');

%% Initial plot
plot(ax, x, real(y))
hold(ax, 'on')
plot(ax, x, imag(y))
ylimits(1) = min([real(yph(:)); imag(yph(:))]);
ylimits(2) = max([real(yph(:)); imag(yph(:))]);
ylim(ax, ylimits)
xlim(ax, setaxlim(x))

%% Set the callback functions
sldPh.ValueChangedFcn = ...
    @(src, event) sldValueChanged(src, event, txtInfo, txtSld, ax, x, ...
                                  yph, harmonic);
btnu.ButtonPushedFcn = ...
    @(src, event) btnButtonPushed(src, event, sldPh, +1);
btnd.ButtonPushedFcn = ...
    @(src, event) btnButtonPushed(src, event, sldPh, -1);
    % @(src, event) updateplot(ax);
    
end

function sldValueChanged(src, event, txtInfo, txtSld, ax, x, yph, harmonic)
    value = round(src.Value);
    %% PLOT
    yplot = yph(value + 1, :); 
    cla(ax)
    plot(ax, x, real(yplot))
    hold(ax, 'on')
    plot(ax, x, imag(yplot))
    ylimits(1) = min([real(yph(:)); imag(yph(:))]);
    ylimits(2) = max([real(yph(:)); imag(yph(:))]);
    ylim(ax, ylimits)
    xlim(ax, setaxlim(x))

    %% UPDATE TEXT AREA PHASE
    txtSld.Value = num2str(value);
    %% INTEGRAL
    dx = x(2) - x(1);
    yIntg = cumtrapz(imag(yplot))*dx;
    % Additional integration as many times as harmonic
    for ii = 1:harmonic
        yIntg = cumtrapz(yIntg);
    end
    intgValue = yIntg(end);  
    txtInfo.Value = sprintf('Integral Imag = %.2f', intgValue);
end

function btnButtonPushed(src, event, sld, direction)
    if sld.Value + direction < 0 || sld.Value + direction > 360
        return
    end
    sld.Value = sld.Value + direction;
    sld.ValueChangedFcn(sld, event)
end

