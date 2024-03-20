function [RRI_ALL] = get_RRI(data, fs, tw)
% GET_RRI Calculates R-R intervals (RRI) from ECG data.
%
%   [RRI_ALL] = get_RRI(data, fs, tw) calculates R-R intervals over specified
%   time windows from ECG data using the Pan-Tompkins algorithm.
%
%   Inputs:
%       data - The ECG data as a vector.
%       fs - Sampling frequency in Hz.
%       tw - Time window for processing in seconds.
%
%   Outputs:
%       RRI_ALL - Cell array of R-R intervals calculated over each time window.
%
%   Gavidia, M., Zhu, H., Montanari, A. N., Fuentes, J., Cheng, C., Dubner, S., ... & Goncalves, J. 
%   Early Warning of Atrial Fibrillation Using Deep Learning. 
%   Patterns, 2024.

% Initialize variables
RRI_ALL = {};  % Cell array to store R-R intervals from each window
data_len = length(data);  % Length of the ECG data
ini = 1;  % Initial index for storing RRI

% Process the ECG data in sliding windows from the end towards the beginning
while true
    % Calculate the segment of data for the current window
    end_idx = data_len - ((ini - 1) * fs * 5);
    start_idx = max(1, end_idx - (tw * fs));
    
    % Break the loop if the start index reaches the beginning of the data
    if start_idx == 1
        break;
    end
    
    ecg_w = data(start_idx:end_idx);  % Extract the window of ECG data

    % Use the Pan-Tompkins algorithm to find QRS complexes
    [~, qrs_i_raw, ~] = pan_tom(double(ecg_w), fs, 0);

    % Calculate R-R intervals (RRI) for the current window
    RRI = diff(qrs_i_raw) / fs;

    % Store the calculated RRI
    RRI_ALL{ini} = RRI;
    
    ini = ini + 1;  % Update the index for the next window
end

% Reverse RRI_ALL to have RRI in chronological order
RRI_ALL = fliplr(RRI_ALL);

end
