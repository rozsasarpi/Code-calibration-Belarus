% Plot results

clearvars
close all
clc

beta_target     = '3.8';
obj_fun_type    = 'sym';
gamma_Q_type    = 'constant'; % for all variable actions!
gamma_Q_diff    = 'yes';

save_fig        = 1;

partial_f_opt   = [2.33, 1.60, 2.08, 1.13, 1.22];
partial_f_exp   = [2.40, 1.60, 2.10, 1.05, 1.25];
partial_f_EC    = [1.50, 1.50, 1.50, 1.35, 1.25];
partial_f_ECb   = [1.50, 1.50, 1.50, 1.15, 1.25];

%--------------------------------------------------------------------------
% PREPROCESS
%--------------------------------------------------------------------------

load(['results\obj_fun.',obj_fun_type,...
    '_gamma_Q_type.',gamma_Q_type,...
    '_gamma_Q_diff.',gamma_Q_diff,...
    '_load_combi.simple_t_ref.50_beta_t.',beta_target,...
    '_limit_state.1_lead_action.1  2  3.mat'])

%--------------------------------------------------------------------------
% RELIABILITY LEVEL
%--------------------------------------------------------------------------

% no calibration only calculates the betas at the given set of partial factors
Results_opt     = calibrate(Model, partial_f_opt);
Results_exp     = calibrate(Model, partial_f_exp); 
Results_EC      = calibrate(Model, partial_f_EC); 
Results_ECb     = calibrate(Model, partial_f_ECb); 

% goodness_measure(Model, Results_opt)

Model.limit_state_label     = {'optimal', 'this paper expert judgement', 'EC 6.10', 'EC 6.10b'};
Model.limit_state_idx       = 1:4;

Results_cell = {Results_opt, Results_exp, Results_EC, Results_ECb}; 
plot_reli_comparison(Model, Results_cell)

%--------------------------------------------------------------------------
% SAVE
%--------------------------------------------------------------------------

if save_fig == 1
    prettify(gcf)
    ID = ['comparison_reli_vs_load_ratio',...
            '_gamma_Q_type.', gamma_Q_type,...
            '_gamma_Q_diff.', gamma_Q_diff,...
            '_load_combi.simple_t_ref.50_beta_t.', beta_target];
    fwidth = 30;
    fheight = 8;
    fpath = ['./figures/',ID];
    figuresize(fwidth , fheight , 'cm')
    export_fig(fpath, '-png', '-m2.5')
end

