clc, close all, clear all

% directory with the excel table
dirTable = 'E:\ZAS';
cd(dirTable);

% data directory for every participant
dirPar1 = [dirTable '\p1\p1_converted_pio\list_a_pressure\'];
dirPar2 = [dirTable '\p2\p2_converted_pio\list_a_pressure\'];
dirPar3 = [dirTable '\p3\p3_converted_pio\list_a_pressure\'];
dirPar4 = [dirTable '\p4\p4_converted_pio\list_a\'];
dirPar5 = [dirTable '\p5\p5_converted_pio\list_a_press\'];
dirPar6 = [dirTable '\p6\p6_converted_pio\list_a\'];

% read the excel table
[values, labels]=xlsread('pio_table_final_2.xls');
labels = labels(2:end,:); %remove first row in the table (column names)
segNumber = length(values(:,1)); % number of iterations for the while-loop

rowInd = 1; % index for the table rows

file=labels(:,1);
speaker=labels(:,2);
target=labels(:,5);
conOnset=values(:,4);
conOffset=values(:,5);
calFactor=values(:,7); %%% column with calibration factor
calSens=values(:,8); %%% column with sensitivity

% filter specifications
[b,a]= butter(6,.01); %6th order butterworth  .04626143
Hd = dfilt.df2t(b,a);

% prelocate matrix for segments
p1_t = repmat({[]},2,10); p1_d = repmat({[]},2,10); p1_s = repmat({[]},2,10); p1_z = repmat({[]},2,10);
p1_S = repmat({[]},2,10); p1_Z = repmat({[]},2,10); p1_tS = repmat({[]},2,10); p1_dZ = repmat({[]},2,10); 

p2_t = repmat({[]},2,10); p2_d = repmat({[]},2,10); p2_s = repmat({[]},2,10); p2_z = repmat({[]},2,10);
p2_S = repmat({[]},2,10); p2_Z = repmat({[]},2,10); p2_tS = repmat({[]},2,10); p2_dZ = repmat({[]},2,10);

p3_t = repmat({[]},2,10); p3_d = repmat({[]},2,10); p3_s = repmat({[]},2,10); p3_z = repmat({[]},2,10);
p3_S = repmat({[]},2,10); p3_Z = repmat({[]},2,10); p3_tS = repmat({[]},2,10); p3_dZ = repmat({[]},2,10);

p4_t = repmat({[]},2,10); p4_d = repmat({[]},2,10); p4_s = repmat({[]},2,10); p4_z = repmat({[]},2,10);
p4_S = repmat({[]},2,10); p4_Z = repmat({[]},2,10); p4_tS = repmat({[]},2,10); p4_dZ = repmat({[]},2,10);

p5_t = repmat({[]},2,10); p5_d = repmat({[]},2,10); p5_s = repmat({[]},2,10); p5_z = repmat({[]},2,10);
p5_S = repmat({[]},2,10); p5_Z = repmat({[]},2,10); p5_tS = repmat({[]},2,10); p5_dZ = repmat({[]},2,10);

p6_t = repmat({[]},2,10); p6_d = repmat({[]},2,10); p6_s = repmat({[]},2,10); p6_z = repmat({[]},2,10);
p6_S = repmat({[]},2,10); p6_Z = repmat({[]},2,10); p6_tS = repmat({[]},2,10); p6_dZ = repmat({[]},2,10);

% loop until there are rows left in the excel table
while segNumber ~= 0
    
    % chose folder name based on the speaker
    switch speaker{rowInd}
        case 'p1'
            dirData = dirPar1;
        case 'p2'
            dirData = dirPar2;
        case 'p3'
            dirData = dirPar3;
        case 'p4'
            dirData = dirPar4;
        case 'p5'
            dirData = dirPar5;
        case 'p6'
            dirData = dirPar6;
    end
    
    % load PIO data
    [pio, freqPio] = wavread([dirData 'pio_' char(file(rowInd)) '.wav']);
    
    % calibration factor
    cal = 200/calFactor(rowInd);
    % sensitivity factor
    sen = calSens(rowInd);
    
    % multiply the PIO vector with the sensitivity and calibration factors
    pio = pio.*sen*cal; 
        
    % filter the PIO data
    pio = filtfilt(b,a, pio);
         
    % segment's onset and offset points
    onset = conOnset(rowInd);
    offset = conOffset(rowInd);
    
    % length of the segment
    len = length(pio(onset:offset));
    
    % length with additional 400 samples
    lenAdd = length(pio(onset-200:offset+200));
    
    % resampling factor
    resFactor = round(100*lenAdd/len);
    
    % choose data range for the segment
    segment = pio(onset-200:offset+200);
    
    % resample the segment to ~100 + additional samples
    segment = resample(segment, resFactor, length(segment));
    
    % compute the number of additional samples on each side
    redun = ceil((length(segment)-100)/2);
    
    % choose the ~100 at the center of the array
    segment = segment(redun+1:length(segment)-redun);
    
    % values missing until 100
    miss = 100-length(segment);
    
    % create array with nan's
    nan = NaN(miss, 1);
    
    % combine the segment with nan
    segment = [segment; nan];
    
    % normalize the y-dimension to zero
    segment = segment-segment(1,1);
    
    % file from which is the segment
    fileName = char(file(rowInd));
    
    % save the segment to a column of an array
    if speaker{rowInd} == 'p1'
        switch target{rowInd}
            case ' t'
                there = sum(~cellfun('isempty',p1_t(1,:)));
                p1_t{1,there+1} = segment;
                p1_t{2,there+1} = fileName;
            case ' d'
                there = sum(~cellfun('isempty',p1_d(1,:)));
                p1_d{1,there+1} = segment;
                p1_d{2,there+1} = fileName;
            case ' s'
                there = sum(~cellfun('isempty',p1_s(1,:)));
                p1_s{1,there+1} = segment;
                p1_s{2,there+1} = fileName;
            case ' z'
                there = sum(~cellfun('isempty',p1_z(1,:)));
                p1_z{1,there+1} = segment;
                p1_z{2,there+1} = fileName;
            case ' S'
                there = sum(~cellfun('isempty',p1_S(1,:)));
                p1_S{1,there+1} = segment;
                p1_S{2,there+1} = fileName;
            case ' Z'
                there = sum(~cellfun('isempty',p1_Z(1,:)));
                p1_Z{1,there+1} = segment;
                p1_Z{2,there+1} = fileName;
            case ' tS'
                there = sum(~cellfun('isempty',p1_tS(1,:)));
                p1_tS{1,there+1} = segment;
                p1_tS{2,there+1} = fileName;
            case ' dZ'
                there = sum(~cellfun('isempty',p1_dZ(1,:)));
                p1_dZ{1,there+1} = segment;
                p1_dZ{2,there+1} = fileName;
        end
        
    elseif speaker{rowInd} == 'p2'
        switch target{rowInd}
            case ' t'
                there = sum(~cellfun('isempty',p2_t(1,:)));
                p2_t{1,there+1} = segment;
                p2_t{2,there+1} = fileName;
            case ' d'
                there = sum(~cellfun('isempty',p2_d(1,:)));
                p2_d{1,there+1} = segment;
                p2_d{2,there+1} = fileName;
            case ' s'
                there = sum(~cellfun('isempty',p2_s(1,:)));
                p2_s{1,there+1} = segment;
                p2_s{2,there+1} = fileName;
            case ' z'
                there = sum(~cellfun('isempty',p2_z(1,:)));
                p2_z{1,there+1} = segment;
                p2_z{2,there+1} = fileName;
            case ' S'
                there = sum(~cellfun('isempty',p2_S(1,:)));
                p2_S{1,there+1} = segment;
                p2_S{2,there+1} = fileName;
            case ' Z'
                there = sum(~cellfun('isempty',p2_Z(1,:)));
                p2_Z{1,there+1} = segment;
                p2_Z{2,there+1} = fileName;
            case ' tS'
                there = sum(~cellfun('isempty',p2_tS(1,:)));
                p2_tS{1,there+1} = segment;
                p2_tS{2,there+1} = fileName;
            case ' dZ'
                there = sum(~cellfun('isempty',p2_dZ(1,:)));
                p2_dZ{1,there+1} = segment;
                p2_dZ{2,there+1} = fileName;
        end
    
    elseif speaker{rowInd} == 'p3'
        switch target{rowInd}
            case ' t'
                there = sum(~cellfun('isempty',p3_t(1,:)));
                p3_t{1,there+1} = segment;
                p3_t{2,there+1} = fileName;
            case ' d'
                there = sum(~cellfun('isempty',p3_d(1,:)));
                p3_d{1,there+1} = segment;
                p3_d{2,there+1} = fileName;
            case ' s'
                there = sum(~cellfun('isempty',p3_s(1,:)));
                p3_s{1,there+1} = segment;
                p3_s{2,there+1} = fileName;
            case ' z'
                there = sum(~cellfun('isempty',p3_z(1,:)));
                p3_z{1,there+1} = segment;
                p3_z{2,there+1} = fileName;
            case ' S'
                there = sum(~cellfun('isempty',p3_S(1,:)));
                p3_S{1,there+1} = segment;
                p3_S{2,there+1} = fileName;
            case ' Z'
                there = sum(~cellfun('isempty',p3_Z(1,:)));
                p3_Z{1,there+1} = segment;
                p3_Z{2,there+1} = fileName;
            case ' tS'
                there = sum(~cellfun('isempty',p3_tS(1,:)));
                p3_tS{1,there+1} = segment;
                p3_tS{2,there+1} = fileName;
            case ' dZ'
                there = sum(~cellfun('isempty',p3_dZ(1,:)));
                p3_dZ{1,there+1} = segment;
                p3_dZ{2,there+1} = fileName;
        end
        
    elseif speaker{rowInd} == 'p4'
        switch target{rowInd}
            case ' t'
                there = sum(~cellfun('isempty',p4_t(1,:)));
                p4_t{1,there+1} = segment;
                p4_t{2,there+1} = fileName;
            case ' d'
                there = sum(~cellfun('isempty',p4_d(1,:)));
                p4_d{1,there+1} = segment;
                p4_d{2,there+1} = fileName;
            case ' s'
                there = sum(~cellfun('isempty',p4_s(1,:)));
                p4_s{1,there+1} = segment;
                p4_s{2,there+1} = fileName;
            case ' z'
                there = sum(~cellfun('isempty',p4_z(1,:)));
                p4_z{1,there+1} = segment;
                p4_z{2,there+1} = fileName;
            case ' S'
                there = sum(~cellfun('isempty',p4_S(1,:)));
                p4_S{1,there+1} = segment;
                p4_S{2,there+1} = fileName;
            case ' Z'
                there = sum(~cellfun('isempty',p4_Z(1,:)));
                p4_Z{1,there+1} = segment;
                p4_Z{2,there+1} = fileName;
            case ' tS'
                there = sum(~cellfun('isempty',p4_tS(1,:)));
                p4_tS{1,there+1} = segment;
                p4_tS{2,there+1} = fileName;
            case ' dZ'
                there = sum(~cellfun('isempty',p4_dZ(1,:)));
                p4_dZ{1,there+1} = segment;
                p4_dZ{2,there+1} = fileName;
        end
        
    elseif speaker{rowInd} == 'p5'
        switch target{rowInd}
            case ' t'
                there = sum(~cellfun('isempty',p5_t(1,:)));
                p5_t{1,there+1} = segment;
                p5_t{2,there+1} = fileName;
            case ' d'
                there = sum(~cellfun('isempty',p5_d(1,:)));
                p5_d{1,there+1} = segment;
                p5_d{2,there+1} = fileName;
            case ' s'
                there = sum(~cellfun('isempty',p5_s(1,:)));
                p5_s{1,there+1} = segment;
                p5_s{2,there+1} = fileName;
            case ' z'
                there = sum(~cellfun('isempty',p5_z(1,:)));
                p5_z{1,there+1} = segment;
                p5_z{2,there+1} = fileName;
            case ' S'
                there = sum(~cellfun('isempty',p5_S(1,:)));
                p5_S{1,there+1} = segment;
                p5_S{2,there+1} = fileName;
            case ' Z'
                there = sum(~cellfun('isempty',p5_Z(1,:)));
                p5_Z{1,there+1} = segment;
                p5_Z{2,there+1} = fileName;
            case ' tS'
                there = sum(~cellfun('isempty',p5_tS(1,:)));
                p5_tS{1,there+1} = segment;
                p5_tS{2,there+1} = fileName;
            case ' dZ'
                there = sum(~cellfun('isempty',p5_dZ(1,:)));
                p5_dZ{1,there+1} = segment;
                p5_dZ{2,there+1} = fileName;
        end
        
    else
        switch target{rowInd}
            case ' t'
                there = sum(~cellfun('isempty',p6_t(1,:)));
                p6_t{1,there+1} = segment;
                p6_t{2,there+1} = fileName;
            case ' d'
                there = sum(~cellfun('isempty',p6_d(1,:)));
                p6_d{1,there+1} = segment;
                p6_d{2,there+1} = fileName;
            case ' s'
                there = sum(~cellfun('isempty',p6_s(1,:)));
                p6_s{1,there+1} = segment;
                p6_s{2,there+1} = fileName;
            case ' z'
                there = sum(~cellfun('isempty',p6_z(1,:)));
                p6_z{1,there+1} = segment;
                p6_z{2,there+1} = fileName;
            case ' S'
                there = sum(~cellfun('isempty',p6_S(1,:)));
                p6_S{1,there+1} = segment;
                p6_S{2,there+1} = fileName;
            case ' Z'
                there = sum(~cellfun('isempty',p6_Z(1,:)));
                p6_Z{1,there+1} = segment;
                p6_Z{2,there+1} = fileName;
            case ' tS'
                there = sum(~cellfun('isempty',p6_tS(1,:)));
                p6_tS{1,there+1} = segment;
                p6_tS{2,there+1} = fileName;
            case ' dZ'
                there = sum(~cellfun('isempty',p6_dZ(1,:)));
                p6_dZ{1,there+1} = segment;
                p6_dZ{2,there+1} = fileName;
        end
   end
    
    
   % reduce the number of segments by 1
   segNumber = segNumber - 1;
   % increase the row index by 1
   rowInd = rowInd + 1;
end

% fill all missing segment tokens with dummys (for the legend fuction in plots)

% participant 1
empty = cellfun(@isempty, p1_t(2,:));
p1_t(2,empty) = {'missing'};
empty = cellfun(@isempty, p1_d(2,:));
p1_d(2,empty) = {'missing'};
empty = cellfun(@isempty, p1_s(2,:));
p1_s(2,empty) = {'missing'};
empty = cellfun(@isempty, p1_z(2,:));
p1_z(2,empty) = {'missing'};
empty = cellfun(@isempty, p1_S(2,:));
p1_S(2,empty) = {'missing'};
empty = cellfun(@isempty, p1_Z(2,:));
p1_Z(2,empty) = {'missing'};
empty = cellfun(@isempty, p1_tS(2,:));
p1_tS(2,empty) = {'missing'};
empty = cellfun(@isempty, p1_dZ(2,:));
p1_dZ(2,empty) = {'missing'};

% participant 2
empty = cellfun(@isempty, p2_t(2,:));
p2_t(2,empty) = {'missing'};
empty = cellfun(@isempty, p2_d(2,:));
p2_d(2,empty) = {'missing'};
empty = cellfun(@isempty, p2_s(2,:));
p2_s(2,empty) = {'missing'};
empty = cellfun(@isempty, p2_z(2,:));
p2_z(2,empty) = {'missing'};
empty = cellfun(@isempty, p2_S(2,:));
p2_S(2,empty) = {'missing'};
empty = cellfun(@isempty, p2_Z(2,:));
p2_Z(2,empty) = {'missing'};
empty = cellfun(@isempty, p2_tS(2,:));
p2_tS(2,empty) = {'missing'};
empty = cellfun(@isempty, p2_dZ(2,:));
p2_dZ(2,empty) = {'missing'};

% participant 3
empty = cellfun(@isempty, p3_t(2,:));
p3_t(2,empty) = {'missing'};
empty = cellfun(@isempty, p3_d(2,:));
p3_d(2,empty) = {'missing'};
empty = cellfun(@isempty, p3_s(2,:));
p3_s(2,empty) = {'missing'};
empty = cellfun(@isempty, p3_z(2,:));
p3_z(2,empty) = {'missing'};
empty = cellfun(@isempty, p3_S(2,:));
p3_S(2,empty) = {'missing'};
empty = cellfun(@isempty, p3_Z(2,:));
p3_Z(2,empty) = {'missing'};
empty = cellfun(@isempty, p3_tS(2,:));
p3_tS(2,empty) = {'missing'};
empty = cellfun(@isempty, p3_dZ(2,:));
p3_dZ(2,empty) = {'missing'};

% participant 4
empty = cellfun(@isempty, p4_t(2,:));
p4_t(2,empty) = {'missing'};
empty = cellfun(@isempty, p4_d(2,:));
p4_d(2,empty) = {'missing'};
empty = cellfun(@isempty, p4_s(2,:));
p4_s(2,empty) = {'missing'};
empty = cellfun(@isempty, p4_z(2,:));
p4_z(2,empty) = {'missing'};
empty = cellfun(@isempty, p4_S(2,:));
p4_S(2,empty) = {'missing'};
empty = cellfun(@isempty, p4_Z(2,:));
p4_Z(2,empty) = {'missing'};
empty = cellfun(@isempty, p4_tS(2,:));
p4_tS(2,empty) = {'missing'};
empty = cellfun(@isempty, p4_dZ(2,:));
p4_dZ(2,empty) = {'missing'};

% participant 5
empty = cellfun(@isempty, p5_t(2,:));
p5_t(2,empty) = {'missing'};
empty = cellfun(@isempty, p5_d(2,:));
p5_d(2,empty) = {'missing'};
empty = cellfun(@isempty, p5_s(2,:));
p5_s(2,empty) = {'missing'};
empty = cellfun(@isempty, p5_z(2,:));
p5_z(2,empty) = {'missing'};
empty = cellfun(@isempty, p5_S(2,:));
p5_S(2,empty) = {'missing'};
empty = cellfun(@isempty, p5_Z(2,:));
p5_Z(2,empty) = {'missing'};
empty = cellfun(@isempty, p5_tS(2,:));
p5_tS(2,empty) = {'missing'};
empty = cellfun(@isempty, p5_dZ(2,:));
p5_dZ(2,empty) = {'missing'};

% participant 6
empty = cellfun(@isempty, p6_t(2,:));
p6_t(2,empty) = {'missing'};
empty = cellfun(@isempty, p6_d(2,:));
p6_d(2,empty) = {'missing'};
empty = cellfun(@isempty, p6_s(2,:));
p6_s(2,empty) = {'missing'};
empty = cellfun(@isempty, p6_z(2,:));
p6_z(2,empty) = {'missing'};
empty = cellfun(@isempty, p6_S(2,:));
p6_S(2,empty) = {'missing'};
empty = cellfun(@isempty, p6_Z(2,:));
p6_Z(2,empty) = {'missing'};
empty = cellfun(@isempty, p6_tS(2,:));
p6_tS(2,empty) = {'missing'};
empty = cellfun(@isempty, p6_dZ(2,:));
p6_dZ(2,empty) = {'missing'};

% ploting the segments
% ----------------------------------------------------------------
scrsz = get(0,'ScreenSize');

% participant 1
figure('Name', 'Participant 1: stops/affricates', 'NumberTitle','off', ...
    'Position',[5 (scrsz(4)/2)-300 scrsz(3)/2+400 scrsz(4)/2+200])
subplot(2,2,1), plot(cell2mat(p1_t(1,:)))
set(gca, 'ylim', [0 800])
legend(p1_t{2,:}, 'location', 'EastOutside')
title('t')
subplot(2,2,2), plot(cell2mat(p1_d(1,:)));
set(gca, 'ylim', [0 800])
legend(p1_d{2,:}, 'location', 'EastOutside')
title('d')
subplot(2,2,3), plot(cell2mat(p1_tS(1,:)));
set(gca, 'ylim', [0 800])
legend(p1_tS{2,:}, 'location', 'EastOutside')
title('tS')
subplot(2,2,4), plot(cell2mat(p1_dZ(1,:)))
set(gca, 'ylim', [0 800])
legend(p1_dZ{2,:}, 'location', 'EastOutside')
title('dZ')

figure('Name', 'Participant 1: fricatives', 'NumberTitle','off', ...
    'Position',[25 (scrsz(4)/2)-320 scrsz(3)/2+400 scrsz(4)/2+200])
subplot(2,2,1), plot(cell2mat(p1_s(1,:)))
set(gca, 'ylim', [0 800])
legend(p1_s{2,:}, 'location', 'EastOutside')
title('s')
subplot(2,2,2), plot(cell2mat(p1_z(1,:)))
set(gca, 'ylim', [0 800])
legend(p1_z{2,:}, 'location', 'EastOutside')
title('z')
subplot(2,2,3), plot(cell2mat(p1_S(1,:)))
set(gca, 'ylim', [0 800])
legend(p1_S{2,:}, 'location', 'EastOutside')
title('S')
subplot(2,2,4), plot(cell2mat(p1_Z(1,:)))
set(gca, 'ylim', [0 800])
legend(p1_Z{2,:}, 'location', 'EastOutside')
title('Z')

% participant 2
figure('Name', 'Participant 2: stops/affricates', 'NumberTitle','off', ...
    'Position',[55 (scrsz(4)/2)-340 scrsz(3)/2+400 scrsz(4)/2+200])
subplot(2,2,1), plot(cell2mat(p2_t(1,:)))
set(gca, 'ylim', [0 800])
legend(p2_t{2,:}, 'location', 'EastOutside')
title('t')
subplot(2,2,2), plot(cell2mat(p2_d(1,:)))
set(gca, 'ylim', [0 800])
legend(p2_d{2,:}, 'location', 'EastOutside')
title('d')
subplot(2,2,3), plot(cell2mat(p2_tS(1,:)))
set(gca, 'ylim', [0 800])
legend(p2_tS{2,:}, 'location', 'EastOutside')
title('tS')
subplot(2,2,4), plot(cell2mat(p2_dZ(1,:)))
set(gca, 'ylim', [0 800])
legend(p2_dZ{2,:}, 'location', 'EastOutside')
title('dZ')

figure('Name', 'Participant 2: fricatives', 'NumberTitle','off', ...
    'Position',[75 (scrsz(4)/2)-360 scrsz(3)/2+400 scrsz(4)/2+200])
subplot(2,2,1), plot(cell2mat(p2_s(1,:)))
set(gca, 'ylim', [0 800])
legend(p2_s{2,:}, 'location', 'EastOutside')
title('s')
subplot(2,2,2), plot(cell2mat(p2_z(1,:)))
set(gca, 'ylim', [0 800])
legend(p2_z{2,:}, 'location', 'EastOutside')
title('z')
subplot(2,2,3), plot(cell2mat(p2_S(1,:)))
set(gca, 'ylim', [0 800])
legend(p2_S{2,:}, 'location', 'EastOutside')
title('S')
subplot(2,2,4), plot(cell2mat(p2_Z(1,:)))
set(gca, 'ylim', [0 800])
legend(p2_Z{2,:}, 'location', 'EastOutside')
title('Z')

% participant 3
figure('Name', 'Participant 3: stops/affricates', 'NumberTitle','off', ...
    'Position',[95 (scrsz(4)/2)-380 scrsz(3)/2+400 scrsz(4)/2+200])
subplot(2,2,1), plot(cell2mat(p3_t(1,:)))
set(gca, 'ylim', [0 800])
legend(p3_t{2,:}, 'location', 'EastOutside')
title('t')
subplot(2,2,2), plot(cell2mat(p3_d(1,:)))
set(gca, 'ylim', [0 800])
legend(p3_d{2,:}, 'location', 'EastOutside')
title('d')
subplot(2,2,3), plot(cell2mat(p3_tS(1,:)))
set(gca, 'ylim', [0 800])
legend(p3_tS{2,:}, 'location', 'EastOutside')
title('tS')
subplot(2,2,4), plot(cell2mat(p3_dZ(1,:)))
set(gca, 'ylim', [0 800])
legend(p3_dZ{2,:}, 'location', 'EastOutside')
title('dZ')

figure('Name', 'Participant 3: fricatives', 'NumberTitle','off', ...
    'Position',[115 (scrsz(4)/2)-400 scrsz(3)/2+400 scrsz(4)/2+200])
subplot(2,2,1), plot(cell2mat(p3_s(1,:)))
set(gca, 'ylim', [0 800])
legend(p3_s{2,:}, 'location', 'EastOutside')
title('s')
subplot(2,2,2), plot(cell2mat(p3_z(1,:)))
set(gca, 'ylim', [0 800])
legend(p3_z{2,:}, 'location', 'EastOutside')
title('z')
subplot(2,2,3), plot(cell2mat(p3_S(1,:)))
set(gca, 'ylim', [0 800])
legend(p3_S{2,:}, 'location', 'EastOutside')
title('S')
subplot(2,2,4), plot(cell2mat(p3_Z(1,:)))
set(gca, 'ylim', [0 800])
legend(p3_Z{2,:}, 'location', 'EastOutside')
title('Z')

% participant 4
figure('Name', 'Participant 4: stops/affricates', 'NumberTitle','off', ...
    'Position',[135 (scrsz(4)/2)-420 scrsz(3)/2+400 scrsz(4)/2+200])
subplot(2,2,1), plot(cell2mat(p4_t(1,:)))
set(gca, 'ylim', [0 800])
legend(p4_t{2,:}, 'location', 'EastOutside')
title('t')
subplot(2,2,2), plot(cell2mat(p4_d(1,:)))
set(gca, 'ylim', [0 800])
legend(p4_d{2,:}, 'location', 'EastOutside')
title('d')
subplot(2,2,3), plot(cell2mat(p4_tS(1,:)))
set(gca, 'ylim', [0 800])
legend(p4_tS{2,:}, 'location', 'EastOutside')
title('tS')
subplot(2,2,4), plot(cell2mat(p4_dZ(1,:)))
set(gca, 'ylim', [0 800])
legend(p4_dZ{2,:}, 'location', 'EastOutside')
title('dZ')

figure('Name', 'Participant 4: fricatives', 'NumberTitle','off', ...
    'Position',[155 (scrsz(4)/2)-440 scrsz(3)/2+400 scrsz(4)/2+200])
subplot(2,2,1), plot(cell2mat(p4_s(1,:)))
set(gca, 'ylim', [0 800])
legend(p4_s{2,:}, 'location', 'EastOutside')
title('s')
subplot(2,2,2), plot(cell2mat(p4_z(1,:)))
set(gca, 'ylim', [0 800])
legend(p4_z{2,:}, 'location', 'EastOutside')
title('z')
subplot(2,2,3), plot(cell2mat(p4_S(1,:)))
set(gca, 'ylim', [0 800])
legend(p4_S{2,:}, 'location', 'EastOutside')
title('S')
subplot(2,2,4), plot(cell2mat(p4_Z(1,:)))
set(gca, 'ylim', [0 800])
legend(p4_Z{2,:}, 'location', 'EastOutside')
title('Z')

% participant 5
figure('Name', 'Participant 5: stops/affricates', 'NumberTitle','off', ...
    'Position',[175 (scrsz(4)/2)-480 scrsz(3)/2+400 scrsz(4)/2+200])
subplot(2,2,1), plot(cell2mat(p5_t(1,:)))
set(gca, 'ylim', [0 800])
legend(p5_t{2,:}, 'location', 'EastOutside')
title('t')
subplot(2,2,2), plot(cell2mat(p5_d(1,:)))
set(gca, 'ylim', [0 800])
legend(p5_d{2,:}, 'location', 'EastOutside')
title('d')
subplot(2,2,3), plot(cell2mat(p5_tS(1,:)))
set(gca, 'ylim', [0 800])
legend(p5_tS{2,:}, 'location', 'EastOutside')
title('tS')
subplot(2,2,4), plot(cell2mat(p5_dZ(1,:)))
set(gca, 'ylim', [0 800])
legend(p5_dZ{2,:}, 'location', 'EastOutside')
title('dZ')

figure('Name', 'Participant 5: fricatives', 'NumberTitle','off', ...
    'Position',[195 (scrsz(4)/2)-500 scrsz(3)/2+400 scrsz(4)/2+200])
subplot(2,2,1), plot(cell2mat(p5_s(1,:)))
set(gca, 'ylim', [0 800])
legend(p5_s{2,:}, 'location', 'EastOutside')
title('s')
subplot(2,2,2), plot(cell2mat(p5_z(1,:)))
set(gca, 'ylim', [0 800])
legend(p5_z{2,:}, 'location', 'EastOutside')
title('z')
subplot(2,2,3), plot(cell2mat(p5_S(1,:)))
set(gca, 'ylim', [0 800])
legend(p5_S{2,:}, 'location', 'EastOutside')
title('S')
subplot(2,2,4), plot(cell2mat(p5_Z(1,:)))
set(gca, 'ylim', [0 800])
legend(p5_Z{2,:}, 'location', 'EastOutside')
title('Z')

% participant 6
figure('Name', 'Participant 6: stops/affricates', 'NumberTitle','off', ...
    'Position',[215 (scrsz(4)/2)-520 scrsz(3)/2+400 scrsz(4)/2+200])
subplot(2,2,1), plot(cell2mat(p6_t(1,:)))
set(gca, 'ylim', [0 800])
legend(p6_t{2,:}, 'location', 'EastOutside')
title('t')
subplot(2,2,2), plot(cell2mat(p6_d(1,:)))
set(gca, 'ylim', [0 800])
legend(p6_d{2,:}, 'location', 'EastOutside')
title('d')
subplot(2,2,3), plot(cell2mat(p6_tS(1,:)))
set(gca, 'ylim', [0 800])
legend(p6_tS{2,:}, 'location', 'EastOutside')
title('tS')
subplot(2,2,4), plot(cell2mat(p6_dZ(1,:)))
set(gca, 'ylim', [0 800])
legend(p6_dZ{2,:}, 'location', 'EastOutside')
title('dZ')

figure('Name', 'Participant 6: fricatives', 'NumberTitle','off', ...
    'Position',[235 (scrsz(4)/2)-540 scrsz(3)/2+400 scrsz(4)/2+200])
subplot(2,2,1), plot(cell2mat(p6_s(1,:)))
set(gca, 'ylim', [0 800])
legend(p6_s{2,:}, 'location', 'EastOutside')
title('s')
subplot(2,2,2), plot(cell2mat(p6_z(1,:)))
set(gca, 'ylim', [0 800])
legend(p6_z{2,:}, 'location', 'EastOutside')
title('z')
subplot(2,2,3), plot(cell2mat(p6_S(1,:)))
set(gca, 'ylim', [0 800])
legend(p6_S{2,:}, 'location', 'EastOutside')
title('S')
subplot(2,2,4), plot(cell2mat(p6_Z(1,:)))
set(gca, 'ylim', [0 800])
legend(p6_Z{2,:}, 'location', 'EastOutside')
title('Z')