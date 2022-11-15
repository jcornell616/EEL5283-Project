% created August 25, 2022
% He Zheng
% 

close all;
clear all;

% add path for helper functions
%addpath(['Z:\Matlab Code']);
%addpath(['Z:\Matlab Code\Functions']);

% user input: list which patient(s), visit day(s), task(s) you want to
% analyze.
pc_dir = 'Z:\';
patients = {'ET003'};
months = {[1]}; %{[1:12],[0:6]};
% an array for each cell, if empty then default is all month and day; if only one array then assume same for all patients

%day =  skip day specification, just search both days b/c recordings do not
%typically repeat over the 2 days
tasks = 6.1; %[4.333, 4.343, 4.323]; %including 4.3xxxx see recording template for task code
DBS = {};% this has to be separate for each patient bc A is not the same for each patient
%'OFF', 'A','B','C','D' - details will have to read from TEED sheet for
% default (empty) is all, so we can plot against TEED; we will typically
% not consider closed loop data here

%%
filename_string=merge_data(pc_dir, patients, months, tasks, DBS);
load ([pc_dir,'processed data\',filename_string,'.mat']);

%%
% then do whatever analysis you want with the data




