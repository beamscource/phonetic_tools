% annotate_breathing
% script to find and annotate peaks in thorax/abdomen signals

%% clean workspace
close all, clear all, clc

%% get directories
mainDir = 'E:\ZAS\MotionCap\';
cd(mainDir)
content = dir(mainDir);
directories = find(vertcat(content.isdir));
partDir = content(directories);
d = length(partDir)-2;

% % filter specifications
[b,a]= butter(6,.01); %6th order butterworth  .04626143
Hd = dfilt.df2t(b,a);

% set folder index
orderIndex = 3;

%% loop through each order
while  d ~= 0
    
    fprintf('Compute data for participant %s. \n', partDir(orderIndex).name);
    
    % get list of liles contained in the folder
    fileList = dir([mainDir partDir(orderIndex).name '\*.wav']);
    f = length(fileList);
    
    % set index for thorax files
    thoIndex = 3;
    % set index for abdomen files
    abdIndex = 2;
    
    %% loop through every corresponding thorax/abdomen files
    while f ~= 0
        
                        
        % define file name for the thorax file
        fileTho = [mainDir partDir(orderIndex).name '\' fileList(thoIndex).name];
        fprintf('Compute file %s. \n', fileTho);
        % read the file
        [thorax, freq] = wavread(fileTho);
        
        % define n-th sample to keep in the downsampled signal
        keepSample = 100;
        thorax = downsample(thorax,keepSample);
        
        % filter the signal
        thorFilt = filtfilt(b,a,thorax);
                
        % get file length for the TextGrid
        fileLen = length(thorFilt);
        
        % compute velocity
        velThorax = diff(thorFilt);
        % amplify the velocity signal
        %velThorax =  velThorax*10^4;
        % get range of the velocity scale
        range = (max(velThorax(velThorax>0)) - min(velThorax(velThorax>0))) / 3;
         
        % threshold for peak detection
        thres = range*0.1/1; % 25% veränderbar
        % get peaks in the thorax signal
        [maxth, onth] = peakdet(velThorax, thres);
        
        % get onsets and maxpoints into one sorted vector
        vecTh = sortrows([maxth' onth']', 1);
        
        % define seq of extrema for the textGrid 
        if vecTh(1,2) < vecTh(2,2)
            seqTh = 1;
        else
            seqTh = 0;
        end
        
        vecTh = vecTh(:,1);
                       
        %fprintf('Got peaks for %s. \n', fileTho);
        
        %plot figure to check thorax
        figure('Name', ['Participant: ' partDir(orderIndex).name ', File: ' ...
            fileList(thoIndex).name], 'units', 'normalized', 'outerposition', ...
            [0 0 1 1], 'NumberTitle', 'off');
        
        plot(thorFilt)
        axis tight;
        hold on;
        plot(velThorax*10^1, 'm')
        hold on;
        plot(onth(:,1), onth(:,2), 'g*');
        %plot(maxth(:,1), maxth(:,2), 'r*');
        pause
        close all
        
        % define file name for the abdomen file
        fileAbd = [mainDir partDir(orderIndex).name '\' fileList(abdIndex).name];
        fprintf('Compute file %s. \n', fileAbd);
        % read the file
        abdomen = wavread(fileAbd);
        
        % downsample the signal
        abdomen = downsample(abdomen,keepSample);
        
        % filter the signal
        abFilt = filtfilt(b,a,abdomen);
        
        % compute velocity
        velAbdomen = diff(abFilt);
        % amplify the velocity signal
        %velAbdomen =  velAbdomen*10^4;
        % get range of the velocity scale
        range = (max(velAbdomen(velAbdomen>0)) - min(velAbdomen(velAbdomen>0))) / 3;
        
        % threshold for peak detection
        thres = range*0.1/1;
        % get peaks in the abdomen signal
        [maxab, onab] = peakdet(velAbdomen, thres);
        
        % get onsets and maxpoints into one sorted vector
        vecAb = sortrows([maxab' onab']', 1);
        
        % define seq of extrema for the textGrid        
        if vecAb(1,2) < vecAb(2,2)
            seqAb = 1;
        else
            seqAb = 0;
        end
        
        vecAb = vecAb(:,1);
               
        %fprintf('Got peaks for %s. \n', fileAbd);
        
        %plot figure to check abdomen
        figure('Name', ['Participant: ' partDir(orderIndex).name ', File: ' ...
            fileList(abdIndex).name], 'units', 'normalized', 'outerposition', ...
            [0 0 1 1], 'NumberTitle', 'off');
        plot(abFilt)
        axis tight;
        hold on;
        plot(velAbdomen*10^1, 'm')
        hold on;
        plot(onab(:,1), onab(:,2), 'g*');
        %plot(maxab(:,1), maxab(:,2), 'r*');
        pause
        close all
        
        %% witing output to a TextGrid file
        
        core =(regexp(fileList(abdIndex).name, '_', 'split'));
        fileName = sprintf('%s_',core{:,1});
        fileName = sprintf('%s', [fileName core{:,2}]);
        
        fprintf('Writing Praat text grid for breath_%s. \n', fileName);
        
        % create a textgrid-file
        fid = fopen([mainDir partDir(orderIndex).name '\breath_' fileName '.TextGrid'],'a');
        
        % write header
        fprintf(fid,'File type = \"ooTextFile\"\n');
        fprintf(fid,'Object class = \"TextGrid\"\n\n');
        fprintf(fid,'xmin = %.1f\n', 0.0);
        fprintf(fid,'xmax = %.12f\n', fileLen/(freq/keepSample));
        fprintf(fid,'tiers? <exists>\n');
        fprintf(fid,'size = 2\n');
        fprintf(fid,'item []:\n');
        
        fprintf(fid,'  item [1]:\n');
        fprintf(fid,'       class = \"IntervalTier\"\n');
        fprintf(fid,'       name = \"thorax\"\n');
        fprintf(fid,'       xmin = %.1f\n', 0.0);
        fprintf(fid,'       xmax = %.12f\n', fileLen/(freq/keepSample));
        fprintf(fid,'       intervals: size = %d\n', length(vecTh)+1);
        
        if seqTh == 1
            for t=1:length(vecTh)
                if t == 1
                    fprintf(fid, '       intervals[%d] :\n', t); % interval indices start at 1
                    fprintf(fid, '           xmin = %.3f\n', 0.0);
                    fprintf(fid, '           xmax = %.3f\n', vecTh(t)/(freq/keepSample));
                    fprintf(fid, '           text = \"\"\n');
                    
                    fprintf(fid, '       intervals[%d] :\n', t+1); % interval indices start at 1
                    fprintf(fid, '           xmin = %.3f\n', vecTh(t)/(freq/keepSample));
                    fprintf(fid, '           xmax = %.3f\n', vecTh(t+1)/(freq/keepSample));
                    fprintf(fid, '           text = \"\"\n');
                elseif t ~= length(vecTh) && mod(t,2)
                    fprintf(fid, '       intervals[%d] :\n', t); % interval indices start at 1
                    fprintf(fid, '           xmin = %.3f\n', vecTh(t)/(freq/keepSample));
                    fprintf(fid, '           xmax = %.3f\n', vecTh(t+1)/(freq/keepSample));
                    fprintf(fid, '           text = \"I\"\n');
                elseif t ~= length(vecTh) && ~mod(t,2)
                    fprintf(fid, '       intervals[%d] :\n', t); % interval indices start at 1
                    fprintf(fid, '           xmin = %.3f\n', vecTh(t)/(freq/keepSample));
                    fprintf(fid, '           xmax = %.3f\n', vecTh(t+1)/(freq/keepSample));
                    fprintf(fid, '           text = \"\"\n');
                else
                    fprintf(fid, '       intervals[%d] :\n', t); % interval indices start at 1
                    fprintf(fid, '           xmin = %.3f\n', vecTh(t)/(freq/keepSample));
                    fprintf(fid, '           xmax = %.3f\n', fileLen/(freq/keepSample));
                    fprintf(fid, '           text = \"\"\n');
                end
            end
        else
            for t=1:length(vecTh)
                if t == 1
                    fprintf(fid, '       intervals[%d] :\n', t); % interval indices start at 1
                    fprintf(fid, '           xmin = %.3f\n', 0.0);
                    fprintf(fid, '           xmax = %.3f\n', vecTh(t)/(freq/keepSample));
                    fprintf(fid, '           text = \"\"\n');
                    
                    fprintf(fid, '       intervals[%d] :\n', t+1); % interval indices start at 1
                    fprintf(fid, '           xmin = %.3f\n', vecTh(t)/(freq/keepSample));
                    fprintf(fid, '           xmax = %.3f\n', vecTh(t+1)/(freq/keepSample));
                    fprintf(fid, '           text = \"\"\n');
                elseif t ~= length(vecTh) && mod(t,2)
                    fprintf(fid, '       intervals[%d] :\n', t); % interval indices start at 1
                    fprintf(fid, '           xmin = %.3f\n', vecTh(t)/(freq/keepSample));
                    fprintf(fid, '           xmax = %.3f\n', vecTh(t+1)/(freq/keepSample));
                    fprintf(fid, '           text = \"\"\n');
                elseif t ~= length(vecTh) && ~mod(t,2)
                    fprintf(fid, '       intervals[%d] :\n', t); % interval indices start at 1
                    fprintf(fid, '           xmin = %.3f\n', vecTh(t)/(freq/keepSample));
                    fprintf(fid, '           xmax = %.3f\n', vecTh(t+1)/(freq/keepSample));
                    fprintf(fid, '           text = \"I\"\n');
                else
                    fprintf(fid, '       intervals[%d] :\n', t); % interval indices start at 1
                    fprintf(fid, '           xmin = %.3f\n', vecTh(t)/(freq/keepSample));
                    fprintf(fid, '           xmax = %.3f\n', fileLen/(freq/keepSample));
                    fprintf(fid, '           text = \"\"\n');
                end
            end
        end
                    
        fprintf(fid,'  item [2]:\n');
        fprintf(fid,'       class = \"IntervalTier\"\n');
        fprintf(fid,'       name = \"abdomen\"\n');
        fprintf(fid,'       xmin = %.1f\n', 0.0);
        fprintf(fid,'       xmax = %.12f\n', fileLen/(freq/keepSample));
        fprintf(fid,'       intervals: size = %d\n', length(vecAb)+1);
        
        if seqAb == 1
            for t=1:length(vecAb)
                if t == 1
                    fprintf(fid, '       intervals[%d] :\n', t); % interval indices start at 1
                    fprintf(fid, '           xmin = %.3f\n', 0.0);
                    fprintf(fid, '           xmax = %.3f\n', vecAb(t)/(freq/keepSample));
                    fprintf(fid, '           text = \"\"\n');
                    
                    fprintf(fid, '       intervals[%d] :\n', t+1); % interval indices start at 1
                    fprintf(fid, '           xmin = %.3f\n', vecAb(t)/(freq/keepSample));
                    fprintf(fid, '           xmax = %.3f\n', vecAb(t+1)/(freq/keepSample));
                    fprintf(fid, '           text = \"\"\n');
                elseif t ~= length(vecAb) && mod(t,2)
                    fprintf(fid, '       intervals[%d] :\n', t); % interval indices start at 1
                    fprintf(fid, '           xmin = %.3f\n', vecAb(t)/(freq/keepSample));
                    fprintf(fid, '           xmax = %.3f\n', vecAb(t+1)/(freq/keepSample));
                    fprintf(fid, '           text = \"I\"\n');
                elseif t ~= length(vecAb) && ~mod(t,2)
                    fprintf(fid, '       intervals[%d] :\n', t); % interval indices start at 1
                    fprintf(fid, '           xmin = %.3f\n', vecAb(t)/(freq/keepSample));
                    fprintf(fid, '           xmax = %.3f\n', vecAb(t+1)/(freq/keepSample));
                    fprintf(fid, '           text = \"\"\n');
                else
                    fprintf(fid, '       intervals[%d] :\n', t); % interval indices start at 1
                    fprintf(fid, '           xmin = %.3f\n', vecAb(t)/(freq/keepSample));
                    fprintf(fid, '           xmax = %.3f\n', fileLen/(freq/keepSample));
                    fprintf(fid, '           text = \"\"\n');
                end
            end
        else
            for t=1:length(vecAb)
                if t == 1
                    fprintf(fid, '       intervals[%d] :\n', t); % interval indices start at 1
                    fprintf(fid, '           xmin = %.3f\n', 0.0);
                    fprintf(fid, '           xmax = %.3f\n', vecAb(t)/(freq/keepSample));
                    fprintf(fid, '           text = \"\"\n');
                    
                    fprintf(fid, '       intervals[%d] :\n', t+1); % interval indices start at 1
                    fprintf(fid, '           xmin = %.3f\n', vecAb(t)/(freq/keepSample));
                    fprintf(fid, '           xmax = %.3f\n', vecAb(t+1)/(freq/keepSample));
                    fprintf(fid, '           text = \"\"\n');
                elseif t ~= length(vecAb) && mod(t,2)
                    fprintf(fid, '       intervals[%d] :\n', t); % interval indices start at 1
                    fprintf(fid, '           xmin = %.3f\n', vecAb(t)/(freq/keepSample));
                    fprintf(fid, '           xmax = %.3f\n', vecAb(t+1)/(freq/keepSample));
                    fprintf(fid, '           text = \"\"\n');
                elseif t ~= length(vecAb) && ~mod(t,2)
                    fprintf(fid, '       intervals[%d] :\n', t); % interval indices start at 1
                    fprintf(fid, '           xmin = %.3f\n', vecAb(t)/(freq/keepSample));
                    fprintf(fid, '           xmax = %.3f\n', vecAb(t+1)/(freq/keepSample));
                    fprintf(fid, '           text = \"I\"\n');
                else
                    fprintf(fid, '       intervals[%d] :\n', t); % interval indices start at 1
                    fprintf(fid, '           xmin = %.3f\n', vecAb(t)/(freq/keepSample));
                    fprintf(fid, '           xmax = %.3f\n', fileLen/(freq/keepSample));
                    fprintf(fid, '           text = \"\"\n');
                end
            end
        end
        
        f = f - 3; % decrease file length by 3
        thoIndex = thoIndex + 3; % increase thorax index by 3
        abdIndex = abdIndex + 3; % increase abdomen index by 3
    end
    
    fclose('all'); % close all opened files 
    fprintf('Press ENTER to procceed with the next participant!\n');
    pause
    
    d = d - 1; % decrease number of folders by 1
    orderIndex = orderIndex + 1; % increase folder index by 1
    
end

fprintf('Finished with all files!\n');

%         % write output to file
%         header = {'onsets' 'onsets_value' 'maxpoints' 'maxpoints_value'};
%         labels = {onsets(:,1) onsets(:,2) maxpoints(:,1) maxpoints(:,2)};
%         xlswrite([mainDir partDir(orderIndex).name '\' strtok(fileList(thoIndex).name, '.') '.xlsx'], header)
%         xlswrite([mainDir partDir(orderIndex).name '\' strtok(fileList(thoIndex).name, '.') '.xlsx'], labels, ...
%              sprintf('A2:D%s', num2str(max(cellfun(@length, labels)))))
