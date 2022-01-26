% Plot reliabiliy index against load ratio for the different models
%
%SYNOPSYS
%
%
%INPUT
%
%OPTIONAL
%
%WARNING - it is way too particular
%

function plot_reli_comparison(Model, Results_cell) % I miss you ggplot2 ;(

%--------------------------------------------------------------------------
% PRE-PROCESS
%--------------------------------------------------------------------------
khi                 = Model.khi(:,1);
beta_target         = Model.beta_target;
lead_action_idx     = Model.lead_action_idx;
limit_state_idx     = Model.limit_state_idx;
nn                  = length(lead_action_idx);
mm                  = length(Results_cell);
lead_action         = Model.lead_action_label;
lead_action         = lead_action(lead_action_idx);
limit_state         = Model.limit_state_label;
limit_state         = limit_state(limit_state_idx);

beta                = nan(length(khi), mm, nn);
for ii = 1:mm
    beta(:,ii,:)                = Results_cell{ii}.beta;
end

title_text          = {'Snow', 'Imposed', 'Wind'};

min_beta            = min(min(min(beta)));
max_beta            = max(max(max(beta)));


partial_f_marker    = {'o', 's', '^', 'v'};
partial_f_marker    = partial_f_marker(1:mm);
%--------------------------------------------------------------------------
% VISUALIZE
%--------------------------------------------------------------------------

figure('Position', [100, 400, nn*400, 300]);
for ii = 1:nn
    subplot(1,nn,ii)
    for jj = 1:mm
        plot(khi, beta(:,jj,ii), '-', 'Marker', partial_f_marker{jj},...
            'MarkerFaceColor', [1,1,1])
        hold on
    end
    plot(khi, repmat(beta_target, size(khi)), '--', 'Color', 'red')
    ylabel('$\beta$', 'Interpreter', 'LaTeX')
    xlabel('$\chi = C_\mathrm{k} \cdot Q_\mathrm{k}/(G_\mathrm{k} + C_\mathrm{k} \cdot Q_\mathrm{k})$', 'Interpreter', 'LaTeX')
    
    % ht = title(['leading action:', num2str(lead_action_idx(ii))]);
    % ht = title(['leading action: ', lead_action{ii}]);
    ht = title(title_text{ii});
    ht.Interpreter = 'LaTeX';
    if ii == 2
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
    set(gca,'XTick', 0.1:0.1:0.9) % WARNING!
    
    set(gca,'TickLabelInterpreter', 'LaTeX')
end

end