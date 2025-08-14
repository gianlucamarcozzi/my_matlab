function [yfin, ymid, b] = subtractbaseline2d(x, y, Opt, dimFirstCorr)
% subtractbaseline      Baseline correction with a polynomial function.
%
% [y, b, p] = subtractBaseline(x, y, Opt, order)
% Input:
%   x               vector of length N
%   y               spectrum, vector of length N
%   Opt             options
%       .order  int, order of the polynomial baseline
%       .width  fraction of spectrum at the edges considered as baseline.
%               This attribute is considered only when the attribute
%               Opt.range doesn't exist,
%               double 0 < Width < 1
%       .range  segments of the spectrum considered as baseline (expressed
%               in the units of x),
%               double (Mx2): [x11 x12; x21 x22; ...]
%   dimFirstCorr    dimension that is corrected first     
%
% Output:
%   y       spectrum baseline corrected
%   b       baseline
%   p       coefficients of the polynomial function, double (1, Opt.Order)
arguments
    x
    y
    Opt     cell = {struct(), struct()}
    dimFirstCorr   (1, 1) double = 1
end

%% Default parameters

DEFAULT_POLY_ORDER = 0;
DEFAULT_WIDTH = 0.1;

%% Check parameters

% Check if Opt is empty
if isempty(fieldnames(Opt{1}))
    Param.polyOrder = DEFAULT_POLY_ORDER;
    Param.width = DEFAULT_WIDTH;
    Opt = {Param, Param};
end

% Check dimFirstCorr
if dimFirstCorr == 1
    corr1 = 1;
    corr2 = 2;
elseif dimFirstCorr == 2
    corr1 = 2;
    corr2 = 1;
else
    error('dimFirstCorr should be either 1 or 2.')
end

%%
if corr1 == 1
    [ymid, yfin, b{1}, b{2}] = deal(y);
    % Correction along first dimension
    nSlice = size(y, corr2);
    for iSlice = 1:nSlice
        [ymid(:, iSlice), b{1}(:, iSlice)] = subtractbaseline(...
            x{corr1}, y(:, iSlice), Opt{corr1});
    end
    % Correction along second dimension
    nSlice = size(y, corr1);
    for iSlice = 1:nSlice
        [yfin(iSlice, :), b{2}(iSlice, :)] = subtractbaseline(...
            x{corr2}, ymid(iSlice, :), Opt{corr2});
    end
elseif corr1 == 2
    [ymid, yfin, b{1}, b{2}] = deal(y);
    % Correction along second dimension
    nSlice = size(y, corr1);
    for iSlice = 1:nSlice
        [ymid, b{1}] = subtractbaseline(...
            x{corr2}, y(iSlice, :), Opt{corr2});
    end
    % Correction along first dimension
    nSlice = size(y, corr2);
    for iSlice = 1:nSlice
        [yfin, b{2}] = subtractbaseline(...
            x{corr1}, ymid(:, iSlice), Opt{corr1});
    end
end

