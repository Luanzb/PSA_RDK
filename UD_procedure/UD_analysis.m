
function UD_analysis(UD,UD2,trl, time)

%% Parameters

numReversalsForThreshold = 5;  % Use last 5 reversals for threshold

fprintf('\n=== STAIRCASE COMPLETE - GREEN COLOR ===\n');
fprintf('Total trials: %d\n', length(UD.x));

% Convert all values back to linear space
allKvalues = 10.^UD.x;

% Find all reversals
reversalIndices = find(UD.reversal);

numReversals = length(reversalIndices);
fprintf('Total number of reversals: %d\n', numReversals);

% Calculate threshold from last N reversals
if numReversals >= numReversalsForThreshold
    lastNreversalIndices = reversalIndices(end - numReversalsForThreshold + 1:end);
    lastNreversalValues = allKvalues(lastNreversalIndices);
    thresholdK = mean(lastNreversalValues);

else
    fprintf('Warning: Not enough reversals for threshold estimation\n');
     thresholdK = NaN;
end

color = trl.dotcolor1;
% Plot results
plotStaircaseResults(allKvalues, UD.response, reversalIndices, ...
    time.switchTrial, thresholdK,color);


%% Parameters

numReversalsForThreshold = 5;  % Use last 5 reversals for threshold

fprintf('\n=== STAIRCASE COMPLETE - RED COLOR ===\n');
fprintf('Total trials: %d\n', length(UD2.x));

% Convert all values back to linear space
allKvalues = 10.^UD2.x;

% Find all reversals
reversalIndices = find(UD2.reversal);

numReversals = length(reversalIndices);
fprintf('Total number of reversals: %d\n', numReversals);

% Calculate threshold from last N reversals
if numReversals >= numReversalsForThreshold
    lastNreversalIndices = reversalIndices(end - numReversalsForThreshold + 1:end);
    lastNreversalValues = allKvalues(lastNreversalIndices);
    thresholdK = mean(lastNreversalValues);

else
    fprintf('Warning: Not enough reversals for threshold estimation\n');
     thresholdK = NaN;
end

color = trl.dotcolor2;
% Plot results
plotStaircaseResults(allKvalues, UD2.response, reversalIndices, ...
    time.switchTrial2, thresholdK,color);
end
