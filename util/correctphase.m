function [yout, phase] = correctphase(y, mode, initialPhase)
% correctphase      Phase correction for signals in orthogonal channels.
%
% [y, phase] = correctphase(y)
% [y, phase] = correctphase(y, mode)
%
% Input:
%   y       spectrum, complex vector of length N
%   mode    criterium for phase correction, string or char vector.
%           Minimize the the peak to peak amplituted of (Maximum) or the 
%           area under the (Integral) imaginary part of the spectrum,
%           maximum (default) or integral
%
% Output:
%   y       spectrum phase corrected (real part)
%   phase   corresponding phase

arguments
    y
    mode {mustBeText} = 'maximum';
    initialPhase = 0;
end

% Define model
shiftphase = @(y, p) y*exp(1i*p*pi/180);

% Normalize
y = y/max(abs(y));
if lower(string(mode)) == "pulse"
    phase = -angle(trapz(y))*180/pi;
    yout = shiftphase(y, phase);
    residAngle = -angle(trapz(yout))*180/pi;
    while abs(residAngle) > 0.1
        phase = phase + residAngle
        yout = shiftphase(y, phase);
        residAngle = -angle(trapz(yout))*180/pi;
    end
    return
end

% Fit model
model = shiftphase(y, p);

switch lower(string(mode))
    case "maximum"
        objective = @(p) imag(max(model(p) - min(model(p))));
    case "cwintegral"
        objective = @(p) imag(trapz(model(p)));    
    otherwise
        error("correctphase: unrecognized mode. The possible values " + ...
            "are 'maximum', 'cwIntegral', 'pIntegral'.")
end

p0 = initialPhase;
lb = -90;
ub = 90;
options = optimoptions('lsqnonlin', 'Display', 'off');

% Run fit.
phase = lsqnonlin(@(p) objective(p), p0, lb, ub, options);
yout = model(phase);

% Make the signal such that the maximum is on the left of the minimum
% [~, minyNo] = min(real(y));
% [~, maxyNo] = max(real(y));
% if minyNo < maxyNo
%     phase = phase + 180;
%     y = model(phase);
% end

end