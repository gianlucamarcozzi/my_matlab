function [y, b, p] = subtractbaseline(x, y, varargin)
% subtractbaseline      Baseline correction with a polynomial function.
%
% [y, b, p] = subtractBaseline(x, y, Opt)
% Input:
%   x       vector of length N
%   y       spectrum, vector of length N
%   Opt     options
%       .order  int, order of the polynomial baseline
%       .width  fraction of spectrum at the edges considered as baseline.
%               This attribute is considered only when the attribute
%               Opt.range doesn't exist,
%               double 0 < Width < 1
%       .range  segments of the spectrum considered as baseline (expressed
%               in the units of x),
%               double (Mx2): [x11 x12; x21 x22; ...]
%
% Output:
%   y       spectrum baseline corrected
%   b       baseline
%   p       coefficients of the polynomial function, double (1, Opt.Order)

Opt = parseoptions(varargin{:});

if isreal(y)
    % Define the baseline region
    try
        width = (max(x) - min(x))*Opt.width;
        idxArray = (x <= min(x) + width) | (x >= max(x) - width);
    catch
        idxArray = maskspectrum(x, y, Opt.range);
    end

    % Polynomial fit
    [p, ~, mu] = polyfit(x(idxArray), y(idxArray), Opt.polyOrder);
    % Baseline calculation
    b = polyval(p, x, [], mu);
    % Baseline subtraction
    y = y - b;
else
    % Separate real and imaginary part and call function separately.
    yr = real(y);
    yi = imag(y);
    [yr, br] = subtractbaseline(x, yr, Opt);
    [yi, bi] = subtractbaseline(x, yi, Opt);
    y = yr + yi*1i;
    b = br + bi*1i;
end

end

%% Option parsing
function Opt = parseoptions(varargin)

% Initialize input parser object.
parser = inputParser;
parser.StructExpand = true;
parser.KeepUnmatched = true;

% Define parameters.
addParameter(parser, 'polyOrder', 0);

fieldnameArray = fieldnames(varargin{:});
containsOrder = contains('order', lower(fieldnameArray));
if containsOrder
    error("Opt structure contains field 'order'. Change it to 'polyOrder'")
end

containsRange = contains('range', lower(fieldnameArray));
if containsRange
    addParameter(parser, 'range', []);
else
    addParameter(parser, 'width', 0.15, @(x) x > 0);
end

% Parse input.
parse(parser, varargin{:});
Opt = parser.Results;

end


