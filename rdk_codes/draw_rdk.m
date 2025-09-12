function [dots] = draw_rdk(const,rdk,stimulusType)
% -------------------------------------------------------------------------
% draw_rdk(const,rdk,stimulusType)
% -------------------------------------------------------------------------
% Goal of the function :
% Draw random dot kinematogram stimulus masks (patches of randomly moving 
% dots), test item (patch with coherent motion), and distractor items 
% (patches of randomly moving dots).
% -------------------------------------------------------------------------
% Input(s) :
% const : general settings
% gabor : gabor stimulus specific settings
% stimulusType : 'target' or 'distractor' - determines which type of stimulus to create
% -------------------------------------------------------------------------
% Output(s):
% -
% -------------------------------------------------------------------------
% Function created by Nina M. Hanning (hanning.nina@gmail.com) 
% and Martin Szinte (martin.szinte@gmail.com)
% Last update : 09 / 04 / 2019
% Project :     StimtTest
% Version :     1.0
% -------------------------------------------------------------------------
% ADD THIS: Set dot color preference
% const.dotColorType = 'cyan';  % Options: 'cyan', 'pink', 'white', 'red', or 'mixed'
% If not specified, defaults to 'mixed'
if ~isfield(const, 'dotColorType')
    const.dotColorType = 'mixed';
end

% Check if stimulusType parameter is provided, if not default to creating all stimuli (original behavior)
if nargin < 3
    stimulusType = 2;
end

% signal direction
durBefSignal  = const.start_test_fr - 1;                                    % before the signal
durAftSignal  = size(const.end_test_fr+1:const.max_fr ,2);                  % after the signal
durDistractor = const.max_fr ;

% define matrix of distractor and test based on stimulusType parameter
if stimulusType == 1
    % Create only target stimulus
    dotSet.xyd              = [const.pos,rdk.rad*2];                   % x coord / y coord / diameter
    dotSet.durBef           = durBefSignal;
    dotSet.durAft           = durAftSignal;
    dotSet.dirS             = rdk.dirSignal;
    dotSet.kappaVal         = rdk.kappa;
    dots{1}                 = comp_randomDots1(const,dotSet);
elseif stimulusType == 0
    % Create only distractor stimulus
    dotSetDist.xyd          = [const.pos,rdk.rad*2];         % x coord / y coord / diameter (using first distractor position)
    dotSetDist.dur          = durDistractor;
    dots{1}                 = comp_randomDotsNoise(const,dotSetDist);
else

end

end
