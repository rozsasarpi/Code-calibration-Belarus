% Plot reliabiliy index against load ratio for the calibrated model
%
%SYNOPSYS
% PLOT_RELI_VS_LOADRATIO(Model, Results)
%
%INPUT
%
%OPTIONAL
% group_by      'limit_state', 'lead_action', '
%
%

function plot_reli_vs_loadratio(Model, Results, group_by) % I miss you ggplot2 ;(

if nargin < 3
    group_by = 'limit_state';
end

khi                 = Model.khi(:,1);
beta                = Results.beta;
beta_target         = Model.beta_target;
lead_action_idx     = Model.lead_action_idx;
limit_state_idx     = Model.limit_state_idx;
nn                  = length(lead_action_idx);
mm                  = length(limit_state_idx);
lead_action         = Model.lead_action_label;
lead_action         = lead_action(lead_action_idx);
limit_state         = Model.limit_state_label;
limit_state         = limit_state(limit_state_idx);

min_beta            = min(min(min(beta)));
max_beta            = max(max(max(beta)));
% maby it should be moved to separate functions, especially if more options are added
switch lower(group_by)
    
    case {'limit_state', 'limit state', 'ls'}
        lead_action_marker = {'o', 's', '^'};
        lead_action_marker  = lead_action_marker(lead_action_idx);
        
        figure('Position', [100, 400, mm*400, 300])
        for ii = 1:mm
            subplot(1,mm,ii)
            for jj = 1:nn
                plot(khi, beta(:,ii,jj), '-', 'Marker', lead_action_marker{jj},...
                    'MarkerFaceColor', [1,1,1])
                hold on
            end
            plot(khi, repmat(beta_target, size(khi)), '--', 'Color', 'red')
            ylabel('$\beta$', 'Interpreter', 'LaTeX')
            xlabel('$\chi = C_\mathrm{k} \cdot Q_\mathrm{k}/(G_\mathrm{k} + C_\mathrm{k} \cdot Q_\mathrm{k})$', 'Interpreter', 'LaTeX')
            
            %   ht = title(['leading action:', num2str(lead_action_idx(ii))]);
            ht = title(['limit state: ', limit_state{ii}]);
            ht.Interpreter = 'LaTeX';
            if ii == mm
                %     legend_label = cellstr(num2str(Model.limit_state_idx(:)));
                legend_label = lead_action;
                legend_label{end+1} = '$\beta_\mathrm{target}$';
                hl = legend(legend_label);
                hl.Interpreter = 'LaTeX';
                % hl.Location = 'best';
%                 hl.Location = 'SouthWest';
                hl.Location = 'NorthEast';
            end
            ylim([min_beta - 0.1*(max_beta-min_beta), max_beta + 0.1*(max_beta-min_beta)])
            xlim([min(khi), max(khi)])
            set(gca,'XTick',0.1:0.1:0.9) % WARNING!
            
            set(gca,'TickLabelInterpreter', 'LaTeX')
        end
        
    case {'leading action', 'lead action', 'leading_action', 'lead_action', 'la'}
        limit_state_marker  = {'o', 's', '^'};
        limit_state_marker  = limit_state_marker(limit_state_idx);
        
        figure('Position', [100, 400, nn*400, 300]);
        for ii = 1:nn
            subplot(1,nn,ii)
            for jj = 1:mm
                plot(khi, beta(:,jj,ii), '-', 'Marker', limit_state_marker{jj},...
                    'MarkerFaceColor', [1,1,1])
                hold on
            end
            plot(khi, repmat(beta_target, size(khi)), '--', 'Color', 'red')
            ylabel('$\beta$', 'Interpreter', 'LaTeX')
            xlabel('$\chi = C_\mathrm{k} \cdot Q_\mathrm{k}/(G_\mathrm{k} + C_\mathrm{k} \cdot Q_\mathrm{k})$', 'Interpreter', 'LaTeX')
            
            %   ht = title(['leading action:', num2str(lead_action_idx(ii))]);
            ht = title(['leading action: ', lead_action{ii}]);
            ht.Interpreter = 'LaTeX';
            if ii == nn
                %     legend_label = cellstr(num2str(Model.limit_state_idx(:)));
                legend_label = limit_state;
                legend_label{end+1} = '$\beta_\mathrm{target}$';
                hl = legend(legend_label);
                hl.Interpreter = 'LaTeX';
                %                 hl.Location = 'best';
                hl.Location = 'SouthWest';
            end
            ylim([min_beta - 0.1*(max_beta-min_beta), max_beta + 0.1*(max_beta-min_beta)])
            xlim([min(khi), max(khi)])
            set(gca,'XTick',0.1:0.1:0.9) % WARNING!
            
            set(gca,'TickLabelInterpreter', 'LaTeX')
        end
        
    otherwise
        error(['Unknown grouping definition type: ', group_by])
end

% if strncmpi(Model.gamma_Q_type, 'l',1)
%     figure
%     yy = Results.partial_f(1) + khi*Results.partial_f(2);
%     plot(khi, yy)
% end


end