

clearvars
close all
clc

beta_t = 2.3;
% beta_t = 3.8;

obj_fun_type  = 'sym';
gamma_Q_type  = 'constant'; % for all variable actions!
gamma_Q_diff  = 'yes';


% load data
load(['results\obj_fun.',obj_fun_type,...
    '_gamma_Q_type.',gamma_Q_type,...
    '_gamma_Q_diff.',gamma_Q_diff,...
    '_load_combi.simple_t_ref.50_beta_t.', num2str(beta_t),...
    '_limit_state.1_lead_action.1  2  3.mat'])


if beta_t == 2.3
    pf          = 1.5;
    pf_idx      = 1;
elseif beta_t == 3.8
    pf          = 2.33;
    pf_idx      = 1;
end

plot_multisolu_gamma(Model, Results, pf, pf_idx)

n_pf = length(Results.partial_f);

save_fig = 1;
if save_fig == 1
    prettify(gcf)
%     w = 5;
%     fwidth = w*n_pf;
%     fheight = w;
    fpath   = ['./figures/Figure_6_beta_t.',num2str(beta_t)];
%     figuresize(fwidth , fheight , 'cm')
    export_fig(fpath, '-png', '-m3.5')
    %export_fig(fpath, '-pdf', '-m2.5')
end