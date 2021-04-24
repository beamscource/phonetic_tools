clc, close all, clear all

directoryParticipant = 'E:\ZAS\p1\';
cd (directoryParticipant);

% calibration values
p1 = 0.2864;
p2 = 0.2906;
p3 = 0.2897;
p4 = 0.5205;
p5 = 0.2208;
p6 = 0.4998;

% choose the participant used for the calculation
x = p1;

% read the csv file with PIO values in the participant's directory
data = dlmread('pio_labels_table.csv', ',', 0, 6);
len = length(data);
% get rid of two last columns
data = dlmread('pio_labels_table.csv', ',', sprintf('G1..K%s', num2str(len)));

% factor to multiply with the PIO values
factor = 200/x;

dataCorr = data.*factor;

fprintf('Correction finished \n.')
