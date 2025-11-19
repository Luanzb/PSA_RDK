function plotStaircaseResults(allKvalues, allResponses, reversalIndices, ...
    switchTrial, thresholdK,color)
trialCount = length(allKvalues);
t = 1:trialCount;
figure( 'Name', 'Staircase Results -GREEN');
set(gca,'TickDir','out');
set(gca,'color', [.7 .7 .7]);
hold on;

% Set log scale FIRST
set(gca, 'YScale', 'log');

% Plot horizontal grid lines first (underneath everything)
yline([40:10:100], 'k', 'LineWidth', .7, 'HandleVisibility', 'off');

% Plot K values
plot(t, allKvalues, 'k-', 'LineWidth', 1.2, 'HandleVisibility', 'off');

% Mark correct (filled) and incorrect (empty) responses
correctTrials = t(allResponses == 1);
incorrectTrials = t(allResponses == 0);
plot(correctTrials, allKvalues(correctTrials), 'ko', ...
'MarkerFaceColor', 'k', 'MarkerSize', 6,'LineWidth', 1.3);
plot(incorrectTrials, allKvalues(incorrectTrials), 'ko', ...
'MarkerFaceColor', 'w', 'MarkerSize', 6,'LineWidth', 1.3);

% Mark reversals
if ~isempty(reversalIndices)
    plot(reversalIndices, allKvalues(reversalIndices), 'ko', ...
'MarkerEdgeColor', 'y', ...
'MarkerSize', 6, 'LineWidth', 1.3);
end

% Mark phase switch
if switchTrial > 0
    xline(switchTrial, 'b--', 'LineWidth', 2, ...
'Label', 'Switch to 1up/2down', 'LabelOrientation', 'horizontal');
end

% Add threshold line
if ~isnan(thresholdK)
    yline(thresholdK, 'Color',color,'LineStyle','--', 'LineWidth', 2, ...
'Label', sprintf('Threshold: %.2f', thresholdK), ...
'LabelHorizontalAlignment', 'left');
end

ylabel('Saturation value', 'FontSize', 12);
xlabel('Trial Number', 'FontSize', 12);
title(sprintf('Transformed 1up/2down (%d reversals)', ...
    length(reversalIndices)), 'FontSize', 14, 'FontWeight', 'bold');
legend('Infos',{'Correct', 'Incorrect', 'Reversals'}, 'Location', 'northeast','Box','off');

% Set axis limits (x-axis and y-axis together)
axis([0 trialCount+1 min(allKvalues)*0.8 max(allKvalues)*1.2]);

% Manually set y-axis ticks to show linear numbers
yticks([40 50 60 70 80 90 100]);
yticklabels({'40', '50', '60', '70', '80', '90', '100'});

end


