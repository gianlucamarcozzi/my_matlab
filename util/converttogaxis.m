function xOut = converttogaxis(xIn, fixedParam, conversionIdentifier)
% converttogaxis    Converts mT or GHz axis to g-value axis.
%
% xOut = converttogaxis(xIn, fixedParam, conversionIdentifier)
% 
% Input:
%   xIn             vector of length N, either magnetic field in mT or
%                   microwave frequency in GHz
%   fixedParam      double, either mw freq in GHz or mag field in mT. This
%                   is the paramater that is fixed in the experiment.
%   conversionIdentifier    either "mT->g" (default), hence fixedParam
%                           will be interpreted as the mw freq, or 
%                           "GHz->g", hence fixedParam will be the magnetic
%                           field
%
% Output:
%   xOut            x-axis in g-value

arguments
    xIn
    fixedParam
    conversionIdentifier {mustBeText} = "mT->g"
end

switch lower(string(conversionIdentifier))
    case "mt->g"
        xOut = planck*(fixedParam*1e9)/bmagn./(xIn*1e-3);
    case "ghz->g"
        xOut = planck.*(xIn*1e9)/bmagn/(fixedParam*1e-3);
    otherwise
        error('converttogaxis: conversionIdentifier not recognized.')
end


