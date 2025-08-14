function [Apl, Amin, probNucs] = calculateaplusaminus(A, AFrame, rVers, nEquivNucs)
    
    if nEquivNucs > 0
        [Ahfi1, Ahfi2] = calculatehfitwospins(A, AFrame, rVers);
        %% Hyperfine lines
        % Quantum numbers of each transition
        for ii = 1:length(nEquivNucs)
            quantNums{ii} = -nEquivNucs(ii)/2:1:nEquivNucs(ii)/2;
        end
        % Pascal factors
        for ii = 1:length(nEquivNucs)
            nLines = nEquivNucs(ii) + 1;
            pascalMatrix = pascal(nLines);
            % Antidiag
            pascs{ii} = pascalMatrix(nLines:nLines - 1:end - 1);
            pascs{ii} = pascs{ii}/sum(pascs{ii});
        end
        % Generate all the combinations
        [Apl, Amin, probNucs] = getquantnumcombinations(...
            Ahfi1, Ahfi2, quantNums, pascs);
    else
        [Apl, Amin] = deal(zeros(1, size(rVers, 2)));
        probNucs = 1;
    end
end

function [Apl, Amin, probs] = getquantnumcombinations(A1, A2, qNums, pascs)
    qStr = 'combinations(';
    pStr = 'combinations(';
    for ii = 1:length(qNums)
        qStr = [qStr, char(sprintf("qNums{%i}, ", ii))];
        pStr = [pStr, char(sprintf("pascs{%i}, ", ii))];
    end
    qStr = qStr(1:end - 2);
    qStr = [qStr, ')'];
    qCombs = table2array(eval(qStr));
    pStr = pStr(1:end - 2);
    pStr = [pStr, ')'];
    pascCombs = table2array(eval(pStr));

    % Multiply qCombs of dim (nHfiLines, length(nEquivNucs)) times A1 or A2
    % of dim (length(nEquivNucs), nSolidAngles), obtain arrays of dim
    % (nHfiLines, nSolidAngles)
    A1tot = qCombs*A1;
    A2tot = qCombs*A2;
    
    Apl = (A1tot + A2tot)/2;
    Amin = (A1tot - A2tot)/2;
    
    % Calculate probabilities based on the combinations
    probs = prod(pascCombs, 2);
end