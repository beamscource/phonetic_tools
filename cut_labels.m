% get raw text responses from log-files
% February 2015

%% get the directories and the log file list
dirMain = 'E:\ZAS\Description_planning\log_files\';

txtList = dir([dirMain '*.xls']);

files = length(txtList);

fileNr = 1;

while files ~= 0
    
    [num,txt] = xlsread([dirMain txtList(fileNr).name]);
    
    sentences = txt(:,16);
    
    fileID = fopen([dirMain strtok(txtList(fileNr).name, '.') '.txt'], 'wt');
    fprintf(fileID, '%s\n', sentences{2:end,:});
    fclose(fileID);
    
    fprintf('Finished file %d from %d. \n', fileNr, length(txtList));
    
    
    % remove procced file from list
    files = files - 1;
    fileNr = fileNr + 1;
end