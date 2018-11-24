clearvars
close all
clc

LD_bc = [
    0.3,	0.4;
    0.4,	0.5;
    0.5,	0.6;
    0.6,	0.7;
    0.7,	0.8
    ];

chi_bc = LD_bc./(1 + LD_bc);

P_bc = [
    0.04;
    0.15;
    0.22;
    0.55;
    0.04];

vt          = 0.05:0.1:1;

chi_grid    = [vt(1:end-1)', vt(2:end)'];

n_grid      = size(chi_grid,1);

n_bc        = size(chi_bc,1);
M = nan(n_bc,n_grid);

for jj = 1:n_bc
    for ii = 1:n_grid
        out = range_intersection(chi_bc(jj,:), chi_grid(ii,:));

        if isempty(out)
            out = 0;
        end
        M(jj,ii) = range(out);
    end
end

d_chi_bc = chi_bc(:,2) - chi_bc(:,1);
NM = bsxfun(@rdivide, M, d_chi_bc);
PP = bsxfun(@times, NM, P_bc);

P_grid = sum(PP);

P_grid