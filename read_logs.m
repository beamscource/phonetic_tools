
clear all; clc

main = 'E:\ZAS\Log-Files\';
cd(main)

% get struct array with file names
fileList = dir([main '*.log']);

for index = 1: length(fileList)
    
    fprintf('Processing %s\n', fileList(index).name);
    
    % get fileID via opening the txt-file
    fileID = fopen(fileList(index).name);
    
    % use textscan to get a cell array;
    % HeaderLines defines how many lines to skip
    C = textscan(fileID,'%s %s %*s %d %*[^\n]', 'HeaderLines', 659);
    fclose(fileID);
    
    % write the extracted contents to a xls-file
    header = {'Event Type' 'Code' 'Time'};
    xlswrite([fileList(index).name '.xls'], header, 'Tabelle1')
    xlswrite([fileList(index).name '.xls'], C{1}, 'Tabelle1','A2');
    xlswrite([fileList(index).name '.xls'], C{2}, 'Tabelle1','B2');
    xlswrite([fileList(index).name '.xls'], C{3}, 'Tabelle1','C2');
    
end

fprintf('Finished. \n')