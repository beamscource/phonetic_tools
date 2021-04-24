
y = downsample(thorax,10);
[b,a]= butter(6,.01); %6th order butterworth
Hd = dfilt.df2t(b,a);

thor_filt1=filtfilt(b,a,thorax);
thor_filt2=filtfilt(b,a,y);
figure
subplot(4,1,1), plot(diff(thor_filt1), 'g')
title('Filter ohne downsampling: erste Abletung')
axis tight
%xlim([-5 5])
hold on
subplot(4,1,2), plot(diff(thor_filt2), 'r')
title('Filter mit downsampling: erste Abletung')
axis tight
%xlim([500 5000])
hold on
subplot(4,1,3), plot(diff(diff(thor_filt2)), 'b')
title('Filter mit downsampling: zweite Abletung')
axis tight
%xlim([500 5000])
subplot(4,1,4), plot(diff(thorax))
title('Ohne Filter und ohne downsampling: erste Ableitung')
axis tight

figure
subplot(4,1,1), plot(thorax, 'g')
title('Rohsignal ohne downsampling und ohne Filter')
axis tight
hold on
subplot(4,1,2), plot(y, 'r')
title('Rohsignal mit downsampling')
axis tight
%xlim([500 5000])
hold on
subplot(4,1,3), plot(thor_filt1, 'b')
title('Rohsignal gefiltert')
axis tight
%xlim([-5 5])
hold on
subplot(4,1,4), plot(thor_filt2)
title('Rohsignal mit downsampling + gefiltert')
axis tight
%xlim([500 5000])