function [Sys, Exp] = importparammytrepr(pathToParam)

if ~isfile(pathToParam)
    error("File not found.")
end

M = readlines(pathToParam);

sysPar = ["A", "AFrame", "J", "Nucs", "S", "dip", "eeFrame", "g", ...
    "gFrame", "gStrain", "initState", "lw1", "lw2", "lwpp", ...
    "nEquivNucs", "pciss", "cwlwpp", "trlwpp1", "trlwpp2"];
expPar = ["x", "mwFreq", "CenterSweep", "Range", "nPoints", "Harmonic", ...
    "nThetas", "nPhis", "gridType"];

Sys = struct();
Exp = struct();
M = deletecomments(M);
M = attachlineswithdots(M);

for ii = 1:numel(M)
    % Get parName
    temp = strsplit(M(ii), '=');
    if isscalar(temp)  % no '=' in this line
        continue    
    end
    parName = strrep(temp(1), ' ', '');
    % Compare with expected parameters
    [sysFlag, iSys] = ismember(parName, sysPar);
    [expFlag, iExp] = ismember(parName, expPar);
    if sysFlag
        par = sysPar(iSys);
    elseif expFlag
        par = expPar(iExp);
    else
        error("Parameter %s not found in the list " + ...
            "of expected parameters. Add it to list or " + ...
            "modify parameter name.\n", parName{:})
    end
    
    if sysFlag
        Sys = addpar(Sys, M(ii), par);
    else
        Exp = addpar(Exp, M(ii), par);
    end

end
Sys = checkelectronspin(Sys);
Sys = checknuclearspins(Sys);
Exp = getxfromrange(Exp);

end

function Sys = addpar(Sys, m, par)
    % par should be a string vector
    temp = strsplit(m{1}, '=');
    m(1) = temp(end);
    for ii = 1:numel(m)
        temp2 = strsplit(m{ii}, '%');
        tt{ii} = temp2(1);
    end

    tfin = "";
    for ii = 1:numel(m)
        tt(ii) = strrep(tt{ii}, '...', '');
        tfin = append(tfin, tt{ii});
    end
    Sys.(par) = eval(tfin);
end

function M = attachlineswithdots(M)
    for ii = numel(M):-1:1
        if contains(M{ii}, '...')
            if ii == numel(M)
                error("The last line of the parameter file contains " + ...
                    "'...'. Import failed.")
            end
            % Remove dots
            temp = strsplit(M{ii}, '...');
            part1 = temp(1);
            % Append the rows
            M(ii) = append(part1, M(ii + 1));
            % Clean the row that was appended
            M(ii + 1) = "";
        end
    end
end

function Sys = checkelectronspin(Sys)
    if ~isfield(Sys, "S")
        return
    else
        for ii = 1:length(Sys.S)
            if mod(2*Sys.S(ii), 1)
                error("Sys.S should be k/2 with k integer.")
            end
        end
    end
end

function Sys = checknuclearspins(Sys)
    % Presence of parameters in the param file
    if ~isfield(Sys, "Nucs")
        if ~isfield(Sys, "A")
            Sys.nEquivNucs = 0;
            return
        else
            error("Tensor A is defined but Nucs are not.")
        end
    end
    if ~isfield(Sys, "Nucs") && isfield(Sys, "AFrame")
            error("Matrix AFrame is defined but Nucs and A are not.")
    end
    if isfield(Sys, "Nucs")
        if ~isfield(Sys, "A")
            error("Tensor A must be defined for Nucs.")
        elseif isfield(Sys, "AFrame")
            Sys.AFrame = zeros(1, 3*length(Sys.S));
        end
    end

    % Sizes
    nucStr = strsplit(Sys.Nucs, ',');
    for inuc = 1:length(nucStr)
        % Check Nucs
        nuc = strrep(nucStr(inuc), " ", "");
        if ~ismember(nuc, ["H", "1H"])
            error("Only 'H' or '1H' implemented as nuclei for now. " + ...
                "Example: Nucs = '1H, 1H, 1H'.")
        end
    end
    % Check number of nEquivNucs entries
    if isfield(Sys, "nEquivNucs")
        if length(Sys.nEquivNucs) ~= length(nucStr) 
            error("The length of nEquivNucs does not match the " + ...
                "number of nuclei given in Nucs.")
        end
    end
    % Check rows of A
    if size(Sys.A, 1) ~= length(nucStr)
        error(append("The size of A (", ...
            strjoin(string(size(Sys.A, 1))), ...
            ") does not match the number of nuclei (", ...
            string(length(nucStr)), ") defined in Nucs."));
    end
    % Check cols of A
    if ~isfield(Sys, "S")
        expectedCols = 3;
    else
        expectedCols = 3*length(Sys.S);
    end
    if size(Sys.A, 2) ~= expectedCols
        error(append("The size of A (", ...
            strjoin(string(size(Sys.A, 1))), ...
            ") does not match the number of electrons (", ...
            string(expectedCols/3), ") defined in Sys.S."));
    end
    % Check AFrame
    if ~isequal(size(Sys.AFrame), [1, expectedCols])
        error("More than one AFrame still not implemented.")
    end
end

function M = deletecomments(M)
    for ii = 1:numel(M)
        temp = strsplit(M(ii), "%");
        M(ii) = temp(1);
    end
end

function Exp = getxfromrange(Exp)
    if isfield(Exp, 'Range')
        Exp.x = linspace(Exp.Range(1), Exp.Range(2), Exp.nPoints);
    elseif isfield(Exp, 'CenterSweep')
        Exp.x = linspace(Exp.CenterSweep(1) - Exp.CenterSweep(2)/2, ...
                         Exp.CenterSweep(1) + Exp.CenterSweep(2)/2, ...
                         Exp.nPoints);
    else
        error("Specify either Range or CenterSweep in the parameters.")
    end

    if isfield(Exp, 'Range') && isfield(Exp, 'CenterSweep')
        warning("Both Range and CenterSweep were specified in the " + ...
            "parameters. Range was used to calculate x.")
    end
end