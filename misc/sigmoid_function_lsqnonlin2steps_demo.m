%%
clearvars

%% 
sigfun = @(x, p) 1./(1 + exp(p(1)*(x - p(2))));

%%
N_POINTS = 31;
X_INIT = 0;
X_FIN = 100;
xdata = linspace(X_INIT, X_FIN, N_POINTS);
xdata = transpose(xdata);

AMP = 5;
BL = 2;
STEEPNESS = -0.5;
X_CROSS = 50;
p0 = [STEEPNESS, X_CROSS];
ydata = AMP*sigfun(xdata, p0) + BL;
SNR = 20;
ydata = addnoise(ydata, SNR, "n");

figure(1)
clf
plot(xdata, ydata)

%%

fitmodel = @(p) sigfun(xdata, p);
p0 = [-0.1, 60];
[yfit, pfit, dpfit] = lsqnonlin2steps(ydata, fitmodel, p0, true);

figure(1)
clf
plot(xdata, ydata)
hold on
plot(xdata, yfit)