function output = sortcellbyparameter(param, inputCells)
%SORTCELLBYPARAMETER
    [~, index] = sort(param);
    output = inputCells;
    for ic = 1:numel(inputCells)
        output{ic} = inputCells{ic}(index);
    end
end

