function[RP] = rp_plot(data,delay,dE)
% Recurrence Plot (RP) parameters
N=length(data);
% delay;  % defined with the autocorrelation function (linear, quadratic)
% dE;    % embedding dimension (defined with false neighbors method)
Nrp = N - (dE-1)*delay;  % RP size
% Embedding
for dim = 1:dE
    Xdim(:,dim) = data(1+(dim-1)*delay:N-(dE-dim)*delay);
end
% Recurrence matrix (real matrix)
RP = zeros(Nrp,Nrp);
for dim = 1:dE
    RP = RP + (repmat(Xdim(:,dim),1,Nrp) - Xdim(:,dim)').^2;
end
RP = sqrt(RP);


end