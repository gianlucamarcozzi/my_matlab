function y1 = gaussianresonancebsweep(wReson, mwFreq, c, mode)
    arguments
        wReson
        mwFreq  
        c      % LWPP SQUARED!!   
        mode string = "lwpp"
    end    
    
    % Validate the mode input
    if ~ismember(mode, ["lwpp"])
        error('Invalid mode. Choose "lwpp".');
    end

    % Calculate the Gaussian resonance based on the provided parameters
    % c is the square of the lwpp, following Zech's convention
    normTerm = sqrt(2/pi./c);
    y1 = normTerm.*exp(-2 * (wReson - mwFreq).^2 ./ c);

end
