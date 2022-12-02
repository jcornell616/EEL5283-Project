function [stim_param] = getTEED(pc_dir, patient_ID, month, stim)
 if strcmpi(stim(1), 'O')
        stim_param.teed = 0;    
 end
filename = [pc_dir,patient_ID,'\', patient_ID,'_Data.xlsx'];
opts = detectImportOptions(filename);
opts = setvartype(opts, 'string');  %or 'char' if you prefer
%data_table = readtable(filename, opts,'Sheet','test' )
%data_table = readtable(filename, 'Sheet','test', 'Range','A1:J17' ) 
data_table = readtable(filename, 'Sheet','test');
    % data_table = readtable([pc_dir,patient_ID,'\', patient_ID,'.xlsx'],'Sheet','TEED');
     % matlab sometimes has problem importing header - can't handle space
     % or symbol
     % column 1: "month x"; 
     % column 2: "A3" etc, dual or interleaving programs takes multiple
     % lines with program retyped
     
     % column 3-4 contact+/-
     % column 5: freq
     % column 6: amp
     % column 8: pulse width
     % column 10: TEED
     month_col = 1;
     stim_col = 2;
     contact_plus_col = 3;
     contact_minus_col = 3;
     freq_col = 5;
     amp_col = 6;
     pulse_col = 8;
     teed_col = 10;
     %keyboard;
     display(stim);
     rows = find( data_table{:,month_col}==month &  strcmpi(string(data_table{:,stim_col}),stim));
     % if single lead stim; you should get one row; if it's two rows; it's
     % double if dual lead; 3+ rows means interleaving programs
     
     % stim_type = 1 single, 2 dual, 3 interleaving on Vo; 4 interleaving
     % on ViM?
     stim_param.stim_type = length(rows);
     for i = 1:length(rows)
         row_idx = rows(i);
         stim_param.amp(i) = data_table{row_idx,amp_col};
         stim_param.freq(i) = data_table{row_idx,freq_col};
         stim_param.teed(i) = data_table{row_idx,teed_col};
         %, contact, ,
     end
     
     
     
     
    