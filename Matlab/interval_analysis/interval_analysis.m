%
%
%
% Interesting observation: does not matter which partial factor set is selected as far as the corresponding objective function is the same, the beta interval willl be the same
%
% simple_gfun(Q, C_Q, G, K_E, R, K_R)
% WARNING!
% x(1:2)        Q   (k2m, cov)
% x(3:4)        G   (k2m, cov) G_k is determined by load ratio, khi
% x(5:6)        R   (k2m, cov) R_k is determined by partial factor-based design
% x(7:8)        K_R (k2m, cov)

clearvars
% close all
clc

addpath('D:\Working folder\Matlab working folder\Belarus_calibration\')

%==========================================================================
% CONTROL & OPTIONS
%==========================================================================

obj_fun_type  = 'sym';
gamma_Q_type  = 'constant'; % for all variable actions!
gamma_Q_diff  = 'no';

% ii      = 3;    % lead_action
jj      = 1;    % limit_state

int_Q = [
    0.90,   1.10;       % Q_S  (k2m)
    0.19,   0.23;       % Q_S  (cov)
    0.60,   0.60;       % Q_I  (k2m)
    0.35,   0.35;       % Q_I  (cov)
    1.00,   1.10;       % Q_W  (k2m)
    0.17,   0.20];      % Q_W  (cov)

int_rest = [
    1.00,   1.05;       % G   (k2m)
    0.07,   0.10;       % G   (cov)
    1.10,   1.20;       % R   (k2m)
    0.05,   0.08;       % R   (cov)
    1.00,   1.15;       % K_R (k2m)
    0.05,   0.10];      % K_R (cov)


%==========================================================================
% INITIALIZATION
%==========================================================================
fname = ['D:\Working folder\Matlab working folder\Belarus_calibration\results\',...
    'obj_fun.',obj_fun_type,...
    '_gamma_Q_type.',gamma_Q_type,...
    '_gamma_Q_diff.',gamma_Q_diff,...
    '_load_combi.simple_t_ref.50_beta_t.2.3_limit_state.1_lead_action.1  2  3.mat'];

load(fname)

n_load_ratio = length(Model.load_ratio_idx);
% n_load_ratio = 1;
n_lead_action = length(Model.lead_action_idx);

% #########################################################################
% select a particular solution
Results     = filter_Results(Results);
Results     = select_Results(Model, Results, 0); % WARNING!
partial_f   = Results.partial_f;
% #########################################################################


%==========================================================================
% INTERVAL ANALYSIS - brute force interval propagation by optimization
%==========================================================================

Results             = calibrate(Model, partial_f); % just to get the correct Probvar corresponding to the selected ii,jj,kk triplet, a little bit overkill and messy
Probvar             = Results.Probvar;

options = optimoptions('fmincon','MaxFunEvals', 1e5, 'TolFun',1e-5,'UseParallel',true);
options.Algorithm   = 'active-set';
% options.Display     = 'iter';

beta_int = nan(n_load_ratio, 2, n_lead_action);
beta_mid = nan(n_load_ratio, 1, n_lead_action);

% loop over leading actions
for ii = 1:n_lead_action
    idx     = 1+2*(ii-1);
    int     = [int_Q(idx:(idx+1),:); int_rest];
    lb      = int(:,1);
    ub      = int(:,2);
    % loop over load ratios
    for kk = 1:n_load_ratio
        
        % ii                  = lead_action_idx;
        % jj                  = limit_state_idx;
        % kk                  = load_ratio_idx;
        reli_fun = @(x) reli_analysis(x, Model, Results, ii, jj, kk);
        
        [Xmin, beta_min] = fmincon(reli_fun, (lb+ub)/2,[],[],[],[],lb,ub,[],options);
        [Xmax, beta_max] = fmincon(@(x) -reli_fun(x), (lb+ub)/2,[],[],[],[],lb,ub,[],options);
        
        beta_int(kk,:,ii) = [beta_min, -beta_max];
        
        beta_mid(kk,:,ii) = reli_fun((lb+ub)/2);
    end
end

% beta_int

%==========================================================================
% PLOT
%==========================================================================
khi = Model.khi(:,jj,ii);

figure('Position', [100, 400, n_lead_action*400, 300])
for ii = 1:n_lead_action
    subplot(1,3,ii)
    bi = beta_int(:,:,ii);
    bm = beta_mid(:,:,ii);
    bt = Model.beta_target;
    plot(khi, bi)
    hold on
    plot(khi, bm, '--')
    plot(khi, repmat(bt, size(khi)), 'r--')
    ylim([0, max(max(bi))*1.05])
    xlim([0.1, 0.9])
    ylabel('$\beta$', 'Interpreter', 'LaTeX')
    xlabel('$\chi = C_\mathrm{k} \cdot Q_\mathrm{k}/(G_\mathrm{k} + C_\mathrm{k} \cdot Q_\mathrm{k})$', 'Interpreter', 'LaTeX')
    set(gca,'TickLabelInterpreter', 'LaTeX')
end



rmpath('D:\Working folder\Matlab working folder\Belarus_calibration\')