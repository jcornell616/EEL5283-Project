function [filename_string] = merge_data(pc_dir, patients, months, tasks, stims)
%%
% collect trials from specified patients etc (as listed in input parameters)
% if an input is empty/null, then collect all

% possible recording formats:
% implemented:
% 1) individual trials 1 trigno file per actual physical trial

% not yet implemented:
% 2) individual trials but spread in different sessions (typically b/c had
% to restart alpine)
% 3) individual trials but the session contains some other task
% 4) all trials for the task recorded in a single trigno file (usually
% closed loop and some earlier data)

% note read_data aleady segments LFP data by trigno trials;
% write a function to segment other trial formats

% processed file format:
% each single trial has its own entry in the final structure
% struct{n}.patientID, month, day, stim (DBS program),
% sessionID, trigno (trigno trial #), summit (trial #?? - actual trial number for that task recording block)
% LFP { time points x 4 channels }  %from 1 excel entry, you'd have session
% and trial(trigno) range, then break the trials, then
% acc
% cued movement onset time, if any- this can be added as a column in excel
% recording_channels

%%
all_idx = 0; % append ALL selected trials
filename_string ='';
for patient_index = 1:length (patients)
    clear patient_ID; clear data_file; clear data_sheets;
    patient_ID = patients{patient_index};
    data_file = [pc_dir,patient_ID,'\', patient_ID,'_Data.xlsx'];
    data_sheets = sheetnames(data_file);
    filename_string = [filename_string, patient_ID];
    
    clear month_string;
    % either specify a range for each patient, or use the same for all
    if length(months) == length (patients)
        month_string = months{patient_index};        
    else
        month_string = months{1};        
    end
    filename_string = [filename_string, 'M', num2str(month_string)];
        
    for month_idx = 1:length(month_string) %0:24 %month 0 is threshold visit, for the excel sheet formmated to M0D1, no day 2
        month = month_string(month_idx);
        for day = 1:2
            clear data_sheet; clear data_table; clear day_dir;
            data_sheet = ['M',num2str(month),'D',num2str(day)];
            
            if find(data_sheets==data_sheet) % if found; case sensitivie
                excel_filename = [pc_dir,patient_ID,'\', patient_ID,'_Data.xlsx'];
                opts = detectImportOptions(data_file);
                opts = setvartype(opts,'string');  % or 'char'
                %data_table = readtable([pc_dir,patient_ID,'\', patient_ID,'.xlsx'],opts,'Sheet',data_sheet);
                %using option to force string causes matlab to drop columns
                %for unknown reasons; but if not read as string had problem
                %with certain fields - trial #
                data_table = readtable(data_file,'Sheet',data_sheet);
                %keyboard;
            else
                continue
            end
            import_col = find(string(data_table.Properties.VariableNames) == "import");
            session_col = find(string(data_table.Properties.VariableNames) == "session");
            trigno_col = find(string(data_table.Properties.VariableNames) == "trigno");
            summit_col = find(string(data_table.Properties.VariableNames) == "summit");
            task_col = find(string(data_table.Properties.VariableNames) == "task");
            stim_col = find(string(data_table.Properties.VariableNames) == "stim");
            amplitude_col = find(string(data_table.Properties.VariableNames) == "amplitude");
            ch0_col = find(string(data_table.Properties.VariableNames) == "ch0");
            ch1_col = find(string(data_table.Properties.VariableNames) == "ch1");
            ch2_col = find(string(data_table.Properties.VariableNames) == "ch2");
            ch3_col = find(string(data_table.Properties.VariableNames) == "ch3");
            %TRS_col =  find(string(data_table.Properties.VariableNames) == "TRSscore");
            day_dir = dir([pc_dir, patient_ID,'\*Month',num2str(month), ' Day',num2str(day),'*']);%Month00 Day1 should come up with only 1
            % open each pre-processed session.mat, find from sheet which
            % trial to read in, what task and stim
            
            clear sessions;
            %find sessions that match input parameter task code and DBS
            % if task code is within input parameter task codes, and DBS
            for table_index = 1:size(data_table,1)                
                % For a numerical value on excel sheet (e.g. ET1 M1D1 task)
                % matlab imports it as a cell, not sure why. Other times
                % even though it's the same thing (e.g. ET2 M2 task) is not
                % a problem, it's imported as a single number as it is on
                % the excel sheet. Not sure why that is, so just convert
                % anything that's a cell into double
                if strcmpi(class(data_table{table_index,task_col}),'cell')
                    this_task =  str2num(data_table{table_index,task_col}{1}); %double
                end
                if strcmpi(class(data_table{table_index,task_col}),'double')                    
                    this_task =  data_table{table_index,task_col};
                end                
                if strcmpi(class(data_table{table_index,task_col}),'char')                    
                    this_task =  str2num(data_table{table_index,task_col});
                end
                if isempty(this_task)
                    task_match = 0;
                    display(['M',num2str(month),'D',num2str(day), ' line',num2str(table_index),' empty task column']);
                        continue;
                end
                if isempty(tasks) %input task, empty means don't care
                    task_match = 1;
                else
                    %task_match = ~isempty(strfind (num2str(tasks),data_table{table_index,task_col}));
                    %task_match = startsWith(num2str(this_task),num2str(tasks));
                    this_task
                    tasks
                    task_match = (this_task>=tasks) & (this_task<(tasks+0.1)); %single task category
                    display(['M',num2str(month),'D',num2str(day), ' line',num2str(table_index),' task column']);
                    %keyboard;
                end

                if task_match
                   display(['M',num2str(month),'D',num2str(day), 'line',num2str(table_index)]);
                   %keyboard;
                end
                
                if isempty(stims)
                    stim_match = 1;
                else
                    stim_match = ~isempty(strfind (num2str(stims),data_table{table_index,stim_col}));
                end
                
                if task_match & stim_match & strcmpi(data_table{table_index,import_col},'y')
                    clear session; clear tmp;
                    tmp = data_table(table_index,:);
                    session_ID = data_table{table_index,session_col}{1};  
                    if exist([day_dir.folder,'\',day_dir.name,'\',session_ID,'.mat'])
                    load([day_dir.folder,'\',day_dir.name,'\',session_ID,'.mat']);
                    else
                        display(['use read_data to import ',session_ID,' first!']);
                        keyboard;
                    end
                    
                    clear ch0; clear ch1; clear ch2; clear ch3;
                    if strcmpi(tmp{:,ch0_col}{1},'vo')
                        ch0 = [session.DeviceSettings{1}.SensingConfig.timeDomainChannels(1).minusInput,session.DeviceSettings{1}.SensingConfig.timeDomainChannels(1).plusInput];
                        ch1 = [session.DeviceSettings{1}.SensingConfig.timeDomainChannels(2).minusInput,session.DeviceSettings{1}.SensingConfig.timeDomainChannels(2).plusInput];
                        ch2 = [session.DeviceSettings{1}.SensingConfig.timeDomainChannels(3).minusInput,session.DeviceSettings{1}.SensingConfig.timeDomainChannels(3).plusInput];
                        ch3 = [session.DeviceSettings{1}.SensingConfig.timeDomainChannels(4).minusInput,session.DeviceSettings{1}.SensingConfig.timeDomainChannels(4).plusInput];
                        sense_channel = 'auto'; % has to read from summit file b/c no one wrote it down
                    else
                        ch0 = str2num(tmp{:,ch0_col}{1}); %an array of 2 numbers, cathod and anode
                        ch1 = str2num(tmp{:,ch1_col}{1});
                        ch2 = str2num(tmp{:,ch2_col}{1});
                        ch3 = str2num(tmp{:,ch3_col}{1});
                        sense_channel = 'manual'; %manually recorded in recording excel sheet
                    end
                    
                    clear summit_trial_idx; clear trigno_trial_idx;
                    
                    if strcmpi(class(tmp{:,summit_col}),'cell')
                        summit_trial_idx = str2num(tmp{:,summit_col}{1});
                    end
                    if strcmpi(class(tmp{:,summit_col}),'char')
                        summit_trial_idx = str2num(tmp{:,summit_col}); % index for summit data block
                    end
                    if strcmpi(class(tmp{:,summit_col}),'double')
                        summit_trial_idx = (tmp{:,summit_col});
                    end

                    if strcmpi(class(tmp{:,trigno_col}),'cell')
                        trigno_trial_idx = str2num(tmp{:,trigno_col}{1});
                    end
                    if strcmpi(class(tmp{:,trigno_col}),'char')
                        trigno_trial_idx = str2num(tmp{:,trigno_col});
                    end
                    if strcmpi(class(tmp{:,trigno_col}),'double')
                        trigno_trial_idx = (tmp{:,trigno_col});
                    end
                    num_trial_row = length(summit_trial_idx);
                    clear task;                   
                    task = repmat(this_task, 1, num_trial_row/length(this_task));
                    
                    clear stim; clear amplitude;
                    stim = tmp{:,stim_col}{1};
                    amplitude = tmp{:,amplitude_col};
                    %   TRS_score =  tmp{:,TRS_col};
                    %num_trial =  %summit_trial_idx
                    % and trigno should have the same number of trials, but
                    % trial numbers sometimes don't line up
                    for ti = 1:num_trial_row
                        all_idx = all_idx + 1;
                        all.LFP{all_idx}= session.LFP{summit_trial_idx(ti)};
                        all.acc{all_idx}= session.accmdata{trigno_trial_idx(ti)};
                        
                        % add month/day, session#, and summit/trigno trial#s
                        % recording channnel, task code
                        % program (amplitude;freq, pulse, contacts, TEED),
                        
                        all.month(all_idx)=month;
                        all.day{all_idx}=day;
                        all.session_ID{all_idx}=session_ID;
                        all.summit_trial_idx{all_idx}=summit_trial_idx(ti);
                        all.trigno_trial_idx{all_idx}=trigno_trial_idx(ti);
                        
                        all.ch0{all_idx}= ch0;
                        all.ch1{all_idx}= ch1;
                        all.ch2{all_idx}= ch2;
                        all.ch3{all_idx}= ch3;
                        all.sense_channel{all_idx} = sense_channel;
                        
                        all.task{all_idx}= task(ti);
                        all.stim{all_idx}= stim;
                        all.amplitude{all_idx}= amplitude;
                       % all.TRS_score{all_idx}= TRS_score;
                        %keyboard;
                        
                    end % for ti = 1:num_trial_row
                end  % if task_match & stim_match & strcmpi(data_table{table_index,import_col},'y')
            end % for table_index = 1:size(data_table,1)
        end % for day=1:2
    end % for month = 0:24
end % for patient_index = 1:length (patients)

filename_string = [filename_string , 'task',num2str(tasks),'stim'];
for i = 1:length(stims)
    filename_string = [filename_string ,stims{i}];
end

save([pc_dir,'processed data\',filename_string,'.mat'],'all','-mat');
%(patients months, tasks, stims)


