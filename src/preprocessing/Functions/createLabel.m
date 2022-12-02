function [datalabels, displc_sampled, movement_blocks, segment_onset_idx, segment_offset_idx] = createLabel(accmdisplc,winLength,ns,num_segment)
%hz ns is length of LFP power; winLength is length of fft window in seconds
%hz added displc_sampled, this is the re-sampled/buffered acc, not 1 or 0
%data label
%onset_idx: index where movement onset is thresheld
%num_segment is how many known trials within a single summit recording
accmdisplc = accmdisplc-mean(accmdisplc);
% figure, plot(accmdisplc), hold on, stem([1:10].*30.*Fs, ones(1, 10),'r'),
% hold on, stem(([1:10].*30+20).*Fs, ones(1, 10),'k'),
n = length(accmdisplc);
Fs = 518; % accm sampling frequency
winLen = floor(winLength*Fs);
overlap_n = ceil(winLen-n/ns);
%N-long signal into ns segments,
segments = buffer(accmdisplc,winLen,overlap_n); %this segment is re-sampled acc, NOT trial segmented by movement onset
y = var(segments,1);
if length(y)~=ns % hz padding length
    np = length(y)-ns;
    if np>0
        y(end-np+1:end)=[];
    else
        y = [zeros(1,abs(np)),y];
    end
end
displc_sampled=y;
%%
res = Fs*ns/n;
intent_lap = [9.89, 10.57, 10.06,9.70,10.58,9.41,9.88,8.69,9.05,10.54];
%intent_lap = [12.92, 12.53, 10.22, 9.79, 9.20, 8.82, 10.09, 10.55, 9.46, 8.86];
for i = 1:length(intent_lap)
    intent_time (i) = sum(intent_lap(1:i));
    xxlabel{i}= [num2str(intent_time (i)),'s'];
end; 

%segment_onset_idx = round([1:10].*30.*res);
%segment_onset_idx = round(([1:10].*10).*res); %+5
segment_onset_idx = round( (intent_time+0.5).*res);
%segment_offset_idx = round(([1:10].*30+20).*res);
%segment_offset_idx = round(([1:10].*30+5).*res);
%segment_offset_idx = round(([1:10].*10+5).*res);
segment_offset_idx = round( (intent_time+6).*res);
xx = round([1:length(y)]./res);

% figure, plot(y), hold on, stem(segment_onset_idx, ones(1, 10),'r'),hold on, 
% %stem(segment_offset_idx, ones(1, 10),'k'), hold on,
% stem(round( (intent_time).*res), ones(1, 10).*0.5,'g'), hold on,
% xticks((intent_time).*res), xticklabels(xxlabel), ylabel('acc displacement');
%keyboard;

%%
%thresold method does not always work
thrsh = 20*abs((median(y)/0.6745)*sqrt(2*log(length(y))));
%y(1:ceil(2*ns/(n/Fs))) = 0;
% hz if variance of the segment is over a threshold
datalabels = zeros(ns,1);
datalabels (y>thrsh)=1;
indxx = find(datalabels==1); % find indexes where datalabels =1
while isempty(indxx)||sum(datalabels)<ceil(2/winLength)
    thrsh = thrsh/2;
    datalabels = zeros(ns,1);
    datalabels (y>thrsh)=1;
    indxx = find(datalabels==1);
    if length(indxx)>1
        datalabels(indxx(1):indxx(end)) = 1;
    end
end
%%
%{
onset_idx=[];
for i = 1:length(indxx)    
    if indxx(i)>1 && datalabels(indxx(i)-1) ==0
        onset_idx = [onset_idx indxx(i)];
    end
end

offset_idx=[];
for i = 1:length(indxx)    
    if indxx(i)>1 && datalabels(indxx(i)+1) ==0
        offset_idx = [offset_idx indxx(i)];
    end
end
if offset_idx(1)<=onset_idx(1) 
    offset_idx(1) = [];
    display('extra offset');
end
if offset_idx(length(offset_idx))<=onset_idx(length(onset_idx))
    onset_idx(length(onset_idx)) = [];
    display('extra onset');
end
if length(offset_idx)~=length(onset_idx)
    display('invalid segment');   
end
%segment a single recording (single summit "trial") into actual trials by
%motor activity
 %threshold by inter-trial duration; or minimal motion duration; or known #
 %of trials

%original length n at 518 pts/sec, downsampled to ns points: Fs*ns/n =
%~19pt/sec for window size 256ms - not enough to threshold minimal motion
%duration for all types of trials; best way is probably by known # of
%trials


onset_diff = diff(onset_idx);
[onset_diff_sort, tmp_idx]=  sort(diff(onset_idx),'descend');
segment_onset_idx (1) = onset_idx(1);

for i = 1:(num_segment-1)
    segment_onset_idx(i+1) = onset_idx(tmp_idx(i)+1);
    keyboard
    display(num2str(i))
end
segment_onset_idx = sort(segment_onset_idx);

% find offset
offset_diff = diff(offset_idx);
[offset_diff_sort, tmp_idx]=  sort(diff(offset_idx),'descend');

for i = 1:(num_segment-1)
    segment_offset_idx(i) = offset_idx(tmp_idx(i));
end
segment_offset_idx(num_segment)=offset_idx(length(offset_idx));
segment_offset_idx = sort(segment_offset_idx);
%}
movement_blocks = zeros(length(datalabels),1);
for i = 1:(num_segment)
    movement_blocks(segment_onset_idx(i):segment_offset_idx(i)) = 1;
end
%keyboard;
% figure, plot(datalabels), hold on, stem(segment_onset_idx,ones(1,10).*0.5,'r'), hold on,
% stem(segment_offset_idx,ones(1,10).*0.5,'k'), hold on,
% plot(movement_blocks, 'g');
%{
% hz: temporarily commented out all below code: this seems to adjust threshold if it's set too
% low - but the rationale for the condition is not clear - test it again
% with first set of data: follow up 3 reach to grasp prog A, C
while indxx(1)<ceil(3/winLength)
    thrsh = 2*thrsh;
    datalabels = zeros(ns,1);
    datalabels (y>thrsh)=1;
    indxx = find(datalabels==1);
end

while indxx(end)+ceil(1/winLength)> length(datalabels)
    keyboard;
    if datalabels(end)==1||datalabels(end-1)==1
        datalabels(end-ceil(0.5/winLength):end)=0;
        indxx(end)=[];
    else
        thrsh = 5*thrsh;
        datalabels = zeros(ns,1);
        datalabels (y>thrsh)=1;
        indxx = find(datalabels==1);
    end
end
shiftV = 5;
while indxx(end)+shiftV > ns
shiftV = shiftV-1;
end
datalabels(indxx(1)-shiftV:indxx(end)+shiftV) = 1;
%}
end