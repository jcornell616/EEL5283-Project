% He Zheng
% 2022.03.16

% Based on ReadJSONnTrignoNSummit and readAccLFP 
% reads specified recording sessions from each (new) visitng day (indicate
% 'y' on "import" column on patient data sheet (patient_ID.xlsx)

% save each (alpine) session into sessionxxxxxxx.mat; data structure: 
% structure "session" with fields:
% session.accmdata: {[174230×3 double]  []}
% session.LFP: {[83938×4 double]}
% session.DeviceSettings: {24×1 cell}

% save data table (imported patient data sheet from excel to matlab table)

close all; 
clear all;

addpath('C:\Users\jacks\OneDrive\Desktop\Github\eel5283-project\EEL5283-Project\src\Functions');

%%
pc_dir = 'C:\Users\jacks\';
patient_ID = 'ET003';
dominant_hand = 0;
Month = 2;
Day = 2;
new_only = 1;
% 1: reading newly appointed sessions only, so if sessionxxxx.mat already exist, do not read again
% 0: read everything that has 'y' on import column, already exists or not

%%
day_dir = dir([pc_dir, patient_ID,'\*Month', num2str(Month), ' Day',num2str(Day),'*']);%Month00 Day1 should come up with only 1
datasheet =['M',num2str(Month),'D',num2str(Day)];
%opts = detectImportOptions([pc_dir,'\', patient_ID,'.xlsx'],'NumHeaderLines',1);
%data_table = readtable([pc_dir,'\', patient_ID,'.xlsx'],opts,'Sheet',datasheet );
data_table = readtable([pc_dir,patient_ID,'\', patient_ID,'_Data.xlsx'],'Sheet',datasheet );

% find column index for whether to import line or not
import_col = find(string(data_table.Properties.VariableNames) == "import");
if (isempty(import_col))
    display(['import header error: ',pc_dir, patient_ID,'.xlsx\',datasheet]);
    keyboard;
end

% find the rows that says 'y' to import
import_row = find(strcmpi(data_table{:,import_col},'y'));
%keyboard;
% go through all sessions to be imported, save each single trial
% save task code and stim for each trial; then all in one big struct
% when doing anaylysis unpack all trials available for that day
session_col = find(string(data_table.Properties.VariableNames) == "session");
% all sessions to be imported:
sessions = unique(data_table{import_row, session_col});

trigno_col = find(string(data_table.Properties.VariableNames) == "trigno");
task_col = find(string(data_table.Properties.VariableNames) == "task");
stim_col = find(string(data_table.Properties.VariableNames) == "stim");
amplitude_col = find(string(data_table.Properties.VariableNames) == "amplitude");
ch0_col = find(string(data_table.Properties.VariableNames) == "ch0");
ch1_col = find(string(data_table.Properties.VariableNames) == "ch1");
ch2_col = find(string(data_table.Properties.VariableNames) == "ch2");
ch3_col = find(string(data_table.Properties.VariableNames) == "ch3");
TRS_col = find(string(data_table.Properties.VariableNames) == "TRSscore");
for i = 1:length(sessions)
    if new_only && exist([day_dir.folder,'\',day_dir.name,'\',sessions{i},'.mat']) 
        display([sessions{i},'already exist']);
    else
        
        clear session;
        [session.accmdata, session.LFP, NumberofChannels, session.DeviceSettings]=readAccLFP([day_dir.folder,'\',day_dir.name,'\',sessions{i}], dominant_hand);
        %read each session once, save entire session block,
        % when analyze, go into the sheet again and find session and trial #'s
        % for each task-stim combo, then have a group of trials for that. easier
        % than re-indexed sessions that still contain different task/stim and
        % vice versa, then woudl have to reindex all in order to find all trials
        % for the same task-stim combo
        
        %for older data where sensing channels aren't written down
        %DeviceSettings{1}.SensingConfig.timeDomainChannels(4)
        
        save([day_dir.folder,'\',day_dir.name,'\',sessions{i},'.mat'],'session','-mat');
    end
end

%after reading in each session some manual adjustments are often necessary-
%update the summit trial # on the sheet, update sheet before saving
data_table = readtable([pc_dir,patient_ID,'\', patient_ID,'_Data.xlsx'],'Sheet',datasheet );
save([day_dir.folder,'\',day_dir.name,'\data_table.mat'],'data_table','-mat');
%{
clear save_row;
  save_row = find(strcmp(data_table{:,session_col}, sessions{i}) & strcmp(data_table{:,import_col},'y'));
  
clear trigno_idx;
  trigno_idx = [];
  trial_idx = 1;
  for j=1:length(save_row)
         trigno_idx = [trigno_idx, str2num(data_table{save_row(j),trigno_col}{1})];
         task = data_table{
         session.LFP = LFPs{trigno_idx};
  end
  keyboard;
  %}
