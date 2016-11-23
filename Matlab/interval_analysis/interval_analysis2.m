% Interval-based reliability analysis
% keeping the quantile(fractile) rules of Eurocode
%
%
% Interesting observation: does not matter which partial factor set is selected as far as the corresponding objective function is the same, the beta interval willl be the same
%
%
%
% Notes:
% - there is a small difference between the calibrated and mid values - because for Q the mid is taken for t_ref maxima and not for annual maxima
%   (with the same partial factors!)
%
%
% simple_gfun(Q, C_Q, G, K_E, R, K_R)
% WARNING!
% x(1)          Q   (cov) + 98% rule or 99.5% for imposed for EC (for SNiP different)
% x(2)          G   (cov) + 50% rule; G_k is determined by load ratio, khi
% x(3)          R   (cov) + 2% rule; R_k is determined by partial factor-based design
% x(4:5)        K_R (k2m, cov)
%


clearvars
% close all
clc

addpath('D:\Working folder\Matlab working folder\Belarus_calibration\')

%==========================================================================
% CONTROL & OPTIONS
%==========================================================================

obj_fun_type  = 'sym';
gamma_Q_type  = 'constant'; % for all variable actions!
gamma_Q_diff  = 'yes';

% ii      = 3;    % lead_action
jj      = 1;    % limit_state

% for annual maxima!
int_Q = [
    0.48,   0.62;       % Q_S  (cov)
    1.10,   1.10;       % Q_I  (cov)
    0.30,   0.50];      % Q_W  (cov)

int_rest = [
    0.07,   0.10;       % G   (cov)
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

n_load_ratio    = length(Model.load_ratio_idx);
% n_load_ratio = 1;
lead_action_idx = Model.lead_action_idx;
n_lead_action   = length(Model.lead_action_idx);

% #########################################################################
% select a particular solution
% % Results     = filter_Results(Results);
% % Results     = select_Results(Model, Results, 0); % WARNING!
% % partial_f   = Results.partial_f;

% with partial factors based on expert judgement
% partial_f       = [1.50, 1.50, 1.30, 1.05, 1.15];
% partial_f       = [1.50, 1.05, 1.15];
% partial_f       = [1.60, 1.50, 1.40, 1.15, 1.025];
% partial_f       = [1.50, 1.20, 1.40, 1.15, 1.025];
% partial_f       = [1.60, 1.30, 1.40, 1.15, 1.025];
partial_f = [1.50, 1.00, 1.30, 1.05, 1.15];
Results         = calibrate(Model, partial_f); % no calibration only calculates the betas at the given set of partial factors

% #########################################################################

t_ref           = Model.t_ref;

%==========================================================================
% INTERVAL ANALYSIS - brute force interval propagation by optimization
%==========================================================================

options         = optimoptions('fmincon','MaxFunEvals', 1e5, 'TolFun',1e-5, 'UseParallel',true);
options.Algorithm   = 'active-set';
% options.Display     = 'iter';

beta_int        = nan(n_load_ratio, 2, n_lead_action);
beta_mid        = nan(n_load_ratio, 1, n_lead_action);

% loop over leading actions
for ii = 1:n_lead_action
    
    % loop over load ratios
    for kk = 1:n_load_ratio
        
        % ii                  = lead_action_idx;
        % jj                  = limit_state_idx;
        % kk                  = load_ratio_idx;
        Probvar     = prob_model(kk,jj,ii, Model); % just to get the correct Probvar corresponding to the selected lead action, rest of the parameters will be overwritten later
        
        int_Q_ii    = int_Q(ii,:);
    
        if Probvar.Q.dist == 11
            % change reference period; 1-year -> t_ref
            int_Q_ii = (1./int_Q_ii + sqrt(6)/pi*log(t_ref/Probvar.Q.t)).^(-1);
        else
            error('Only Gumbel distribution is adopted for variable action yet.')
        end

        int     = [int_Q_ii; int_rest];
        lb      = int(:,1);
        ub      = int(:,2);

        reli_fun = @(x) reli_analysis2(x, Model, Probvar, partial_f, ii, jj, kk);
        
        [Xmin, beta_min] = fmincon(reli_fun, (lb+ub)/2,[],[],[],[],lb,ub,[],options);
        [Xmax, beta_max] = fmincon(@(x) -reli_fun(x), (lb+ub)/2,[],[],[],[],lb,ub,[],options);
        
        beta_int(kk,:,ii) = [beta_min, -beta_max];
        
        beta_mid(kk,:,ii) = reli_fun((lb+ub)/2);
    end
end

% beta_int
beta_mid


    
%==========================================================================
% PLOT
%==========================================================================
khi = Model.khi(:,jj,ii);

% % for verification...
% figure('Position', [100, 400, n_lead_action*400, 300])
% for ii = 1:n_lead_action
%     subplot(1,3,ii)
%     bc = Results.beta(:,:,ii);
%     bm = beta_mid(:,:,ii);
%     bt = Model.beta_target;
%     plot(khi, bc)
%     hold on
%     plot(khi, bm, '--')
%     plot(khi, repmat(bt, size(khi)), 'r--')
%     hl = legend('calibration', 'interval mid');
%     hl.Interpreter = 'LaTeX';
%     hl.Location = 'SouthEast';
%     ylim([0, max(max(max(beta_mid)))*1.1])
%     xlim([0.1, 0.9])
%     ylabel('$\beta$', 'Interpreter', 'LaTeX')
%     xlabel('$\chi = C_\mathrm{k} \cdot Q_\mathrm{k}/(G_\mathrm{k} + C_\mathrm{k} \cdot Q_\mathrm{k})$', 'Interpreter', 'LaTeX')
%     set(gca,'TickLabelInterpreter', 'LaTeX')
% end

cmp                 = get(groot,'defaultAxesColorOrder');
lead_action_marker  = {'o', 's', '^'};
lead_action_marker  = lead_action_marker(lead_action_idx);
lead_action_label   = Model.lead_action_label;

% not general, ad hoc solution
figure('Position', [100, 400, n_lead_action*400, 300])
for ii = 1:n_lead_action
    subplot(1,3,ii)
    bi = beta_int(:,:,ii);
    bm = beta_mid(:,:,ii);
    bt = Model.beta_target;
    fill([khi; flipud(khi)], [bi(:,1); flipud(bi(:,2))], cmp(ii,:), 'FaceAlpha', 0.3)
%     fill([khi; flipud(khi)], bi(:), repmat(cmp(ii,:),18,1))
    hold on
    plot(khi, bi, '-', 'Marker', lead_action_marker{ii},...
                    'MarkerFaceColor', [1,1,1],...
                    'Color', cmp(ii,:),...
                    'MarkerSize', 4)
    plot(khi, bm, 'w--', 'Linewidth', 2)
    hf = plot(khi, repmat(bt, size(khi)), 'r--');
    if ii == n_lead_action
        hl = legend(hf, {'$\beta_\mathrm{target}$'});
        hl.Interpreter = 'LaTeX';
        hl.Location = 'best';
    end
    ht = title(lead_action_label{ii});
    ht.Interpreter = 'LaTeX';
    ylim([0, max(max(max(beta_int)))*1.05])
    xlim([0.1, 0.9])
    ylabel('$\beta$', 'Interpreter', 'LaTeX')
    xlabel('$\chi = C_\mathrm{k} \cdot Q_\mathrm{k}/(G_\mathrm{k} + C_\mathrm{k} \cdot Q_\mathrm{k})$', 'Interpreter', 'LaTeX')
    set(gca,'TickLabelInterpreter', 'LaTeX')
end

% save(['snip_', num2str(partial_f(1)), '.mat'], 'khi', 'beta_int', 'beta_mid', 'Model')

% rmpath('D:\Working folder\Matlab working folder\Belarus_calibration\')