%% Linear/non-linear fitting model
function [yfit, linCoeffs] = mldividefun(y, fun, p)
    % First calculate the exponential without scaling, then fit the linear
    % scaling parameter.
    % Solve Y = XA, where y: (y1 ... yn) = (1 ... 1, x1 ... xn)(a0, a1),
    % matrix form of y = a0 + a1*x. In this case, the matrix X is exp(-x/tau),
    % while Y = y.
    X = fun(p);

    % X = [ones(length(y), 1) yfun];
    linCoeffs = X \ y; % Solve linear equation: yfit * amplitude + C = y.
    yfit = fun(p) * linCoeffs;

end