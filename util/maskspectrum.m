function [idxArray, x, y] = maskspectrum(x, y, range)
% maskspectrum      Return values of the spectrum that are in range.
%
% [idx, x, y] = maskspectrum(x, y, range)
% Input:
%   x           vector of length N
%   y           spectrum, vector of length N
%   range       segments of the spectrum to return as output (expressed
%               in the units of x),
%               double (Mx2): [x11 x12; x21 x22; ...]
%
% Output:
%   idx         array of masked indeces, logical of length N
%   x           masked x
%   y           masked y

[nRanges, ~] = size(range);
idxArray = zeros(size(x));
for iRange = 1:nRanges
    idxArray_ = (x >= range(iRange, 1)) & (x <= range(iRange, 2));
    idxArray = idxArray + idxArray_;
end
idxArray = logical(idxArray);

x = x(idxArray);
y = y(idxArray);

end