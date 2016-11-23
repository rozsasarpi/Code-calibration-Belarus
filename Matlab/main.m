% Reliability-based partial factor calibration
%
%
% Model specification:
% - in main.m - scalar; those that are more likely to be changed, most important ones
% - in model_spec.m - nonscalar; those that are more likely to be changed, most important ones
% - in prob_model.m - very likely fixed, such as distribution types
%
%
% Structuring of main arrays:
% dim1 (height)     load ratio, khi = C_k*Q_k/(G_k + C_k*Q_k)
% dim2 (width)      limit state, [LS1, LS2, ...] format
% dim3 (depth)      lead action, [snow, imposed, wind] order is use
%
% Should be consistent:
%   model_spec.m
%   simple_gfun.m
%   prob_model.m
%
% ORDER IS IMPORTANT

clearvars
close all
clc

%==========================================================================
% OPTIONS & MODEL SPECIFICATION
%==========================================================================
Model.t_ref         = 50;

beta_target_50      = 3.8;
% % beta_target_1       = norminv(normcdf(beta_target_50)^(1/50));
% % beta_target_t_ref   = norminv(normcdf(beta_target_1)^(Model.t_ref));
% % Model.beta_target   = beta_target_t_ref;
Model.beta_target   = beta_target_50;

% Model.beta_target   = 2.3;
Model.obj_fun_type  = 'sym';
Model.load_combi    = 'simple'; % only 'simple' is implemented yet
Model.gamma_Q_type  = 'constant'; % for all variable actions!
% Model.gamma_Q_type       = 'linear'; % for all variable actions!
Model.gamma_Q_diff  = 'no'; % differentiate between gamma_Q for each variable action?

% see model_spec.m for explanation of indexing
Model.load_ratio_idx      = 1:9; % [0.1, 0.2, 0.3, 0.4, 0.5, 0.6, 0.7, 0.8, 0.9]
Model.limit_state_idx     = 1;   
Model.lead_action_idx     = 1:3; % [snow, imposed, wind]

% Model.limit_state_label   = {'bending', 'shear', 'buckling'};
Model.limit_state_label   = {'general'};

Model.P_rep = [0.98, 0.995, 0.98]; % Eurocode
% Model.P_rep = [0.95, 0.995, 0.80]; % SNiP
%==========================================================================
% Model specification & check
%==========================================================================

Model               = model_spec(Model);
Model               = model_check(Model);

%==========================================================================
% CALIBRATION
%==========================================================================

Results             = calibrate(Model)

%==========================================================================
% SAVE
%==========================================================================û

save(['results\',...
    'obj_fun.', Model.obj_fun_type,...
    '_gamma_Q_type.', Model.gamma_Q_type,...
    '_gamma_Q_diff.', Model.gamma_Q_diff,...
    '_load_combi.', Model.load_combi,...
    '_t_ref.', num2str(Model.t_ref),...
    '_beta_t.', num2str(Model.beta_target),...
    '_limit_state.', num2str(Model.limit_state_idx),...
    '_lead_action.', num2str(Model.lead_action_idx),...
    '.mat'],...
    'Model', 'Results')

%==========================================================================
% PLOT
%==========================================================================
plot_reli_vs_loadratio(Model, Results)

plot_multisolu_gamma(Model, Results)