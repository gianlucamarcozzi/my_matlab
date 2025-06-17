function [x0, y0, Param0] = loadfolderelexsys(folderPath, ext, complex)
arguments
    folderPath 
    ext         = "*.DTA"
    complex     = false
end

if ~endsWith(folderPath, '/')
    folderPath = append(folderPath, '/');
end
dirFolder = dir(append(folderPath, ext));
nMeas = numel(dirFolder);

if nMeas == 0
    error("The directory has no file with such extension.")
end

for ii = 1:nMeas
    filename = fullfile(dirFolder(ii).folder, dirFolder(ii).name);
    [x0Raw{ii}, y0Raw{ii}, Param0{ii}] = eprload(filename);
    if numel(x0Raw{ii}) == 2 & iscell(x0Raw{ii})
        x0{ii}.t = x0Raw{ii}{1};
        x0{ii}.b0 = transpose(x0Raw{ii}{2});
    else
        x0{ii} = x0Raw{ii};
    end

    if iscell(y0Raw{ii})
        % cwEPR case
        y0{ii} = y0Raw{ii}{1} + 1i*y0Raw{ii}{2};
    else
        if size(y0Raw{ii}, 2) ~= 1
            % pEPR map case: transpose y0. Final size: [ntime, nfield]
            y0{ii} = transpose(y0Raw{ii});
        else
            y0{ii} = y0Raw{ii};
        end
    end
end


end
