% annotate_pio

%% clean workspace
close all, clear all

%% get directories
mainDir = 'E:\ZAS\MotionCap\';
cd(mainDir)
content = dir(mainDir);
directories = find(vertcat(content.isdir));
partDir = content(directories);

[b,a]= butter(6,.01); %6th order butterworth  .04626143
Hd = dfilt.df2t(b,a);

% set folder index
orderIndex = 3;

%% loop through each order
while partDir ~= 0

    % get list of liles contained in the folder
    fileList = dir([mainDir partDir(orderIndex).name '\*.wav']);
    % set index for thorax files
    thoIndex = 3;
        
    % loop through every thorax file
    while fileList ~= 0
        
        % define file name
        fileTho = [mainDir partDir(orderIndex).name '\' fileList(thoIndex).name];
        % read the file
        thorax = wavread(fileTho);
        % get file length
        fileLength = length(thorax');
        
        % create a vector with 3 poits between 1 and the end of the wav-file
        numChunk = 3;
        chunkLimits = round(linspace(1, fileLength, numChunk));
        
        % for-loop for reading 2 chunks
        for i = 1:numChunk - 1
            
            [maxpoints, onsets] = peakdet(thorax(chunkLimits(1):chunkLimits(1+1)-1)', 0.01);
            
            %plot figure
            figure('Name', ['Participant: ' partDir(orderIndex).name ', File: ' ...
                fileList(thoIndex).name], 'units', 'normalized', 'outerposition', ...
                [0 0 1 1], 'NumberTitle', 'off');
            plot(thorax(chunkLimits(1):chunkLimits(1+1)-1)')
            axis tight;
            hold on;
            for i = 1:length(onsets)
                o = impoint(gca, onsets(i,1), onsets(i,2));
                setColor(o,'g');
                
            end
            for i = 1:length(maxpoints)
                m = impoint(gca, maxpoints(i,1), maxpoints(i,2));
                setColor(m,'r');
                
            end
            
%             plot(onsets(:,1), onsets(:,2), 'g*');
%             plot(maxpoints(:,1), maxpoints(:,2), 'r*');
%             
        end
        
        % write output to file
        header = {'onsets' 'onsets_value'};
        labels = {onsets};
        xlswrite([mainDir partDir(orderIndex).name '\' strtok(fileList(thoIndex).name, '.') '.xlsx'], header)
        xlswrite([dirData strtok(fileList(thoIndex).name, '.') '.xlsx'], labels, ...
             sprintf('A2:B%s', num2str(length(onsets))))
             

    fileList = fileList - 3;
    thoIndex = thoIndex + 3;
    end
    
    orderIndex = orderIndex + 1;
    
end

    % get list of liles contained in the folder
    fileList = dir([mainDir partDir(orderIndex).name '\*.wav']);
    % set index for abdomen files
    abdIndex = 2;
    
    % loop through every abdomen file
    while fileList ~= 0
        
        % define file name
        fileAbd = [mainDir partDir(orderIndex).name '\' fileList(thoIndex).name];
        % read the file
        tho = wavread(fileAbd);
        
        fileList = fileList - 3;
        abdIndex = abdIndex + 3;
  
    end
    
    
    
    
end


