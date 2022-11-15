function avgbandPower = plotACCstft(accData_raw, Fs,FreqRange,plotstft)
% accData_raw is untrimmed length: all trials probably have diff lengths
if nargin <3 || isempty(FreqRange)
    FreqRange = [7, 13];
end
%%
%trim trials to the same length
for i=1:length(accData_raw) 
    acc_length(i) = length(accData_raw{i}); %length(all.acc{1})
end
trial_length_trim = min(acc_length);

for tr=1:length(accData_raw) 
    accData{tr,:}= accData_raw{tr}(1:trial_length_trim,:);
end

%%
for i=1:length(accData) %for each trial
    %keyboard;
    Data = accData{i};
    Disp = calcDisplacement(Data);
    XX = Disp - mean(Disp);
    if length(XX)<Fs*8
        XX(end+1:Fs*8) = 0;
    end 
    [SS,freq,time_vector] =spectrogram(XX,1024,800,1024,Fs);%256hz
    nt = length(time_vector);
    if i==1
        pnt=nt;
    end
    if nt>pnt
        SS(:,nt)=[];
        time_vector(nt)=[];
        nt = nt-1;
    elseif nt<pnt
        SS(:,pnt)=0;
        time_vector = ptime_v;
        nt = nt+1;
    end
   
    absSpec(i,:,:) = abs(SS)./size(SS,1);
    stftACCM(i,:,:) =  10*log10(absSpec(i,:,:));
    
%     %for variable length trials
%     absSpec{i} = abs(SS)./size(SS,1);
%     stftACCM{i} =  10*log10(absSpec{i});
    pnt = nt;
    ptime_v = time_vector;
end
if plotstft ==1
    %keyboard;
    freq_display = (freq >= 1) & (freq <= 30);
    figure('DefaultAxesFontSize',15), 
    imagesc(time_vector,freq(freq_display),squeeze(mean(stftACCM(:,  freq_display, :),1)));
    colormap jet
    set(gca, 'YDir', 'normal');
    cb = colorbar;
    cb.Label.String = 'Power/frequency (dB/Hz)';
    ylabel('Frequency (Hz)');
    xlabel('time [s]')
end

absSpecpower = squeeze(mean(absSpec,1));%absSpec(trial#,freq,time)
%pTot = sum(absSpecpower(freq < 200,:),1);
band_stft = absSpecpower( (freq >= FreqRange(1)) & (freq <= FreqRange(2)),:);
bandPowerx = sum(band_stft,1);
avgbandPower = mean(bandPowerx(3:end));

end