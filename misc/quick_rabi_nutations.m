clearvars
[x, y] = eprload("/home/gianluca/files/mnt/1/files/projects/temp/ee");

expcos = @(xx, p) [exp(-xx/p(1)).*cos(2*pi*p(2)*xx), ones(numel(xx), 1)];
fitOpt = optimoptions('lsqnonlin','Display','off');

w0 = 30*1e-3;
p0 = [40, w0];
fitmodel = @(p) expcos(x, p);
ydata = real(y);
ydata = ydata/max(ydata);

[yfit, pfit, pci] = lsqnonlin2steps(ydata, fitmodel, p0, fitOpt);

figure(111)
clf
plot(x, ydata, 'o')
hold on
plot(x, yfit)
title(sprintf('%.4f MHz, %.2f ns', pfit(2)*1e3, 1/2/pfit(2)))

% NEXTTILE ---------------------------------------------------------------
%{
nexttile
% errorbar(1:nMeas, freq, pci(:, 2, 1) - freq', pci(:, 2, 2) - freq', 'o')
errorbar(1:nMeas, freq, pci(:, 2, 1) - freq', pci(:, 2, 2) - freq', 'o')
xlim([0.9, nMeas + 0.1])
%}
%-------------------------------------------------------------------------

%% FFT
%{
nMeas = 1;
APPLY_WINDOW = 1;
tStep = x{1}(2) - x{1}(1);
fSampl = 1/tStep;
nzf = 1024;  % Zero filling
winham = windowhamming(numel(y{1}), 1);
if APPLY_WINDOW
    winrabii = winham.*y{1}';  % Apply window function
else
    winrabii = y{1};
end
nexttile(2)
plot(x{1}, winrabii)

if nzf ~= 0
    fxrabi = fSampl/nzf*(-nzf/2:nzf/2 - 1);  % Freq axis
    frabii = zeros(nMeas, nzf);  % Initialize fft arrays
    winrabii(:, nzf) = zeros(nMeas, 1);  % Zero filling
else
    fxrabi = fSampl/nTau*(-nTau/2:nTau/2 - 1);  % Freq axis
    frabii = zeros(nMeas, nTau);  % Initialize fft arrays
end
nexttile(3)
plot(1:nzf, winrabii)

for ii = 1
    frabii(ii, :) = fft(winrabii(ii, :));

    nexttile
    plot(fxrabi, abs(fftshift(frabii(ii, :))), 'o-')
    xlim([-0.1, 0.1])
end
%}
