function [SEGMENTATION] = data_seg(DATA, fs, LABELS, dis_thresh, tw, n_file)
% DATA_SEG Segments the input data based on atrial fibrillation (AF) events.
%
%   [SEGMENTATION] = data_seg(DATA, fs, LABELS, dis_thresh, tw, n_file)
%   segments the input DATA into sinus rhythm (SR), pre-AF, and AF phases
%   based on LABELS provided for atrial fibrillation events.
%
%   Inputs:
%       DATA - The input signal data.
%       fs - Sampling frequency in Hz.
%       LABELS - Cell array containing AF event labels and times.
%       dis_thresh - Threshold for the coefficient of variation of R-R intervals.
%       tw - Time window for R-R interval calculation.
%       n_file - File index to select the correct labels.
%
%   Outputs:
%       SEGMENTATION - An array indicating the segmented parts of the input data.
%                      1 = Sinus Rhythm (SR), 2 = Pre-AF, 3 = AF
%
%   Gavidia, M., Zhu, H., Montanari, A. N., Fuentes, J., Cheng, C., Dubner, S., ... & Goncalves, J. 
%   Early Warning of Atrial Fibrillation Using Deep Learning. 
%   Patterns, 2024.


% Initialize variables
N = length(DATA);
m = fs * 60; % Sampling frequency in minutes
SR_ini = 1; % Start index for sinus rhythm
SEGMENTATION = ones(N, 1); % Default to sinus rhythm

% Calculate mean R-R interval
RR_T = get_RRI(DATA, fs, tw);
mean_rri = trimmean(horzcat(RR_T{:}), 5);

% Data segmentation
for tt = 2:width(LABELS)
    if (LABELS{tt}{n_file} ~= "[]")
        % Parse AF event start and end times
        AF = split(erase(LABELS{tt}{n_file}, ["[", "]"]), ' ');
        AF_ini = str2double(AF{1});
        AF_end = str2double(AF{2});

        % Detect pre-AF segment
        PreAF = find_preaf(DATA(SR_ini:AF_ini), AF_ini, fs, dis_thresh, tw, mean_rri);

        % Segment data into SR, Pre-AF, and AF
        SEGMENTATION(SR_ini:AF_ini) = 1; % SR
        SEGMENTATION(PreAF + 1:AF_ini) = 2; % Pre-AF
        SEGMENTATION(AF_ini + 1:AF_end) = 3; % AF

        SR_ini = AF_end + 1;
    else
        SR_end = N;
        SEGMENTATION(SR_ini:SR_end) = 1; % SR
        break
    end
end

end
