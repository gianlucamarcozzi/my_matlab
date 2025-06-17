function data = eprloadstructure(filePath)
% eprloadstructure    loadepr on filepath or directory and initialize a
% structure to save the data.
%
% data = eprloadstructure(filePath)
% Input:
%   filePath        text scalar to the location of the file or structure
%                   output of the function dir(filename)
%
% Output:
%   data
%       .title      text scalar, filename of filePath
%       .x          empty future corrected x-axis array
%       .y          empty future corrected y-axis array
%       .Params     structure for parameters from the spectrometer
%       .Metadata   structure for metadata (sample, spectrometer, ...)
%       .DataPrep   structure to store any important values used and
%                   obtained during data preparation

    if ~isstruct(filePath)
        [fileFolder, fileName, fileExtension] = fileparts(filePath);
        fileDir(1).folder = fileFolder;
        fileDir(1).name = strcat(fileName, fileExtension);
    else % filePath is already the directory structure.
        fileDir = filePath;
    end
    if isempty(fileDir)
        error("The file could not be found. Check filePath " + ...
            "parameter, check file extension or check file " + ...
            "permission.")
    end

    nDatas = numel(fileDir);
    data = repmat( ...
        struct('filename', {}, 'x', {}, 'y', {}, 'Params', {}, ...
               'Metadata', struct([]), 'DataPrep', struct([])), ...
               nDatas, 1); % Initialize.

    for ii = 1:nDatas
        filePath_ = fullfile(fileDir(ii).folder, fileDir(ii).name);
        [data(ii).DataPrep.xRaw, y_, ...
            data(ii).Params] = eprload(filePath_);
        
        % Assume there are no points in the name except to distinguish the
        % actual filename from the extension.
        filename = strsplit(fileDir(ii).name, '.');
        if numel(filename) ~= 2
            data(ii).filename = char(fileDir(ii).name);
            warning("Could not create a proper data.title because " + ...
                "the format of the filename did not allow it " + ...
                "(the filename does not have an extension or has " + ...
                "a point in the middle of the filename).")
        else 
            data(ii).filename = char(filename(1));
        end
        
        if iscell(y_) % cwEPR with 0 and 90 degree modulation phase.
            data(ii).DataPrep.yRaw = y_{1, 1} + 1i*y_{1, 2};
        else
            data(ii).DataPrep.yRaw = y_;
        end
    end
end



