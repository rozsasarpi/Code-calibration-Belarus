
clearvars
close all
clc

obj_fun_type  = 'sym';
gamma_Q_type  = 'constant'; % for all variable actions!
gamma_Q_diff  = 'yes';


% load data
load(['results\obj_fun.',obj_fun_type,...
    '_gamma_Q_type.',gamma_Q_type,...
    '_gamma_Q_diff.',gamma_Q_diff,...
    '_load_combi.simple_t_ref.50_beta_t.2.3_limit_state.1_lead_action.1  2  3.mat'])

%--------------------------------------------------------------------------
% with calibrated partial factors
Results.partial_f
goodness_measure(Model, Results)

%--------------------------------------------------------------------------
% with partial factors based on expert judgement
%##########################################################################
partial_f = [1.50, 1.50, 1.30, 1.00, 1.20];
%##########################################################################
Results2 = calibrate(Model, partial_f); % no calibration only calculates the betas at the given set of partial factors

Results2.partial_f
goodness_measure(Model, Results2)

