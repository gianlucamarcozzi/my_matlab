function [yOut, ParamOut] = averagescans(y, Param, finalTitle)

% Average the scans and store in yOut
yOut = zeros(size(y{1}));
nScan = numel(y);
for iScan = 1:nScan
    yOut = yOut + y{iScan}/nScan;
end

% Store average params in ParamOut
ParamOut = Param{1};
ParamOut.TITL = finalTitle;
ParamOut.FrequencyMon = '';
ParamOut.Power = '';
ParamOut.MWFQ = 0;
ParamOut.MWPW = 0;
for iScan = 1:nScan
    ParamOut.MWFQ = ParamOut.MWFQ + Param{iScan}.MWFQ/nScan;
    ParamOut.MWPW = ParamOut.MWPW + Param{iScan}.MWPW/nScan;
end

