function outRange = setaxlim(x, ratio)
% Return a range that is perc times bigger than the range between the 
% maximum and the minimum of x. Useful to set limits for both axes of a
% plot.
%
% Input:
%   x           vector
%   Ratio       (outRange - ppAmp)/outRange, usually set at 0.2
%
% Output:
%   outRange    new range to give as input to xlim or ylim
arguments
    x
    ratio = 1
end

ppAmpHalf = (max(x) - min(x))/2;
mid = (max(x) + min(x))/2;

outRange(1) = mid - ppAmpHalf*ratio;
outRange(2) = mid + ppAmpHalf*ratio;

end