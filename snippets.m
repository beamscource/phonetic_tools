%play sound
soundsc(data(:,1), samplerate)

%display data
image(data{2}(end:-1:1,:,:))

