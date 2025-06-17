function xOut = correctxaxis(x, axCorr, isIndex)
arguments
    x
    axCorr
    isIndex = 0
end

if isIndex
    xOff = x(axCorr);
else
    xOff = axCorr;
end

for ii = 1:numel(x)
    xOut = x - xOff;
end