clear 
close
%%
fn = '/home/perception/gebru/Desktop/sound.wav';
%% Get Audio
% if you want to crop out some signal at the start or end
cs =0;
ce =0;
[sound,rfs] = audioread(fn);
sound = sound(rfs*cs+1:end-rfs*ce,1);

%%
THRESHOLD = -6; % Threshold to update the noise spectrum
ALPHA = 0.4; % update rate (forgotten factor)
NORDER = 6; % order
WINSIZE = 2048; % window size
WINDOW = hamming(WINSIZE,'symmetric'); % hamming window type
ltsd = LTSD(WINSIZE,WINDOW,NORDER,ALPHA,THRESHOLD);
res =  ltsd.compute(sound);
%% SHOW RESULT
USIZE = 4; % to throw away segments which are less that USIZE * WINSIZE
max_level = max(max(abs(sound)));
max_level = max_level + 0.01*max_level;
enframe = buffer(1:length(sound),WINSIZE,round(WINSIZE/2));
IDX = res>2.5;
d = IDX(2:end) - IDX(1:end-1);
vadStart = find(d==1);
vadEnd = find(d==-1);
len = (vadEnd - vadStart)*WINSIZE/rfs;
to_remove = len < USIZE*WINSIZE/rfs;
vadStart(to_remove)= [];
vadEnd(to_remove) = [];
tidx = 1:length(sound);
figure();
plot(sound,'linesmoothing','on'); hold on;
for i=1:length(vadStart)    
    x_start = enframe(1,vadStart(i)+1) + 0.5*NORDER*WINSIZE;
    x_end = enframe(end,vadEnd(i)+1) + 0.5*NORDER*WINSIZE;
    x = [x_start,x_end,x_end,x_start,x_start];
    y = [max_level,max_level,-max_level,-max_level,max_level];
    plot(x, y, 'b-','linewidth',2); hold on;
end
axis off; set(gca, 'LooseInset', [0,0,0,0]);
