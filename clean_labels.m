clear all; clc

%% get the directories and the labels file list
dirMain = 'E:\ZAS\Description_planning\labels\';

txtList = dir([dirMain '*.txt']);

files = length(txtList);

fileNr = 1;

while files ~= 0
    
    fileID = fopen([dirMain strtok(txtList(fileNr).name, '.') '.txt']);
    raw = textscan(fileID, '%s', 'delimiter', '\n');
    fclose(fileID);
    raw = raw{1,1}; % get inside the cell with senteces
    
    % loop through each sentence
    for s = 1:length(raw)
        str = raw{s,:};
        
        % get rid of brackets
        opens = str == '[';
        closes = str == ']';
        nestingcount = cumsum(opens - [0 closes(1:end-1)]);
        str = str(nestingcount == 0);
        
        % get rid of parantheses
        opens = str == '(';
        closes = str == ')';
        nestingcount = cumsum(opens - [0 closes(1:end-1)]);
        str = str(nestingcount == 0);
        
        % get rid of dots
        dot = str == '.';
        str = str(dot == 0);
        
        % get rid of commas
        comma = str == ',';
        str = str(comma == 0);
        
        % get rid of hyphens
        hyp = str == '-';
        str = str(hyp == 0);
        
        raw{s,:} = str;
        
    end
    
    
    fileID = fopen([dirMain strtok(txtList(fileNr).name, '.') '.txt'], 'wt');
    fprintf(fileID, '%s\n', raw{:});
    fclose(fileID);
    
    fprintf('Finished file %d from %d. \n', fileNr, length(txtList));
    
    % remove procced file from list
    files = files - 1;
    fileNr = fileNr + 1;
    
end