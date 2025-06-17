function [yFit, SysBest] = simulatecomponentsfit(Fit)
% Simulate components of the fit
    nSys = numel(Fit.argsfit{1, 1});
    
    pnamesString = string(Fit.pnames);
    SysBest = Fit.argsfit{1, 1};
    for isys = 1:nSys
        % Filter the parameters from system isys
        containsSys = contains(pnamesString, ...
            strcat('arg1{', string(isys), '}'));
        pnamesStringContains = pnamesString(containsSys);
        pfitContains = Fit.pfit(containsSys);

        SysBest_ = SysBest{isys};
        for jj = 1:numel(pnamesStringContains)
            % Split and select only name of the parameter itself
            pnameSplit_ = strsplit(pnamesStringContains(jj), '.');
            pname_ = char(pnameSplit_(end));
            if contains(pname_, '(')
                pnameSplit = strsplit(pname_, '(');
                pnameBase = pnameSplit{1};
                pnameSplit{2} = pnameSplit{2}(1:end - 1);  % Remove ')'
                pnameIdx = str2double(strsplit(pnameSplit{2}, ','));
                SysBest_.(pnameBase)(pnameIdx(1), pnameIdx(2)) = ...
                    pfitContains(jj);
            else
                SysBest_.(pname_) = pfitContains(jj);
            end
        end
        SysBest{isys} = SysBest_;
    end
    Exp = Fit.argsfit{1, 2};
    Opt.separate = 'components';
        
    yFit = Fit.scale*pepper(SysBest, Exp, Opt);
    weight = zeros(nSys, 1);
    isFieldHarmonic = isfield(Exp, 'Harmonic');
    for isys = 1:nSys
        if ~isFieldHarmonic  % Derivative spectrum.
            integrSpectrum = cumtrapz(cumtrapz(yFit(isys, :)));
        else
            integrSpectrum = yFit(isys, :);  % Initialization
            for ii = Exp.Harmonic:-1:0
                % Integrate once for every harmonic
                integrSpectrum = cumtrapz(integrSpectrum);
            end
        end
        weight(isys) = integrSpectrum(end);
    end
    for isys = 1:nSys
        SysBest{isys}.weightDI = weight(isys)/sum(weight);
    end
end

%{
%% Fit
clearvars; close all
% Path to the project folder
chdir('D:\Profile\qse\files\projects\sijia_sulphurization');
% Add source file directory
addpath(genpath('scr'));

for jj = 49
    pathFile = strcat("data/processed/gm-e1-000", string(jj), ".mat");
    load(pathFile);
    
    % Fit 2 spin systems
    Sys0 = struct('g', 2.0034, ...
        'lwpp', [1 0.2]);
    Sys1 = struct('g', 2.0052, ...
        'lwpp', [1 0.5], ...
        'weight', 1.2);
    Sys2 = struct('g', 2.008, ...
        'lwpp', [0.6 0.6], ...
        'weight', 0.7);
    
    
    Vary0 = struct('g', .005, ...
        'lwpp', Sys0.lwpp);
    Vary1 = struct('g', .005, ...
        'lwpp', Sys1.lwpp, ...
        'weight', 1);
    Vary2 = struct('g', .005, ...
        'lwpp', Sys2.lwpp, ...
        'weight', 1);
    
    % Define x and y
    Exp.Range = [min(data.x) max(data.x)];
    Exp.mwFreq = data.Params.MWFQ*1e-9;
    Exp.nPoints = numel(data.x);
    Exp.Harmonic = 0;

    % Disregard low field peak g ~ 2.0065
    % FitOpt.mask = (1:numel(x) < 195) | (1:numel(x) > 378);
    FitOpt.BaseLine = [];
    
    Sys = {Sys0, Sys1, Sys2};
    SysVary = {Vary0, Vary1, Vary2};
    % Sys = {Sys0, Sys1};
    % SysVary = {Vary0, Vary1};
    % Sys = {Sys0};
    % SysVary = {Vary0};
    
    % Fit = esfit(yy, @pepper, {{Sys1, Sys2, Sys3}, Exp}, {{Vary1, Vary2, Vary3}}, FitOpt)
    % data.Fit = esfit(data.y, @pepper, {Sys, Exp}, {SysVary}, FitOpt);
    
    % saveintomat(pathFile, data, true)     % Immediately save the fit
    
    % Simulate separate components and save again afterwards
    % load(pathFile)
    load(pathFile)
    Fit = data.Fit;
    
    if numel(Sys) == 1
        figure()
        plot(data.x, data.y)
        hold on
        plot(data.x, Fit.fit)
    elseif numel(Sys) == 2
        Sys0b.g = Fit.pfit(1);
        Sys0b.lwpp(1) = Fit.pfit(2);
        Sys0b.lwpp(2) = Fit.pfit(3);
        Sys1b.g = Fit.pfit(4);
        Sys1b.lwpp(1) = Fit.pfit(5);
        Sys1b.lwpp(2) = Fit.pfit(6);
        Sys1b.weight = Fit.pfit(7);
        
        Exp = Fit.argsfit{1, 2};
        Opt.Output = 'separate';
        
        yFit = Fit.scale*pepper({Sys0b, Sys1b}, Exp, Opt);
        data.Fit.yFit0 = yFit(1, :);
        data.Fit.yFit1 = yFit(2, :);
        
        % saveintomat(pathFile, data, true)    % Save again
        
        %
        figure()
        plot(data.x, data.y)
        hold on
        plot(data.x, Fit.fit)
        % plot(data.x, data.Fit.yFit0 + data.Fit.yFit1)
        plot(data.x, data.Fit.yFit0)
        plot(data.x, data.Fit.yFit1)

    else
        Sys0b.g = Fit.pfit(1);
        Sys0b.lwpp(1) = Fit.pfit(2);
        Sys0b.lwpp(2) = Fit.pfit(3);
        Sys1b.g = Fit.pfit(4);
        Sys1b.lwpp(1) = Fit.pfit(5);
        Sys1b.lwpp(2) = Fit.pfit(6);
        Sys1b.weight = Fit.pfit(7);        
        Sys2b.g = Fit.pfit(8);
        Sys2b.lwpp(1) = Fit.pfit(9);
        Sys2b.lwpp(2) = Fit.pfit(10);
        Sys2b.weight = Fit.pfit(11);
        
        Exp = Fit.argsfit{1, 2};
        Opt.Output = 'separate';
        
        yFit = Fit.scale*pepper({Sys0b, Sys1b, Sys2b}, Exp, Opt);
        data.Fit.yFit0 = yFit(1, :);
        data.Fit.yFit1 = yFit(2, :);
        data.Fit.yFit2 = yFit(3, :);
    
        % saveintomat(pathFile, data, true)    % Save again
        
        %
        figure()
        plot(data.x, data.y)
        hold on
        plot(data.x, Fit.fit)
        % plot(data.x, data.Fit.yFit0 + data.Fit.yFit1 + data.Fit.yFit2)
        plot(data.x, data.Fit.yFit0)
        plot(data.x, data.Fit.yFit1)
        plot(data.x, data.Fit.yFit2)
    end
    % fprintf('%f +- %e\n', data.Fit.pfit(1), data.Fit.pstd(1))
end
%}