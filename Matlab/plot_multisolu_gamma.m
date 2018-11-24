% Plot partial factors of multiple calibrated models (multiple optimum points)
%
%SYNOPSYS
% PLOT_MULTISOLU_GAMMA(Model, Results)
%

function plot_multisolu_gamma(Model, Results, pf, pf_idx)
% close all

if nargin < 4
   pf_idx = 1.5; 
end
if nargin < 3
   pf = 1.5; 
end
% 
% pf          = 1.5;
% % pf          = 2.0;
% pf_idx      = 1;

%==========================================================================
% PRE-PROCESSING
%==========================================================================
if ~isfield(Results, 'manymins')
    warning('No multiple solutions are available in Results structure!')
else
    
Results     = filter_Results(Results);
% select the result with gamma_S closest to 1.5
Results2    = select_Results(Model, Results, pf_idx, pf);
   
manymins    = Results.manymins;
gamma_label = Model.gamma_label;
gamma_label{end} = 'gamma_M';
n_solu      = length(manymins);
n_pf        = length(gamma_label);

PF          = reshape(cell2mat({manymins.X}),n_pf, n_solu).';

% sort accoring to first columnd while keeping the rows together
[B,I]       = sort(PF(:,1));
PF          = [B, PF(I,2:end)];

% sort manymins as well for convinience
manymins    = manymins(I);

O_val       = cell2mat({manymins.Fval}).';

idx         = find(PF(:,1)==Results2.partial_f(1)); 


%==========================================================================
%PLOT
%==========================================================================

%--------------------------------------------------------------------------
% For evaluation, check
%--------------------------------------------------------------------------
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

%--------------------------------------------------------------------------
% For publication
%--------------------------------------------------------------------------
% PLOT CONFIG
%....................
left_marg   = 0.05;
right_marg  = 0.01;
bot_marg    = 0.02;
top_marg    = 0.07;
gap_v       = 0.05;
gap_h       = 0.02;
%....................
n_col       = n_pf;
n_row       = 1;

cc          = 1:n_col;
rr          = 1:n_row;

H           = (1-((n_row-1)*gap_v+bot_marg+top_marg))/n_row;
W           = (1-((n_col-1)*gap_h+left_marg+right_marg))/n_col;

L           = repmat(left_marg+(cc-1)*W+(cc-1)*gap_h, n_row, 1);
B           = repmat(bot_marg+(rr-1)*H+(rr-1)*gap_v, 1, n_col);


figure('Position', [100, 300, (n_col)*150, 150])
% ymin = min(min(PF))-0.1;
% ymax = max(max(PF))+0.1;
ymin = 0.8; % WARNING!
ymax = 2.8;

for ii = 1:n_col
    subplot('Position', [L(ii), B(ii), W, H]);
    bar(PF(:,ii), 'FaceColor', 0.8*[1,1,1], 'EdgeColor', 'none')
    hold on
    bar(idx, PF(idx,ii), 'FaceColor', 0.5*[1,1,1], 'EdgeColor', 'none')
%     bar(PF(:,ii), 'FaceColor', 'none') 
    box off
    
    ht = title(['$\',gamma_label{ii},'$']);
    ht.Interpreter = 'LaTeX';
    ylim([ymin, ymax])
    xlim([0,n_solu+1])
    
    if ii ~= 1
        set(gca, 'YTickLabel', [])
    else
        ylabel('Partial factor, $\gamma$', 'Interpreter', 'LaTeX')
    end
    
    % draw guides to indicate values
    set(gca, 'XTick',[])
    Line.layer = 'top';
    Line.color = [1, 1, 1];
    plot_guides(gca, Line)

    % 'hide' bring axes
    set(gca, 'Layer','bottom')
    
    ax = gca;
    ax.XColor = 0.8*[1,1,1];
    
    yminmax = ylim;
    xminmax = xlim;
    
    % make y axis 'invisible'
    hl = plot(xminmax(1)*ones(1,2), yminmax, 'Color', ones(1,3), 'LineWidth', 1.5);
    uistack(hl,'top')
    
    set(gca,'XTickLabel',[]) 
    set(gca,'TickLabelInterpreter', 'LaTeX')
    
end

set(gca,'XTickLabel',[]) 
set(gca,'TickLabelInterpreter', 'LaTeX')


%--------------------------------------------------------------------------
% POST-PROCESS
%--------------------------------------------------------------------------
S = mean(PF(:,1:3),2) + sum(PF(:,4:end),2);

disp(gamma_label)
disp([PF, S])

end

end