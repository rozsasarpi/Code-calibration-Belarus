% Plot results

clearvars
close all
clc

obj_fun_type  = 'sym';
gamma_Q_type  = 'constant'; % for all variable actions!

%==========================================================================
% COMPARE VARIABLE ACTION DIFFERENTIATED PARTIAL FACTOR, GAMMA_Q
%==========================================================================
%--------------------------------------------------------------------------
% SINGLE GAMMA_Q 
%--------------------------------------------------------------------------
% load data
gamma_Q_diff  = 'no';

load(['results\obj_fun.',obj_fun_type,...
    '_gamma_Q_type.',gamma_Q_type,...
    '_gamma_Q_diff.',gamma_Q_diff,...
    '_load_combi.simple_t_ref.50_beta_t.2.3_limit_state.1_lead_action.1  2  3.mat'])

Results     = filter_Results(Results);
Results1    = select_Results(Model, Results, 0); % WARNING!

% khi = Model.khi;
% Rk1 = 

goodness_measure(Model, Results1)

% PLOT
plot_reli_vs_loadratio(Model, Results1, 'limit_state')

ha1         = gca;
ylim1       = get(ha1, 'Ylim');
hf1         = gcf;
hf          = get(gcf,'Children');
hl          = hf(1);
hl.Visible  = 'off';

disp('=====================================================================')
%--------------------------------------------------------------------------
% DISTINCT GAMMA_Q 
%--------------------------------------------------------------------------
% load data
% obj_fun_type  = 'asym';
gamma_Q_diff  = 'yes';

load(['results\obj_fun.',obj_fun_type,...
    '_gamma_Q_type.',gamma_Q_type,...
    '_gamma_Q_diff.',gamma_Q_diff,...
    '_load_combi.simple_t_ref.50_beta_t.2.3_limit_state.1_lead_action.1  2  3.mat'])

Results     = filter_Results(Results);
Results2    = select_Results(Model, Results, 0); % WARNING!

goodness_measure(Model, Results2)

% PLOT
plot_reli_vs_loadratio(Model, Results2, 'limit_state')

hf2         = gcf;
ha2         = gca;
ylim2       = get(ha2, 'Ylim');
% ylimm       = [min(ylim1(1), ylim2(1)), max(ylim1(2), ylim2(2))];
ylimm       = [1.97,    2.74];
set(ha1,'Ylim',ylimm)
set(ha2,'Ylim',ylimm)

% Objective function value
tx = min(xlim) + 0.05*diff(xlim);
ty = max(ylim) - 0.10*diff(ylim);

figure(hf1)
text(tx, ty, ['$O_\mathrm{',obj_fun_type,'}=', sprintf('%4.2f', Results1.obj_fun_val), '$'], 'Interpreter', 'LaTeX')
figure(hf2)
text(tx, ty, ['$O_\mathrm{',obj_fun_type,'}=', sprintf('%4.2f', Results2.obj_fun_val), '$'], 'Interpreter', 'LaTeX')

%--------------------------------------------------------------------------
% COMPARE required characteristic resistances!
%--------------------------------------------------------------------------
Options.title_text = 'single vs. distinct; constant; asym';
Options.model1     = 'single';
Options.model2     = 'distinct';

% Options.title_text = 'single; constant; sym vs. asym';
% Options.model1     = 'sym';
% Options.model2     = 'asym';

plot_rRk_vs_loadratio(Model, Results1, Results2, Options)

% ylim([-0.005    0.025])

