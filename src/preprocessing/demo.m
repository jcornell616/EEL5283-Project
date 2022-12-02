% created August 25, 2022
% He Zheng
% 

close all;
clear all;

% user input: list which patient(s), visit day(s), task(s) you want to
% analyze.
pc_dir = 'C:\Users\jacks\';
patients = {'ET003'};
months = {[1:2]};%{[1:12],[0:6]};
% an array for each cell, if empty then default is all month and day; if only one array then assume same for all patients

day = {}; %skip day specification, just search both days b/c recordings do not
%typically repeat over the 2 days
tasks = {}; %[4.333, 4.343, 4.323]; %including 4.3xxxx see recording template for task code
DBS = {};% this has to be separate for each patient bc A is not the same for each patient
%'OFF', 'A','B','C','D' - details will have to read from TEED sheet for
% default (empty) is all, so we can plot against TEED; we will typically
% not consider closed loop data here

%%
filename_string = merge_data(pc_dir, patients, months, tasks, DBS);
data = load ([pc_dir,'processed_data\',filename_string,'.mat']);

%%

% parameters
lfp_fs = 250;
acc_fs = 518;

% filter parameters
b = [-0.007288816315017994,0.013495008808199113,0.027547095103915557,-0.011505024521146143,...
  -0.03039964096334081,0.03674316034136654,0.040610848250408706,-0.08762774998434325,...
  -0.047395556465362275,0.3117608964306181,0.5499223350011418,0.3117608964306181,-0.047395556465362275,...
  -0.08762774998434325,0.040610848250408706,0.03674316034136654,-0.03039964096334081,...
  -0.011505024521146143,0.027547095103915557,0.013495008808199113,-0.007288816315017994];

a = [1];

% organize data
lfp = data.all.LFP{1};
acc = data.all.acc{1};

% decimate LFP data
dec_lfp_fs = 125;
dec_factor = lfp_fs / dec_lfp_fs;
filtered_lfp = filter(b, a, lfp(1:5000, 1));
dec_lfp = decimate(filtered_lfp, dec_factor);

% plot spectrogram
spectrogram(lfp(:, 1), 512, 0, 250, lfp_fs, 'yaxis')

figure()
plot([1:5000] / lfp_fs, lfp(1:5000, 1))

figure()
plot(filtered_lfp)

% ACF
p = 100;
figure()
Rxx = acf(lfp(1:256, 1), p);
