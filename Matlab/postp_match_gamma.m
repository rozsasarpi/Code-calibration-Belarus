clearvars
close all
clc

beta_target   = '3.8';
t_ref         = '50';
pf            = [1.05, 1.15]; % WARNING!
pf_idx        = [4, 5];



% beta_target   = '2.3';
% t_ref         = '50';
% pf            = [1.5]; % WARNING!
% pf_idx        = [1];
% pf            = [1.5, 1.35, 1.0]; % WARNING!
% pf            = [1.10, 1.26]; % WARNING!
% pf_idx        = [1, 2, 3];
% pf            = [1.5, 1.5, 1.5, 1.35, 1.00]; % WARNING!
% pf_idx        = 1:5;


obj_fun_type  = 'sym';
gamma_Q_type  = 'constant'; % for all variable actions!

gamma_Q_diff  = 'yes';

% load data
file_name = ['obj_fun.',obj_fun_type,...
    '_gamma_Q_type.',gamma_Q_type,...
    '_gamma_Q_diff.',gamma_Q_diff,...
    '_load_combi.simple_t_ref.',t_ref...
    '_beta_t.',beta_target,...
    '_limit_state.1_lead_action.1  2  3.mat'];

load(['results\',file_name])

Results             = filter_Results(Results);
[Results, PF]       = select_Results(Model, Results, pf_idx, pf); % WARNING!

save(['results\toR\',file_name], 'PF')
% khi = Model.khi;
% Rk1 = 

goodness_measure(Model, Results)

%--------------------------------------------------------------------------
% with partial factors based on expert judgement
%##########################################################################
% partial_f = [1.30, 1.30, 1.15, 1.05, 1.15];
% partial_f = [1.50, 1.00, 1.30, 1.05, 1.15];

partial_f = [2.40, 1.60, 2.10, 1.05, 1.25];
% partial_f = [2.10, 2.10, 1.90, 1.05, 1.25];
%##########################################################################
Results2 = calibrate(Model, partial_f); % no calibration only calculates the betas at the given set of partial factors

Results2.partial_f
goodness_measure(Model, Results2)