% Plot ratio of required characteristic resistance against load ratio for the calibrated models
%
%SYNOPSYS
% PLOT_RRK_VS_LOADRATIO(Model1, Results1, Model2, Results2)
%
%INPUT
% 
%
% (R_k2 - R_k1)./R_k1
% assuming that basic inputs, dimensions are the same in Model1 and Model2

function plot_rRk_vs_loadratio(Model, Results1, Results2)


khi                 = Model.khi(:,1);
R_k1                = Results1.R_k;
R_k2                = Results2.R_k;

lead_action_idx     = Model.lead_action_idx;
limit_state_idx     = Model.limit_state_idx;
n_lead_action       = length(lead_action_idx);
n_limit_state       = length(limit_state_idx);

lead_action         = Model.lead_action_label;
lead_action         = lead_action(lead_action_idx);
limit_state         = Model.limit_state_label;
limit_state         = limit_state(limit_state_idx);

rR_k                = (R_k2 - R_k1)./R_k1;    

min_rR_k            = min(min(min(rR_k)));
max_rR_k            = max(max(max(rR_k)));
% maby it should be moved to separate functions, especially if more options are added
group_by = 'limit_state';
switch lower(group_by)
    
    case {'limit_state', 'limit state', 'ls'}
        lead_action_marker = {'o', 's', '^'};
        lead_action_marker  = lead_action_marker(lead_action_idx);
        
        figure('Position', [100, 400, n_limit_state*400, 300])
        for ii = 1:n_limit_state
            subplot(1,n_limit_state,ii)
            for jj = 1:n_lead_action
                plot(khi, rR_k(:,ii,jj), '-', 'Marker', lead_action_marker{jj},...
                    'MarkerFaceColor', [1,1,1])
                hold on
            end
            plot(khi, zeros(size(khi)), '--black')
            
            ylabel('$(R_\mathrm{k,distinct}-R_\mathrm{k,single})/R_\mathrm{k,single}$', 'Interpreter', 'LaTeX')
            xlabel('$\chi = C_\mathrm{k} \cdot Q_\mathrm{k}/(G_\mathrm{k} + C_\mathrm{k} \cdot Q_\mathrm{k})$', 'Interpreter', 'LaTeX')

            ht = title(['limit state: ', limit_state{ii}]);
            ht.Interpreter = 'LaTeX';
            if ii == n_limit_state
                %     legend_label = cellstr(num2str(Model.limit_state_idx(:)));
                legend_label = lead_action;
                hl = legend(legend_label);
                hl.Interpreter = 'LaTeX';
                hl.Location = 'best';
%                 hl.Location = 'SouthWest';
%                 hl.Location = 'NorthEast';
            end
            ylim([min_rR_k - 0.1*(max_rR_k-min_rR_k), max_rR_k + 0.1*(max_rR_k-min_rR_k)])
            xlim([min(khi), max(khi)])
            set(gca,'XTick',0.1:0.1:0.9) % WARNING!
            
            set(gca,'TickLabelInterpreter', 'LaTeX')
        end
        
    case {'leading action', 'lead action', 'leading_action', 'lead_action', 'la'}
        
        % to be implemented
        
    otherwise
        error(['Unknown grouping definition type: ', group_by])
end



end