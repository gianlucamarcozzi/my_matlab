function [] = matlab2latextablefit( ...
                    filePath, Fit, printFieldArray, printFieldArrayAs)
    format long
    pstd = Fit.pstd;
    pnames = Fit.pnames;
    SysBest = Fit.SysBest;
    nSys = numel(SysBest);

    % Initialize SysBestPstd
    SysBestPstd = SysBest;
    for isys = 1:nSys
        try
            SysBestPstd{isys} = rmfield(SysBestPstd{isys}, "weightDI");
        catch
        end
    end

    % Write pstd in SysBestPstd
    for isys = 1:nSys
        for ip = 1:numel(pnames)
            splitPnames = strsplit(pnames{ip}, ["{", "}", "."]);
            sysNo = str2double(splitPnames{2});
            fieldName = splitPnames{3};
            if ~contains(fieldName, 'lwpp')
                SysBestPstd{sysNo}.(fieldName) = pstd(ip);
            else
                fieldNameSplit = strsplit(fieldName, ["(", ",", ")"]);
                fieldName = fieldNameSplit{1};
                lwppNo = str2double(fieldNameSplit{end - 1});
                SysBestPstd{sysNo}.(fieldName)(lwppNo) = pstd(ip);
            end
        end
    end
    
    % Create pfitPrint. It is a matrix where each row is a different 
    % field, the i-th odd column contains the pfit values of the i-th spin
    % system, the i-th even column contains the pstd values of the i-th
    % spin system.
    nPrintFields = numel(printFieldArray);
    % The (nPrintFields - 1) is due to weightDI having no uncertainty.
    pfitPrint = zeros(nPrintFields, 2*nSys);
    for isys = 1:nSys
        iColPrint = 2*isys - 1;
        LwppNo = 1;
        sysFieldArray_ = fieldnames(SysBest{isys});
        for iField = 1:numel(printFieldArray)
            fieldName = printFieldArray(iField);
            containsPfit = strcmp(sysFieldArray_, fieldName);
            
            if sum(containsPfit) == 0
                pfitPrint(iField, iColPrint) = 0; % pfit
                pfitPrint(iField, iColPrint + 1) = 0; % pstd
            elseif sum(containsPfit) == 1
                fieldName = sysFieldArray_(containsPfit);
                isLwpp = strcmp(fieldName, 'lwpp');
                isWeightDI = strcmp(fieldName, 'weightDI');
                if ~isLwpp && ~isWeightDI
                    pfitPrint(iField, iColPrint) = ...
                        SysBest{isys}.(fieldName{:});
                    pfitPrint(iField, iColPrint + 1) = ...
                        SysBestPstd{isys}.(fieldName{:});
                elseif isLwpp
                    lwppBest = SysBest{isys}.(fieldName{:});
                    lwppPstd = SysBestPstd{isys}.(fieldName{:});
                    pfitPrint(iField, iColPrint) = lwppBest(LwppNo);
                    pfitPrint(iField, iColPrint + 1) = lwppPstd(LwppNo);
                    LwppNo = LwppNo + 1;
                elseif isWeightDI
                    pfitPrint(iField, iColPrint) = ...
                        SysBest{isys}.(fieldName{:});
                    pfitPrint(iField, iColPrint + 1) = 0;
                end
            else
                error("There are two fields which have the same name")
            end
        end
    end
    
    if nSys == 3
        writetolatextable3sys(filePath, pfitPrint, printFieldArrayAs)
    elseif nSys == 2
        writetolatextable2sys(filePath, pfitPrint, printFieldArrayAs)
    elseif nSys == 1
        writetolatextable1sys(filePath, pfitPrint, printFieldArrayAs)
    else
        error("Not still implemented for this number of spin systems")
    end
end
    
function [] = writetolatextable3sys(filePath, pfitPrint, printFieldArrayAs)
    fileID = fopen(filePath, 'w');
    fprintf(fileID, '\t & %12s & %12s & %12s \\\\ \n\n', ...
        'Sys a', 'Sys b', 'Sys c');
    for iField = 1:numel(pfitPrint(:, 1))
        printFieldAs = printFieldArrayAs(iField);
            fprintf(fileID, ...
                '%9s & %.5f(%.5f) & %.5f(%.5f) & %.5f(%.5f) \\\\ \n', ...
                printFieldAs, pfitPrint(iField, :));
    end
    fclose(fileID);
end

function [] = writetolatextable2sys(filePath, pfitPrint, printFieldArrayAs)
    fileID = fopen(filePath, 'w');
    fprintf(fileID, '\t & %12s & %12s \\\\ \n\n', ...
        'Sys1', 'Sys2');
    for iField = 1:numel(pfitPrint(:, 1))
        printFieldAs = printFieldArrayAs(iField);
            fprintf(fileID, ...
                '%9s & %.5f(%.5f) & %.5f(%.5f) \\\\ \n', ...
                printFieldAs, pfitPrint(iField, :));
    end
    fclose(fileID);
end
function [] = writetolatextable1sys(filePath, pfitPrint, printFieldArrayAs)
    fileID = fopen(filePath, 'w');
    fprintf(fileID, '\t & %12s \\\\ \n\n', ...
        'Sys');
    for iField = 1:numel(pfitPrint(:, 1))
        printFieldAs = printFieldArrayAs(iField);
            fprintf(fileID, ...
                '%9s & %.5f(%.5f) \\\\ \n', ...
                printFieldAs, pfitPrint(iField, :));
    end
    fclose(fileID);
end