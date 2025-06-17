function [yfit, X, dX] = lsqnonlin2steps(ydata, fitmodel, p0, fitOpt)
    arguments
        ydata
        fitmodel
        p0
        fitOpt = optimoptions('lsqnonlin','Display','off');
    end
    if size(ydata, 1) == 1
        ydata = transpose(ydata);
    elseif size(ydata, 2) == 1
        %
    else
        error("ydata should have at least one dimension with length 1.")
    end
    [X, ~, residual, ~, ~, ~, jacobian] = ...
        lsqnonlin(@(p) ydata - mldividefun(ydata, fitmodel, p), ...
        p0, [], [], fitOpt);
    pci = nlparci(X, residual, 'jacobian', jacobian);
    dX = abs(pci(:, 1)' - X);
    [yfit, linCoeffs] = mldividefun(ydata, fitmodel, X);
    X = [X, linCoeffs'];

end

