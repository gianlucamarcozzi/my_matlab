function x = correctcalibrationxaxis(xRaw, Opt)
% correctcalibrationxaxis
% Field calibration and conversion from gauss to mT.
%
% x = correctcalibrationxaxis(xRaw, Opt)
%
% Input:
%   xRaw    vector of length N
%   Opt
%       .xOff       x-axis offset value (in GHz or mT)
%       .gauss2mt   boolean indicating if the conversion from gauss to mT 
%                   will be performed or not
%
% Output:
%   x       corrected x-axis

arguments
    xRaw
    Opt struct = struct('xOff', 0,  'gauss2mt', false)
end

if Opt.gauss2mt
    xRaw = xRaw/10;
end

x = xRaw + Opt.xOff; % mT


