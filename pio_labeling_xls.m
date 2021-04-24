close all, clear all
% participant's directory with the excelfile
directoryParticipant = '/Users/mac/Desktop/den_epg/';
cd(directoryParticipant);
% data's directory
directoryPio = [directoryParticipant 'p1/p1_converted_pio/list_a_pressure/'];
% acoustic's directory
directoryAudio = [directoryParticipant 'p1/p1_dat_wav/list_a/'];
 
% number of PIO files used for the outer while-loop
listPio = length(dir([directoryPio '/*.wav']));

% read the excelfile in the participant's directory
[timeStamps, table]=xlsread('epg_TextGrids_table.xls');

%remove first row in the table (column names)
table = table(2:end,:);

% index for both while-loops (opening files, finding triplets &
% corresponding time stamps, get segment names)
index = 1;

% cell number for writing table
writeCell = 1;

% filter specifications
[b,a]= butter(6,.01); %6th order butterworth  .04626143
Hd = dfilt.df2t(b,a);

% outer while-loop runs as long as there are files left in the PIO directory 
while listPio ~= 0
    
    %fprintf ('New file loaded. \n')
    
    % load PIO data
    [pio, freqPio] = wavread([directoryPio 'pio_' cell2mat(table(index, 1)) '.wav']);
    % load audio
    [audio, freqAudio] = wavread([directoryAudio cell2mat(table(index, 1)) '.wav']);
    
    % filter pressure data
    pioFilter=filtfilt(b,a, pio);
    
    % derive velocity and acceleration for filtered data
    velocityPio=diff(pioFilter);
    accelPio=diff(velocityPio);  
    
    % define current triplet
    tripletCurrent = table(index, 1);
    tripletNew = tripletCurrent;
    % compare the two triplets
    tripletSame = strcmp(tripletCurrent, tripletNew);
    
    % inner while-loop runs as long as triplets are left in the current
    % file
    while tripletSame == 1 
    
        %fprintf ('New triplet loaded. \n')
    
        % define the new triplet as current one
        tripletCurrent = tripletNew;
    
        % start & end points of the segments from excelfile
        onset=timeStamps(index,4);
        offset=timeStamps(index+2,5);

        % choose data range for the plots
        acoustics = audio(round(freqAudio*onset):round(freqAudio*offset));
        pioUnfiltered = pio(round(freqPio*onset):round(freqPio*offset));
        pioFiltered = pioFilter(round(freqPio*onset):round(freqPio*offset));
        pioVelocity = velocityPio(round(freqPio*onset):round(freqPio*offset));
        pioAcceleration = accelPio(round(freqPio*onset):round(freqPio*offset));
    
        %utt=locmat(i,1);
        %tok=locmat(i,2);
        %k=size(ema);
        %l=k(1,1)-1
        %timeaxis=[0:l]/1859;
   
        % plot the data
        subplot(4,1,1), plot(acoustics);
        hold on 
        %axis([round(freqAudio*onset) round(freqAudio*offset)])
        title(['File: ' cell2mat(table(index, 1)) ...
            ' Segment: ' cell2mat(table(index+1, 5)) ', Audio'])
                
        subplot(4,1,2), plot(pioUnfiltered);
        %axis([round(freqPio*onset) round(freqPio*offset) 0 1])
        title('PIO unfiltered')
        hold on;        
        subplot(4,1,2), plot(pioFiltered,'r');
        %axis([round(freqPio*onset) round(freqPio*offset) 0 1])
        title('PIO filtered')
        
        subplot(4,1,3), plot(pioVelocity);
        %axis([round(freqPio*onset) round(freqPio*offset) 0 1])
        title('PIO velocity')
        
        subplot(4,1,4), plot(pioAcceleration);
        %axis([round(freqPio*onset) round(freqPio*offset) 0 1])
        title('PIO acceleration')
            
        % play the acoustics of the plotted data
        sound(acoustics, freqAudio);
        
        % graphical input, n defines the number of points one wants to label
        % ENTER skips a trimplet without marks
        [marker] = ginput(4);
        
        % if there are markers, write them to an excel table in the
        % participant's directory together with the current file name and the
        % corresponding segment name
        if marker ~= 0
            % convert start point to a string with precision of 15 digits
            start = num2str(marker(1), 15); 
            % replace dot by comma
            start = strrep(start, '.', ',');
            
            fin = num2str(marker(2), 15);
            fin = strrep(fin, '.', ',');
            
            labels = {cell2mat(table(index, 1)) cell2mat(table(index+1, 5)) ...
                    start fin};
            xlswrite('pio_labels_table.xlsx', labels, ...
                sprintf('A%s:D%s', num2str(writeCell),num2str(writeCell)))
            
            % increase cell number for writing labels
            writeCell = writeCell + 1;
        else
        end
    
        % check the file name three cells (segments) further & define next triplet
        tripletNew = table(index+3,1);
        tripletSame = strcmp(tripletCurrent, tripletNew);
    
        % increase index by 3 (number of segments in one triplet)
        index=index+3;
                  
        % close all figures
        close all
    end % end of the inner while-loop
    
    % remove proccessed file from running list
    listPio = listPio-1;
    
end % end of the outer while-loop

fprintf('Processing finished. \n')