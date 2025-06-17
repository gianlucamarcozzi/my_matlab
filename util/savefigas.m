function [] = savefigas(fig, path, overwrite)
% savefigas      Save fig without automatic overwriting.
%
% savefigas(fig, path, overwrite)
%
% Input:
%   fig         figure or axis to save
%   path        path where to save the data
%   overwrite   boolean, if true and there is a file with the same name
%               in the folder, it overwrites the file in the path (default
%               false)

arguments
    fig
    path
    overwrite = false
end

[fileFolder, fileName, fileExtension] = fileparts(path);
if isempty(fileExtension)
    fileExt = {'.svg', '.png', '.pdf'};
else
    fileExt = {fileExtension};
end

for ii = 1:numel(fileExt)
    pathSave = fullfile(fileFolder, strcat(fileName, fileExt{ii}));

    if ~overwrite
        while isfile(pathSave)
            dirFolder = dir(fileFolder);
            [~, fileName, ~] = fileparts(pathSave);
            pathSave = fullfile(fileFolder, strcat(fileName, '_new', fileExt{ii}));
            warning(strcat("The file was saved with another name because " + ...
                "a file with the same name already exists in the folder:" + ...
                newline, dirFolder(1).folder))
        end
    end

    if strcmp(fileExt{ii}, '.pdf')
        exportgraphics(gcf, pathSave)
    else
        saveas(fig, pathSave);
    end
end