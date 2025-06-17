function [snr, ppAmp, noiseLev] = getSNR(x, y, noiseRange, mode)
% getsnr    Calculate signal to noise ratio, defined as the ratio between
% peak to peak intensity of the signal over the standard deviation of the 
% noise distribution. The peak to peak amplitude of the signal is 
% calculated over all the spectrum, while the standard deviation of the 
% noise is calculated only in the noiseRange region.
%
% [snr, ppAmp, noiseLev] = getSNR(x, y, noiseRange)
% [snr, ppAmp, noiseLev] = getSNR(x, y, noiseRange, Mode)
% Input:
%   x           vector of length N
%   y           spectrum, vector of length N
%   noiseRange  segments of the spectrum considered as noise (expressed
%               in the units of x),
%               double (Mx2): [x11 x12; x21 x22; ...]
%   mode        determines how the NoiseLev is calculated, Stdev (default)
%               or PeaktoPeak
%
% Output:
%   snr         signal to noise ratio, float
%   ppAmp       amplitude peak to peak of the signal, float
%   noiseLev    noise level, depends on selected Mode
%               standard deviation (Stdev mode) or peak to peak 
%               amplitude (PeakToPeak mode) of the noise distribution

arguments
    x
    y
    noiseRange
    mode = "stdev"
end
ppAmp = max(y) - min(y);
[~, ~, noiseY] = maskspectrum(x, y, noiseRange);
switch lower(string(mode))
    case "stdev"
        noiseLev = std(noiseY);
    case "peaktopeak"
        noiseLev = max(noiseY) - min(noiseY);
    otherwise
        error("getsnr: mode parameter has incorrect value. Possible " + ...
            "values are only 'stdev' and 'peaktopeak")
end
snr = ppAmp/noiseLev;

end