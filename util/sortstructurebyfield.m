function varargout = sortstructurebyfield(struc, fie)
    T = struct2table(struc); % convert the struct array to a table
    [sortedT, index] = sortrows(T, fie); % sort the table by 'DOB'
    sortedStruc = table2struct(sortedT);
    if nargout == 1
        varargout{1} = sortedStruc;
    elseif nargout == 2
        varargout{1} = sortedStruc;
        varargout{2} = index;
    else
        error('sortstructurebyfield: wrong number of outputs.')
    end
end