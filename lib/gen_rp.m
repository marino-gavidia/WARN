function [label_1, label_2, label_3] = gen_rp(data, SEGMENTATION, file, tw, fs, img_dim, delay, dE, rp)
% GEN_RP Generates recurrence plots (RPs) from segmented ECG data.
%
%   [label_1, label_2, label_3] = gen_rp(data, SEGMENTATION, file, tw, fs,
%   img_dim, delay, dE, rp) processes ECG data to generate RPs, saving the
%   plots and their corresponding labels (representing physiological states)
%   to an HDF5 file.
%
%   Inputs:
%       data - The ECG data as a vector.
%       SEGMENTATION - Segmentation labels for the data.
%       file - Path to the HDF5 file for output.
%       tw - Time window for processing.
%       fs - Sampling frequency in Hz.
%       img_dim - Dimensions for the output images.
%       delay - Delay parameter for the RP.
%       dE - Embedding dimension for the RP.
%       rp - Flag to display the RP plot.
%
%   Outputs:
%       label_1, label_2, label_3 - Counters for each label type (for
%       additional processing or metadata).
%
%   Gavidia, M., Zhu, H., Montanari, A. N., Fuentes, J., Cheng, C., Dubner, S., ... & Goncalves, J. 
%   Early Warning of Atrial Fibrillation Using Deep Learning. 
%   Patterns, 2024.

% Initialize variables
label_1 = 0;
label_2 = 0;
label_3 = 0;
ini_seg = 1;
N = length(data);
RP_backup = int8(zeros(img_dim));

% Determine visibility of RP figures
figureVisibility = 'off';
if rp
    figureVisibility = 'on';
end
set(groot, 'defaultFigureVisible', figureVisibility);

% Generate RPs using a sliding window approach
for ini = 1:(N / (fs * 15))
    % Update interval for the current window
    ini_seg = (ini - 1) * fs * 15 + 1;
    end_seg = ini_seg + tw * fs - 1;

    % Break the loop if the end of the data is reached
    if end_seg > N
        break;
    end

    interval = ini_seg:end_seg;
    ecg_w = data(interval);

    % Generate and process RP
    try
        [~, qrs_i_raw, ~] = pan_tom(double(ecg_w), fs, 0);
        RRI = diff(qrs_i_raw) / fs;
        imagesc(rp_plot(RRI, delay, dE));
        F = getframe;
        RP = imresize(F.cdata, img_dim);
        RP = rgb2gray(RP);
        RP_backup = RP;
    catch
        RP = RP_backup;
    end
    RP = uint8(RP);

    % Update the HDF5 file with the new RP and its label
    info = h5info(file, '/x');
    curSize = info.Dataspace.Size;
    h5write(file, '/x', RP, [1, 1, curSize(end) + 1], [img_dim, 1]);

    % Write label based on segmentation
    label = determine_label(SEGMENTATION(interval));
    h5write(file, '/y', label, [1, curSize(end) + 1], [3, 1]);

    % Update label counters
    switch find(label == 1)
        case 1
            label_1 = label_1 + 1;
        case 2
            label_2 = label_2 + 1;
        case 3
            label_3 = label_3 + 1;
    end
end

end

function label = determine_label(segmentation)
% Helper function to determine the label for a given segmentation
if any(segmentation == 3)
    label = [1; 0; 0]; % AF
elseif any(segmentation == 2)
    label = [0; 1; 0]; % PRE-AF
else
    label = [0; 0; 1]; % SR
end
end
