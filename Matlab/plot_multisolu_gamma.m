% Plot partial factors of multiple calibrated models (multiple optimum points)
%
%SYNOPSYS
% PLOT_MULTISOLU_GAMMA(Model, Results)
%

function plot_multisolu_gamma(Model, Results)

%==========================================================================
% INITIALIZATION
%==========================================================================
if ~isfield(Results, 'manymins')
    warning('No multiple solutions are available in Results structure!')
else

manymins    = Results.manymins;
gamma_label = Model.gamma_label;
n_solu      = length(manymins);
n_pf        = length(gamma_label);

PF          = reshape(cell2mat({manymins.X}),n_pf, n_solu).';

% sort accoring to first columnd while keeping the rows together
[B,I]       = sort(PF(:,1));
PF          = [B, PF(I,2:end)];

% sort manymins as well for convinience
manymins    = manymins(I);

O_val       = cell2mat({manymins.Fval}).';

%==========================================================================
%PLOT
%==========================================================================

figure('Position', [100, 300, (n_pf+1)*200, 200])
ymin = min(min(PF))-0.1;
ymax = max(max(PF))+0.1;

for ii = 1:n_pf
    subplot(1,n_pf+1,ii)
    bar(PF(:,ii))
%     bar(PF(:,ii), 'FaceColor', 'none') 
%     box off
    ht = title(['$\',gamma_label{ii},'$']);
    ht.Interpreter = 'LaTeX';
    ylim([ymin, ymax])
    xlim([0,n_solu+1])
    
    set(gca,'XTickLabel',[]) 
    set(gca,'TickLabelInterpreter', 'LaTeX')
    
end

subplot(1,n_pf+1,n_pf+1)
bar(O_val)
xlim([0,n_solu+1])

ht = title('$O_{val}$');
ht.Interpreter = 'LaTeX';
set(gca,'XTickLabel',[]) 
set(gca,'TickLabelInterpreter', 'LaTeX')

disp(gamma_label)
disp(PF)

end

end