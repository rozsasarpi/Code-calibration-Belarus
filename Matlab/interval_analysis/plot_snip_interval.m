clearvars
close all
clc

load('snip_1.5.mat', 'khi', 'beta_int', 'beta_mid', 'Model')
beta_int1 = beta_int;
beta_mid1 = beta_mid;

load('snip_1.6.mat', 'khi', 'beta_int', 'beta_mid', 'Model')
beta_int2 = beta_int;
beta_mid2 = beta_mid;

khi_split = 0.58;
idx1 = 5;
idx2 = 6;


lead_action_idx     = [1, 2, 3];
n_lead_action       = length(lead_action_idx);

cmp                 = get(groot,'defaultAxesColorOrder');
lead_action_marker  = {'o', 's', '^'};
lead_action_marker  = lead_action_marker(lead_action_idx);
lead_action_label   = Model.lead_action_label;

% not general, ad hoc solution
figure('Position', [100, 400, n_lead_action*400, 300])
for ii = 1:n_lead_action
    subplot(1,n_lead_action,ii)
    
    % split figure
    
    btmp    = beta_int1(:,:,ii);
    tmp     = interp1(khi, btmp, khi_split);
    bi      = [btmp(1:idx1,:); tmp];
    bim     = btmp(1:idx1,:);
    
    btmp    = beta_mid1(:,:,ii);
    tmp     = interp1(khi, btmp, khi_split);
    bm      = [btmp(1:idx1,:); tmp];
    
    bt      = Model.beta_target;
    khiss   = [khi(1:idx1); khi_split];
    khissm  = khi(1:idx1);
    
    fill([khiss; flipud(khiss)], [bi(:,1); flipud(bi(:,2))], cmp(ii,:), 'FaceAlpha', 0.3, 'EdgeColor', 'none')
%     fill([khi; flipud(khi)], bi(:), repmat(cmp(ii,:),18,1))
    hold on
    plot(khiss, bi, '-','Color', cmp(ii,:))
    plot(khissm, bim, 'Marker', lead_action_marker{ii},...
                    'MarkerFaceColor', [1,1,1],...
                    'Color', cmp(ii,:),...
                    'MarkerSize', 4)
                
    plot(khiss, bm, 'w--', 'Linewidth', 2)
    hf = plot(khiss, repmat(bt, size(khiss)), 'r--');
    
    % second branch
    btmp    = beta_int2(:,:,ii);
    tmp     = interp1(khi, btmp, khi_split);
    bi      = [tmp; btmp(idx2:end,:)];
    bim     = btmp(idx2:end,:);
    
    btmp    = beta_mid2(:,:,ii);
    tmp     = interp1(khi, btmp, khi_split);
    bm      = [tmp; btmp(idx2:end,:)];
    
    bt      = Model.beta_target;
    khiss   = [khi_split; khi(idx2:end,:), ];
    khissm  = khi(idx2:end);
    
    fill([khiss; flipud(khiss)], [bi(:,1); flipud(bi(:,2))], cmp(ii,:), 'FaceAlpha', 0.3, 'EdgeColor', 'none')
%     fill([khi; flipud(khi)], bi(:), repmat(cmp(ii,:),18,1))
    hold on
    plot(khiss, bi, '-','Color', cmp(ii,:))
    plot(khissm, bim, 'Marker', lead_action_marker{ii},...
                    'MarkerFaceColor', [1,1,1],...
                    'Color', cmp(ii,:),...
                    'MarkerSize', 4)
    
    plot(khiss, bm, 'w--', 'Linewidth', 2)
    hf = plot(khiss, repmat(bt, size(khiss)), 'r--');
    
    
    if ii == n_lead_action
        hl = legend(hf, {'$\beta_\mathrm{target}$'});
        hl.Interpreter = 'LaTeX';
        hl.Location = 'best';
    end
    ht = title(lead_action_label{ii});
    ht.Interpreter = 'LaTeX';
    ylim([0, max(max(max(beta_int)))*1.05])
    xlim([0.1, 0.9])
    set(gca, 'XTick', khi(1:2:end))
%     set(gca, 'XTick', [khi(1); khi(2:2:end); khi(end)])
%     set(gca, 'XTickLabel', khi)
    ylabel('$\beta$', 'Interpreter', 'LaTeX')
    xlabel('$\chi = C_\mathrm{k} \cdot Q_\mathrm{k}/(G_\mathrm{k} + C_\mathrm{k} \cdot Q_\mathrm{k})$', 'Interpreter', 'LaTeX')
    set(gca,'TickLabelInterpreter', 'LaTeX')
end

