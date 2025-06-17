function [yfit, X, dX] = lsqnonlin2steps2(ydata, fitmodelIn, p0, offset, fitOpt)
    arguments
        ydata
        fitmodelIn
        p0
        offset {logical} = true
        fitOpt = optimoptions('lsqnonlin','Display','off');
    end
    
    %% Check input
    isRow = @(y) size(y, 1) == 1 && size(y, 2) > 1;
    isCol = @(y) size(y, 2) == 1 && size(y, 1) > 1;
    % Transpose ydata into a column vector, if necessary
    if isRow(ydata)
        ydata = transpose(ydata);
    elseif isCol(ydata)
        %
    else
        error("ydata should be a vector (no scalar, no matrix).")
    end
    
    % Transpose the output of fitmodel to a column vector, if necessary
    y0 = fitmodelIn(p0);
    if isRow(y0)
        fitmodelIn = @(p) transpose(fitmodelIn);
    elseif isCol(y0)
        %
    else
        error("The outpur of fitmodel should be a vector" + ...
            "(no scalar, no matrix).")
    end
    
    %% Add linear part to the model, if requested
    if offset
        fitmodel = @(p) [fitmodelIn(p), ones(length(y0), 1)];
    else
        fitmodel = fitmodelIn;
    end

    %% FIT
    % Fit separately non-linear and linear part
    [X, ~, residual, ~, ~, ~, jacobian] = ...
        lsqnonlin(@(p) ydata - mldividefun(ydata, fitmodel, p), ...
        p0, [], [], fitOpt);
    % Uncertainties for the non-linear parameters (95% CI)
    pci = nlparci(X, residual, 'jacobian', jacobian);
    dX = abs(pci(:, 1)' - X);
    % Best fit curve and linear coefficients
    [yfit, linCoeffs] = mldividefun(ydata, fitmodel, X);
    % Include linear coefficients in the parameter vector
    X = [X, linCoeffs'];

end
