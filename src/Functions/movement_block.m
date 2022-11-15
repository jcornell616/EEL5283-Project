% He Zheng
% 2022.09.30
% based on createLabel
% takes raw acc displacement data
% return movement onset and offset time 

function [datalabels] = movement_block(accmdisplc)
threshold = mean(accmdisplc)+std(accmdisplc)*2;
datalabels = zeros(1,length(accmdisplc));
datalabels(find(accmdisplc>threshold)) =1;

end
%             ns = length(LFP_power); num_segment = 0;
%             [datalabels, displc_sampled, movement_blocks, segment_onset_idx, segment_offset_idx]...
%     = movement_block(displc{1},winLen,ns,num_segment)