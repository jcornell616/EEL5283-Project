% @Rakibul Mowla
%% Get All ACCM Files**********************************
clear, clc
tic
disp('choose session folder contains Trigno data and DeviceNPC700478H')
%pathname = uigetdir('..\SET001');
%pathname = 'O:\UH3\SET001\20210416 Month3 Day01\Session1618494427459'; %dbs off
%pathname = 'O:\UH3\SET001\20210416 Month3 Day01\Session1618499829760'; %on

%pathname = 'O:\UH3\SET001\20210225 Month1 Day02\Session1614265439228'; %dbs off postrual tremor cognitive
%pathname = 'O:\UH3\SET001\20210225 Month1 Day02\Session1614279403762'; %dbs on

pathname = 'O:\UH3\SET003\screening_20220111\Session1641916895545';
%pathname = 'O:\UH3\test data\Session1641833724859'; % muscle blue only
disp(pathname(end-19:end))
addpath(pathname);
fnames = dir(pathname);
FcnCSV = @(x)~isempty(strfind(x.name,'TrignoData_'));
FcnNPC = @(x)~isempty(strfind(x.name,'DeviceNPC'));
summitFolder = fnames(arrayfun(FcnNPC, fnames));   % .CSV files inside PATH
%summitPath = [pathname,'\DeviceNPC700478H'];
summitPath = [pathname,'\',summitFolder.name];
trignofiles = fnames(arrayfun(FcnCSV, fnames));   % .CSV files inside PATH
Nfiles = length(trignofiles)-1; % number of files (i.e., trials)
accmdata = cell(Nfiles,2); % 1-->right hand, 2--> left
emgdata = cell(Nfiles,2);

for i=1:Nfiles
    BehavDataRaw = readtable([pathname,'\',trignofiles(i).name]);
    % sensor 9: right hand, sensor 2: right arm EMG
    % sensor 10: left hand, sensor 1: left arm EMG
    % sensor 11: head
    accmdata{i,1} = convertDelsysRaw2Array(BehavDataRaw, 11, 13);
    accmdata{i,2} = convertDelsysRaw2Array(BehavDataRaw, 19, 21);
    % Samplig rate 518
    %extract EMGs
    %this is the acc sensor (big square one) for acc signal; NOT EMG
    emgdata{i,1} = convertDelsysRaw2Array(BehavDataRaw, 9, 9);
    emgdata{i,2} = convertDelsysRaw2Array(BehavDataRaw, 17, 17);
    
    emg_right_yellow = convertDelsysRaw2Array(BehavDataRaw, 7, 7);
     emg_right_blue = convertDelsysRaw2Array(BehavDataRaw, 5, 5);
    %for right hand EMG, blue 5, yellow 7
    % for left hand EMG:
    % Samplig rate 1259
%     for j = 1:32
%       yellow_emg{i,j}=convertDelsysRaw2Array(BehavDataRaw, j, j);
%     end;
  
end
rmpath(pathname);
figure, plot(emg_right_yellow,'r'), hold on,... %title ('right arm sensor B brachioradialis');
plot(emg_right_blue,'b'), %title ('right arm sensor A Flexor carpi radialis')
keyboard;
% @Medtronic
%% Get All JSON Files****************************************************************
addpath(summitPath);
AdaptiveLog=jsondecode(fixMalformedJson(fileread('AdaptiveLog.json'),'AdaptiveLog'));
DeviceSettings=jsondecode(fixMalformedJson(fileread('DeviceSettings.json'),'DeviceSettings'));
DiagnosticsLog=jsondecode(fixMalformedJson(fileread('DiagnosticsLog.json'),'DiagnosticsLog'));
ErrorLog=jsondecode(fixMalformedJson(fileread('ErrorLog.json'),'ErrorLog'));
EventLog=jsondecode(fixMalformedJson(fileread('EventLog.json'),'EventLog'));
RawDataAccel=jsondecode(fixMalformedJson(fileread('RawDataAccel.json'),'RawDataAccel'));
RawDataFFT=jsondecode(fixMalformedJson(fileread('RawDataFFT.json'),'RawDataFFT'));
RawDataPower=jsondecode(fixMalformedJson(fileread('RawDataPower.json'),'RawDataPower'));
RawDataTD=jsondecode(fixMalformedJson(fileread('RawDataTD.json'),'RawDataTD'));
StimLog=jsondecode(fixMalformedJson(fileread('StimLog.json'),'StimLog'));
TimeSync=jsondecode(fixMalformedJson(fileread('TimeSync.json'),'TimeSync'));
rmpath(summitPath);
%keyboard;
%% Find First Good Packet Gen Time***************************************************
FirstGoodTimeAll = NaN(5,1);
if ~isempty(RawDataTD.TimeDomainData)
    for ii = 1:1:length(RawDataTD.TimeDomainData) % Find the first TD Gen Time
        if RawDataTD.TimeDomainData(ii).PacketGenTime > 0
            FirstGoodTimeAll(1,1) = RawDataTD.TimeDomainData(ii).PacketGenTime;
            break
        end
    end
end
if ~isempty(RawDataFFT.FftData)
    for ii = 1:1:length(RawDataFFT.FftData) % Find the first FFT Gen Time
        if RawDataFFT.FftData(ii).PacketGenTime > 0
            FirstGoodTimeAll(2,1) = RawDataFFT.FftData(ii).PacketGenTime;
            break
        end
    end
end
if ~isempty(RawDataPower.PowerDomainData)
    for ii = 1:1:length(RawDataPower.PowerDomainData) % Find the first Power Gen Time
        if RawDataPower.PowerDomainData(ii).PacketGenTime > 0
            FirstGoodTimeAll(3,1) = RawDataPower.PowerDomainData(ii).PacketGenTime;
            break
        end
    end
end
if ~isempty(RawDataAccel.AccelData)
    for ii = 1:1:length(RawDataAccel.AccelData) % Find the first Accel Gen Time
        if RawDataAccel.AccelData(ii).PacketGenTime > 0
            FirstGoodTimeAll(4,1) = RawDataAccel.AccelData(ii).PacketGenTime;
            break
        end
    end
end
if ~isempty(AdaptiveLog)
    for ii = 1:1:length(AdaptiveLog) % Find the first Adaptive Gen Time
        if AdaptiveLog(ii).AdaptiveUpdate.PacketGenTime > 0
            FirstGoodTimeAll(5,1) = AdaptiveLog(ii).AdaptiveUpdate.PacketGenTime;
            break
        end
    end
end
FirstGoodTime = min(FirstGoodTimeAll); %Used when using Packet Gen Time for plotting
% This will be used as a reference for all plots when plotting based off Packet Gen
% Time. It is the end of the first streamed packet. The first received sample is
% considered the zero reference.
%% Find Master System Tick and Master Time Stamp*************************************
masterTickArray = NaN(6,1);
masterTimeStampArray = NaN(6,1);
if ~isempty(RawDataTD.TimeDomainData) % Find the first TD Sys Tick and Timestamp
    masterTickArray(1) = RawDataTD.TimeDomainData(1).Header.systemTick;
    masterTimeStampArray(1) = RawDataTD.TimeDomainData(1).Header.timestamp.seconds;
end
if ~isempty(RawDataAccel.AccelData) % Find the first Accel Sys Tick and Timestamp
    masterTickArray(2) = RawDataAccel.AccelData(1).Header.systemTick;
    masterTimeStampArray(2) = RawDataAccel.AccelData(1).Header.timestamp.seconds;
end
if ~isempty(TimeSync.TimeSyncData) % Find the first Time Sync Sys Tick and Timestamp
    masterTickArray(3) = TimeSync.TimeSyncData(1).Header.systemTick;
    masterTimeStampArray(3) = TimeSync.TimeSyncData(1).Header.timestamp.seconds;
end
if ~isempty(RawDataFFT.FftData) % Find the first FFT Sys Tick and Timestamp
    masterTickArray(4) = RawDataFFT.FftData(1).Header.systemTick;
    masterTimeStampArray(4) = RawDataFFT.FftData(1).Header.timestamp.seconds;
end
if ~isempty(RawDataPower.PowerDomainData) % Find the first Pow Sys Tick and Timestamp
    masterTickArray(5) = RawDataPower.PowerDomainData(1).Header.systemTick;
    masterTimeStampArray(5) = RawDataPower.PowerDomainData(1).Header.timestamp.seconds;
end
if ~isempty(AdaptiveLog) % Find the first Adaptive Sys Tick and Timestamp
    masterTickArray(6) = AdaptiveLog(1).AdaptiveUpdate.Header.systemTick;
    masterTimeStampArray(6) = AdaptiveLog(1).AdaptiveUpdate.Header.timestamp.seconds;
end
masterTimeStamp = min(masterTimeStampArray);
I = find(masterTimeStampArray == masterTimeStamp);
masterTick = min(masterTickArray(I));
% This (masterTimeStamp and masterTick) will be used as a reference for all plots
% when plotting based off System Tick. It is the end of the first streamed packet.
% The first received sample is considered the zero reference.
rolloverseconds = 6.5535; % System Tick seconds before roll over
%% Find Relative First Packet End Time***********************************************
for i = length(DeviceSettings):-1:1 % Get last configured sample rate
    if isfield(DeviceSettings{i,1}, 'SensingConfig')
        if isfield(DeviceSettings{i,1}.SensingConfig, 'timeDomainChannels')
            if DeviceSettings{i,1}.SensingConfig.timeDomainChannels(1).sampleRate==0
                SampleRate=250; %Hz
            elseif DeviceSettings{i,1}.SensingConfig.timeDomainChannels(1).sampleRate==1
                SampleRate=500;
            elseif DeviceSettings{i,1}.SensingConfig.timeDomainChannels(1).sampleRate==2
                SampleRate=1000;
            else
                if DeviceSettings{i,1}.SensingConfig.timeDomainChannels(2).sampleRate==0
                    SampleRate=250; %Hz
                elseif DeviceSettings{i,1}.SensingConfig.timeDomainChannels(2).sampleRate==1
                    SampleRate=500;
                elseif DeviceSettings{i,1}.SensingConfig.timeDomainChannels(2).sampleRate==2
                    SampleRate=1000;
                else
                    if DeviceSettings{i,1}.SensingConfig.timeDomainChannels(3).sampleRate==0
                        SampleRate=250; %Hz
                    elseif DeviceSettings{i,1}.SensingConfig.timeDomainChannels(3).sampleRate==1
                        SampleRate=500;
                    elseif DeviceSettings{i,1}.SensingConfig.timeDomainChannels(3).sampleRate==2
                        SampleRate=1000;
                    else
                        if DeviceSettings{i,1}.SensingConfig.timeDomainChannels(4).sampleRate==0
                            SampleRate=250; %Hz
                        elseif DeviceSettings{i,1}.SensingConfig.timeDomainChannels(4).sampleRate==1
                            SampleRate=500;
                        elseif DeviceSettings{i,1}.SensingConfig.timeDomainChannels(4).sampleRate==2
                            SampleRate=1000;
                        else
                            disp('Error: undefined sampling rate')
                        end
                    end
                end
            end
            break
        end
    end
end
if I == 1 % if a time domain packet was the first packet received
    endtime1 = (size(RawDataTD.TimeDomainData(1).ChannelSamples(1).Value,1)-1)/SampleRate;
    % Sets the first packet end time in seconds based off samples and sample rate.
    % This is used as a reference for FFT, Power, and Adaptive data because these are
    % calculated after the TD data has been acquired. Accel data generates its own
    % first packet end time in seconds.
else
    endtime1 = 0;
end
%% Get General User Preferences (Timing and Spacing Schemes)*************************
if isnan(FirstGoodTime)
    disp('Time Sync not enabled. Do not plot based off Packet Gen Time!')
end
prompt = 'Input 1 to plot based off system tick or input 2 to plot based off Packet Gen Time: ';
%timing = input(prompt, 's');
timing = '2';
if strcmp(timing,'1')
    timing = true;
elseif strcmp(timing,'2')
    timing = false;
else
    error('Invalid Input')
end
prompt = 'Input 1 to linearly space packet data points or input 2 to space packet data points based off sample rate: ';
%spacing = input(prompt, 's');
spacing = '1';
if strcmp(spacing,'1')
    spacing = true;
elseif strcmp(spacing,'2')
    spacing = false;
else
    error('Invalid Input')
end
%% Get TD User Preferences***********************************************************
pref = 'y';
if strcmp(pref,'y')
    prefTD = true;
elseif strcmp(pref,'n')
    prefTD = false;
else
    error('Invalid Input')
end
%% Plot Time Domain Data*************************************************************
if ~isempty(RawDataTD.TimeDomainData) && prefTD == true %If there is data in the JSON File and user wants to plot the data
    NumberofChannels=size(RawDataTD.TimeDomainData(1).ChannelSamples,1);
    NumberofEvokedMarkers=size(RawDataTD.TimeDomainData(1).EvokedMarker,1);
    ChannelDataTD=cell(NumberofChannels,1); %Initializes Raw TD data structure
    PacketSize = 0; %Initialize Packet Sample Size structure
    EvokedMarker = cell(NumberofEvokedMarkers,1); %Initialize Evoked Marker data structure
    EvokedIndex = cell(NumberofEvokedMarkers,1); %Initialize Evoked Index data structure
    tvec = []; %Initializes time vector
    missedpacketgapsTD = 0; %Initializes missed packet count
    %Necessary if running this section consectutively--------------------------------
    if exist('stp','var')
        clear stp
    end
    %--------------------------------------------------------------------------------
    seconds = 0; %Initializes seconds addition due to looping
    % Determine corrective time offset-----------------------------------------------
    tickref = RawDataTD.TimeDomainData(1).Header.systemTick - masterTick;
    timestampref = RawDataTD.TimeDomainData(1).Header.timestamp.seconds - masterTimeStamp;
    if timestampref > 6
        seconds = seconds + timestampref; % if time stamp differs by 7 or more seconds make correction
    elseif tickref < 0 && timestampref > 0
        seconds = seconds + rolloverseconds; % adds initial loop time if needed
    end
    %--------------------------------------------------------------------------------
    loopcount = 0; %Initializes loop count
    looptimestamp = []; %Initializes loop time stamp index
    
    for ii = 1:1:length(RawDataTD.TimeDomainData) % loop through all data packets
        %Keep track of missed packets-------------------------------------------------
        if ii ~= 1
            if RawDataTD.TimeDomainData(ii-1).Header.dataTypeSequence == 255
                if RawDataTD.TimeDomainData(ii).Header.dataTypeSequence ~= 0
                    missedpacketgapsTD = missedpacketgapsTD + 1;
                end
            else
                if RawDataTD.TimeDomainData(ii).Header.dataTypeSequence ~= RawDataTD.TimeDomainData(ii-1).Header.dataTypeSequence + 1
                    missedpacketgapsTD = missedpacketgapsTD + 1;
                end
            end
        end
        %-----------------------------------------------------------------------------
        if timing == true
            %plotting based off system tick***********************************************
            if ii == 1
                endtime = (RawDataTD.TimeDomainData(ii).Header.systemTick - masterTick)*0.0001 + endtime1 + seconds; % adjust the endtime of the first packet according to the masterTick
                endtimeold = endtime - (size(RawDataTD.TimeDomainData(1).ChannelSamples(1).Value,1)-1)/SampleRate; % plot back from endtime based off of sample rate
            else
                endtimeold = endtime;
                if RawDataTD.TimeDomainData(ii-1).Header.systemTick < RawDataTD.TimeDomainData(ii).Header.systemTick
                    endtime = (RawDataTD.TimeDomainData(ii).Header.systemTick - masterTick)*0.0001 + endtime1 + seconds;
                else
                    seconds = seconds + rolloverseconds;
                    endtime = (RawDataTD.TimeDomainData(ii).Header.systemTick - masterTick)*0.0001 + endtime1 + seconds;
                end
            end
            if spacing == true
                %linearly spacing data between packet system ticks------------------------
                if ii ~= 1
                    tvec = [tvec(1:end-1), linspace(endtimeold,endtime,size(RawDataTD.TimeDomainData(ii).ChannelSamples(1).Value,1)+1)]; % Linearly spacing between packet end times
                else
                    tvec = [tvec(1:end-1), linspace(endtimeold,endtime,size(RawDataTD.TimeDomainData(ii).ChannelSamples(1).Value,1))];
                end
            elseif spacing == false
                %sample rate spacing data between packet system ticks---------------------
                tvec = [tvec, endtime-(size(RawDataTD.TimeDomainData(ii).ChannelSamples(1).Value,1)-1)/SampleRate:1/SampleRate:endtime];
            end
            %-------------------------------------------------------------------------
            for i=1:NumberofChannels %Construct Raw TD Data Structure
                ChannelDataTD{i,1}= [ChannelDataTD{i,1}, RawDataTD.TimeDomainData(ii).ChannelSamples(i).Value'];
                PacketSize(ii) = size(RawDataTD.TimeDomainData(ii).ChannelSamples(1).Value,1);
            end
        elseif timing == false
            %plotting based off packet gen times******************************************
            if RawDataTD.TimeDomainData(ii).PacketGenTime > 0 % Check for Packet Gen Time
                if spacing == true
                    %linearly spacing data between packet gen times-----------------------
                    if ~exist('stp','var')
                        stp = 1;
                        endtime = (RawDataTD.TimeDomainData(ii).PacketGenTime-FirstGoodTime)/1000 + endtime1; % adjust the endtime of the first packet according to the FirstGoodTime
                        endtimeold = endtime - (size(RawDataTD.TimeDomainData(1).ChannelSamples(1).Value,1)-1)/SampleRate; % plot back from endtime based off of sample rate
                        tvec = [tvec(1:end-1), linspace(endtimeold,endtime,size(RawDataTD.TimeDomainData(ii).ChannelSamples(1).Value,1))];
                    else
                        endtimeold = endtime;
                        endtime = (RawDataTD.TimeDomainData(ii).PacketGenTime-FirstGoodTime)/1000 + endtime1;
                        tvec = [tvec(1:end-1), linspace(endtimeold,endtime,size(RawDataTD.TimeDomainData(ii).ChannelSamples(1).Value,1)+1)];
                    end
                elseif spacing == false
                    %sample rate spacing data between packet gen times--------------------
                    endtime = (RawDataTD.TimeDomainData(ii).PacketGenTime-FirstGoodTime)/1000 + endtime1;
                    tvec = [tvec, endtime-(size(RawDataTD.TimeDomainData(ii).ChannelSamples(1).Value,1)-1)/SampleRate:1/SampleRate:endtime];
                end
                %---------------------------------------------------------------------
                for i=1:NumberofChannels %Construct Raw TD Data Structure
                    ChannelDataTD{i,1}= [ChannelDataTD{i,1}, RawDataTD.TimeDomainData(ii).ChannelSamples(i).Value'];
                    PacketSize(ii) = size(RawDataTD.TimeDomainData(ii).ChannelSamples(1).Value,1);
                end
            end
        end
        %*****************************************************************************
        if ii ~= 1
            if RawDataTD.TimeDomainData(ii-1).Header.systemTick > RawDataTD.TimeDomainData(ii).Header.systemTick
                loopcount = loopcount + 1;
                looptimestamp(end+1) = RawDataTD.TimeDomainData(ii).Header.timestamp.seconds;
            end
        end
    end
    
    figure,
    linestyle = 'b-';
    for i=1:NumberofChannels
        TDaxi(i) = subplot(NumberofChannels,1,i);
        XX(:,i) =ChannelDataTD{i,1}; % saving channel data in XX
        plot(tvec, ChannelDataTD{i,1},linestyle)
        title(['Time Domain Data Output: Channel ',int2str(RawDataTD.TimeDomainData(1).ChannelSamples(i).Key)])
        xlabel('Time (s)')
        ylabel('Voltage (mV)')
    end
    
    
elseif isempty(RawDataTD.TimeDomainData) %Inform user that there is no data in the JSON File
    disp('No TD Data Available to Plot')
end
toc
%% Segmenting trials @Rakib
tvecDiff = diff([0,tvec]);
timethrsh = 0.08;
tvecDiff(tvecDiff>timethrsh)=1;
tvecDiff(tvecDiff<timethrsh)=0;

triggV = diff([0,tvecDiff]);
figure; plot(normalize(XX(:,1))); hold on;
plot(3*triggV); hold off;

startIndx = [1,find(triggV<0)]; % find trial start indexes
endIndx = [find(triggV>0),length(tvec)]; % find trial end indexes

LFPs = cell(length(startIndx),1);
for i = 1:length(startIndx)
    LFPs{i} = XX(startIndx(i):endIndx(i),:);
end
keyboard;
clearvars -except LFPs accmdata emgdata %clear non-essential variables

%% Help Functions
function arr = convertDelsysRaw2Array(RawData, StartIdx, EndIdx)
arr = table2array(rmmissing(RawData(:, StartIdx:EndIdx)));
end