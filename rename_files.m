% rename files
% February 2015

%% clean the workspace
clear all; clc; close all;

%% get the directories and the log file list
dirMain = 'E:\ZAS\Description_planning_German\audio\';

folderList = dir(dirMain);
folderList = folderList(3:end); 
folders = length(folderList);
indx = 1;

while folders ~=0
    
% Get all files in the current folder
files = dir([dirMain folderList(indx).name '\*.wav']);

% Loop through each file
for i = 1:length(files)
    % Get the file name (minus the extension) + Convert to number
    %nice function fileparts
    name = str2double(strtok(files(i).name, '.'));

      if ~isnan(name)
          % If numeric, rename
          movefile([dirMain folderList(indx).name '\' files(i).name], [dirMain folderList(indx).name '\' sprintf('%02d.wav', name)]);
      end

end

% remove procced folder from list
folders = folders - 1;
indx = indx + 1;
end