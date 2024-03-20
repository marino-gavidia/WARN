function [RP] = rp_plot(data, delay, dE)
% RP_PLOT Generates a recurrence plot (RP) from time series data.
%
%   [RP] = rp_plot(data, delay, dE) calculates the recurrence plot for the given
%   time series data using specified delay and embedding dimension.
%
%   Inputs:
%       data - A vector of time series data.
%       delay - The delay parameter for phase space reconstruction, typically
%               determined by the autocorrelation function or mutual information.
%       dE - The embedding dimension, usually found using methods like false nearest
%            neighbors.
%
%   Outputs:
%       RP - A matrix representing the recurrence plot.
%
%
%   Gavidia, M., Zhu, H., Montanari, A. N., Fuentes, J., Cheng, C., Dubner, S., ... & Goncalves, J. 
%   Early Warning of Atrial Fibrillation Using Deep Learning. 
%   Patterns, 2024.

% Initialize the length of the time series and the size of the RP matrix
N = length(data);
Nrp = N - (dE - 1) * delay;  % RP size

% Phase space reconstruction using embedding
Xdim = zeros(Nrp, dE);
for dim = 1:dE
    Xdim(:, dim) = data(1 + (dim - 1) * delay : N - (dE - dim) * delay);
end

% Compute the recurrence matrix
RP = zeros(Nrp, Nrp);
for i = 1:Nrp
    for j = 1:Nrp
        % Sum of squared differences across all dimensions
        RP(i, j) = sum((Xdim(i, :) - Xdim(j, :)).^2);
    end
end

% Convert distances to similarities (optional)
RP = sqrt(RP);  % Euclidean distance
% For binary recurrence plot, apply a threshold
% RP = RP <= threshold;

end
