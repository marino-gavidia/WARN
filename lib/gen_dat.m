function [] = gen_dat(tw, dim, fs, delay, dE, dis_thresh, inputf, outputf, SAMPLES, rp)
% GEN_DAT Generates datasets and recurrence plots for a list of samples.
%
%   gen_dat(tw, dim, fs, delay, dE, dis_thresh, inputf, outputf, SAMPLES, rp)
%   processes a list of sample files, performs data segmentation, and generates
%   recurrence plots (RPs) for each sample, saving the results in HDF5 format.
%
%   Inputs:
%       tw - Time window for R-R interval calculation.
%       dim - Dimensionality of the recurrence plot.
%       fs - Sampling frequency in Hz.
%       delay - Time delay for phase space reconstruction.
%       dE - Embedding dimension for phase space reconstruction.
%       dis_thresh - Threshold for the coefficient of variation of R-R intervals.
%       inputf - Input file directory.
%       outputf - Output file directory.
%       SAMPLES - Cell array containing sample identifiers.
%       rp - Parameters to display recurrence plot generation.
%
%   Outputs:
%       None. Results are saved to HDF5 files.
%
%   Gavidia, M., Zhu, H., Montanari, A. N., Fuentes, J., Cheng, C., Dubner, S., ... & Goncalves, J. 
%   Early Warning of Atrial Fibrillation Using Deep Learning. 
%   Patterns, 2024.

for l = 1:height(SAMPLES{1})
    file_read = SAMPLES{1}{l} + ".txt";
    output_file_path = outputf + SAMPLES{1}{l} + ".hdf5";

    % Check for existence of input and output files
    if ~isfile("data/" + file_read) || isfile(output_file_path)
        continue
    end
    
    disp(file_read); % Display the current file being processed
    [~, n_file] = fileparts(file_read);
    
    % Create HDF5 file for storing results
    file = strcat(outputf, '/', num2str(n_file), '.hdf5');
    h5create(file, '/x', [dim, dim, Inf], 'Datatype', 'uint8', 'ChunkSize', [dim, dim, 1]);
    h5create(file, '/y', [3, Inf], 'Datatype', 'double', 'ChunkSize', [3, 1]);

    % Load and preprocess data
    DATA = load(inputf + file_read);
    DATA = DATA(:, 2); % Assuming the relevant data is in the second column

    % Segment data
    SEGMENTATION = data_seg(DATA, fs, SAMPLES, dis_thresh, tw, l);

    % Generate recurrence plots
    gen_rp(DATA, SEGMENTATION, file, tw, fs, [dim, dim], delay, dE, rp);
end

end
