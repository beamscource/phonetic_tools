% To convert a *.wav into *.mat in matlab try this:
%reads wav file
kn = wavread('native.wav');
%save the wav file into the default extension (.mat)
save koru_native.mat kn;

c = wavread('dialect.wav');
save dialect.mat c;

st = wavread('dialect_2.wav');
save dialect_2.mat st;


%read in a textfile with four columns: filenumber, beginning, end, sound

clear all, clc
[filenumber, sound, beg, fin]=textread('results.txt', '%s%s%f%f', 'delimiter', '\t');

%choose high and low pass for calculation of the center of gravity
highpass=12000;
lowpass=1000;

%Spectrum: center at 20ms
L=20;

% Preallocation of output vector
cogmean = zeros(length(filenumber),1);

figure;
hold on;


for i=1:length(filenumber) %for each line in the list
    if isequal(char(sound(i)), 's')
        col='r'; %if the sound is s, use red to plot
    elseif isequal(char(sound(i)), 'sh') %if the sound is ss, use blue to plot
        col='b';
    end
    % define samplerate by extracting them from the wav files % SR is always the same
    [y, samplerate] = wavread(char(filenumber(i)));
    %%put together filename
    % get file name
    filename=[char(filenumber(i)) '.mat'];
    % load the mat file
    d = load(filename);
    % get the file name
    name = fieldnames(d);
    % select data for the fricative by accessing d by the names
    data = getfield(d,name{1});    
    myfricative= data(round(samplerate*beg(i)):round(samplerate*fin(i)));
    s=struct('SIGNAL', myfricative, 'SRATE', samplerate);
    [p, f]=ComputeAOS(s, L); %calculate spectrum
    %plot spectrum
    plot(f, p, col) ;
    %calculate center of gravity
    cog=ComputeCOG(s, 'hicut', highpass, 'locut', lowpass);
    cogmean(i)= nanmean(cog);
    
    %get rid of variables no longer needed
    clear cog d data myfricative s p f col samplerate name
end;


%display the center of gravity results in order to be able to view them or
%copy them somewhere
cogmean=fix(cogmean');

%to prepare stats
%figure;
%boxplot(cogmean, sound); 


% save results in data frame for further processing
df = fopen('results_cog.txt','wt');  

fprintf(df, '%s\t', 'sound');
fprintf(df, '%s\t', 'id');
fprintf(df, '%s', 'cog');
fprintf(df, '\n');

for i = 1:size(sound, 1)
    % Open datafile for output, appending to file
    fprintf(df, '%s\t', char(sound(i)));
    fprintf(df, '%s\t', char(filenumber(i))); % i
    fprintf(df, '%f', cogmean(i));    % cog value
    fprintf(df, '\n');
end
fclose(df);

