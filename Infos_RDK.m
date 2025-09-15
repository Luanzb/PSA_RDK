
git_path = 'C:/Users/activ/OneDrive/Documentos/GitHub/PSA_RDK';
addpath(genpath(git_path));

pc_path = 'C:/Users/activ/OneDrive/Documentos/Projects/PSA_RDK';
addpath(genpath(pc_path));


% Ask subject number
answer = inputdlg({'Numero voluntario'}, '', [1 25]);
sub.id = answer{1}; sub.id_num = str2double(answer{1});

%% INFORMAÇÕES SOBRE O TECLADO
KbName('UnifyKeyNames');
info.escapeKey = KbName('ESCAPE');
info.leftKey = KbName('LeftArrow');
info.rightKey = KbName('RightArrow');
info.uparrow = KbName('UpArrow');
info.downarrow = KbName('DownArrow');
info.s         = KbName('S');
info.n         = KbName('N');
info.return = KbName('return');

%% Screen setup
Screen('Preference', 'SyncTestSettings', 0.01, 50, 0.25);
Screen('Preference', 'SuppressAllWarnings', 1);
Screen('Preference', 'Verbosity', 0);
Screen('Preference', 'SkipSyncTests', 1);

% Seed the random number generator. Here we use an older way to be
% compatible with older systems.
rng('shuffle')

screens = Screen('Screens');% Get the screen numbers.
info.scr_num = screens(3);% draw to the externalscreen.

% Define black and white (white== 1 and black, 0).
info.white_idx = WhiteIndex(info.scr_num);
info.black_idx = BlackIndex(info.scr_num);
info.gray_idx = info.white_idx/2;

% Open an screen window
[win, info.scr_rect] = PsychImaging('OpenWindow', info.scr_num, info.black_idx, [], 32, 2, [], []); % RODA EM TELA TODA

% Inter-flip interval
info.scr_ifi = Screen('GetFlipInterval', win);

sca; clc;

%% Get the size of the screen window in pixels

[scr_xsize_mm, scr_ysize_mm] = Screen('DisplaySize', info.scr_num);
info.scr_xsize_cm = scr_xsize_mm/10;
info.scr_ysize_cm = scr_ysize_mm/10;

% Screen size in pixels
%or, by:[scrX,scrY] = Screen('WindowSize',info.scr_num); % in  pixels
info.scr_xsize = info.scr_rect(3);
info.scr_ysize = info.scr_rect(4);

% Centre coordinate of the window
[info.scr_xcenter, info.scr_ycenter] = RectCenter(info.scr_rect); % in pixels
info.scr_rrate = round(1/info.scr_ifi);     % Refresh rate
info.scr_dist_cm = 57;          % Viewing distance from screen (cm)

%% Infos Fixation Dot
info.fp_size_dva = 0.3;        % fixation Dot diameter
info.fp_size_pix = round(dva2pix(info.scr_dist_cm, info.scr_xsize_cm, info.scr_xsize, info.fp_size_dva));

%% Infos Saccade_Cue
info.cue_width_dva = 0.15; % saccade cue width in dva
info.cue_length_dva = 0.7; % saccade cue length in dva

info.cue_width_px = round(dva2pix(info.scr_dist_cm, info.scr_xsize_cm, info.scr_xsize, info.cue_width_dva));% saccade cue width converted to pixels
info.cue_length_px = round(dva2pix(info.scr_dist_cm, info.scr_xsize_cm, info.scr_xsize, info.cue_length_dva)); % saccade cue length converted to pixels

%% Tamanho, velocidade e Posicoes dos RDK

% tamnho do estimulo RDK
RDK.size_dva = 5;
RDK.size_pix = dva2pix(info.scr_dist_cm,info.scr_xsize_cm,info.scr_xsize,RDK.size_dva);
% tamanho dos pontos do RDK
RDK.size_dot_dva = .17;
RDK.size_dot_pix = dva2pix(info.scr_dist_cm,info.scr_xsize_cm,info.scr_xsize,RDK.size_dot_dva);

% velocidade de movimento dos pontos por segundo. uma velocidade de 5 dva,
% equvale a um deslocamento de XX pixels por segundo.
RDK.speed_dot = 3; % 5
RDK.speed_dot_pix = dva2pix(info.scr_dist_cm,info.scr_xsize_cm,info.scr_xsize,RDK.speed_dot);

% RDK Eccentricity
RDK.EccDVA = 8;
RDK.Ecc = round(dva2pix(info.scr_dist_cm,info.scr_xsize_cm,info.scr_xsize,RDK.EccDVA));

% RDK coordinates on the left and right side from FP
RDK.coordL = [info.scr_xcenter-RDK.Ecc info.scr_ycenter];
RDK.coordR = [info.scr_xcenter+RDK.Ecc info.scr_ycenter];

% Random dot kinematograms
RDK.rad         = RDK.size_pix/2;               % item radius
%RDK.dirSignal   = 45;                % test item motion direction (0:right, 90:up, 180:left, 270:down)
%RDK.kappa       = 100;               % test item motion coherence
const.stimRad   = RDK.rad;          % item size

%% Color RDKs
% filled dot
RDK.dottype = 2;

% dotcolor1 = rgb2lab([0 1 0]);
% dotcolor1(1,1) = 54;
RDK.dotcolor1a = [88 198 219]/255;  % lab2rgb(dotcolor1); % Green

% dotcolor2 = rgb2lab([1 0 0]);
% dotcolor2(1,1) = 54;
RDK.dotcolor2a = [255 120 200]/255;  % lab2rgb(dotcolor2); % Red

%% General settings
% Ajust screen size and specify item positions and trial timing
% space between stimuli

const.pos = [960 540]; % it will be changed to the right and left side.

% Temporal configurations
trl.trial_dur_t = 1.4;                        % trial duration (in seconds)
const.frame_dur = 1/60;                     % frame duration in seconds (e.g. 1/60 for screen refresh rate of 60 Hz)

% Trial timing (in frames)
RDK.test_dur_t      = 0.2;              % test presentation duration (seconds)
const.start_fr       = 1;                                                           % trial start
const.test_dur_fr    = round(RDK.test_dur_t/const.frame_dur);                       % test presentation duration
const.max_fr         = round(trl.trial_dur_t/const.frame_dur);  

% See genVonMisesDotInfo for details
const.dotRadSize = RDK.size_dot_pix;   %%%% GOOD PROXY? %%%
const.theta_noise = 90;
const.kappa_noise = 0;

const.numDots = 25;
const.dotSpeed_pix = RDK.speed_dot_pix;   % dot speed [pix/dec] %%%% GOOD PROXY? %%%
const.sigDotSpeedMulti = 3; % acceleration (put 1 for without)

const.durMinLife = 0.166;           const.numMinLife = (round(const.durMinLife/const.frame_dur));
const.numMeanLife = 0.300;          const.numMeanLife = (round(const.numMeanLife/const.frame_dur));

%% Define circle parameters (dashed circle around the RDK)

circle1.ecc_dva = RDK.EccDVA; % 8 degrees of visual angle
circle1.rad_dva = 2.6;     % 4 degrees of visual angle

% Convert DVA to pixels
circle1.ecc_pix = dva2pix(info.scr_dist_cm,info.scr_xsize_cm,info.scr_xsize,circle1.ecc_dva);
circle1.rad_pix = dva2pix(info.scr_dist_cm,info.scr_xsize_cm,info.scr_xsize,circle1.rad_dva);


% Calculate circle positions
circle1.leftCirclePos = [info.scr_xcenter - circle1.ecc_pix, info.scr_ycenter];
circle1.rightCirclePos = [info.scr_xcenter + circle1.ecc_pix, info.scr_ycenter];

% Set circle properties
circle1.Color = [1 1 1]; % White
circle1.lineWidth = 2; % Line width in pixels
circle1.linegap = 3;

%% Matrix of trials
%  Congruent Saccade (CS),Incongruent Saccade (IS), Congruent Color (CC)
%  and Incongruent Color (IC)

% 1 = CS + CC
% 2 = IS + CC
% 3 = CS + IC
% 4 = IS + IC

%  Conditions   Feature   Cue Congruency  Cue Side  Targ Side  Targ Ori  Catch Trials   Training
%-----------------------------------------------------------------------------------------------
%    1:4        1=Green   1=Congruent     1=Left    1=Left     1=UP      1=Catch       1=training
%               2=Red     2=Incongruent   2=Right   2=Right    2=DOWN   0=NoCatch     0=notraining

info.ntrials = 840;

conditions = [repelem(1,144) repelem(2,144) repelem(3,36) repelem(4,36)]';
feature = [repelem(1,288) repelem(2,72)]';
cue_congruency = [repelem(1,144) repelem(2,144) repelem(1,36) repelem(2,36)]';
cue_side =  [repmat([repelem(1,72) repelem(2,72)]',2,1)' repmat([repelem(1,18) repelem(2,18)]',2,1)']';

% Target side
% - When cue_congruency = 1 (congruent): target_side = cue_side
% - When cue_congruency = 2 (incongruent): target_side = opposite of cue_side
% The expression 3 - cue_side flips between 1 and 2 (since 3-1=2 and 3-2=1)
target_side = zeros(size(cue_congruency));
congruent_cue = (cue_congruency == 1);
target_side(congruent_cue) = cue_side(congruent_cue);
target_side(~congruent_cue) = 3 - cue_side(~congruent_cue);

target_ori = [repmat([repelem(1,36) repelem(2,36)]',4,1)' repmat([repelem(1,9) repelem(2,9)]',4,1)']';
catch_trl = [Shuffle([repelem(1,57) repelem(0,231)])'; Shuffle([repelem(1,14) repelem(0,58)])'];

matrix_v1 = [conditions feature cue_congruency cue_side target_side target_ori catch_trl];

matrix_v1 = [matrix_v1; matrix_v1];

if rem(sub.id_num,2) == 1
    trl.feature_ses(:,1) = [repelem(1,288) repelem(2,72) repelem(2,288) repelem(1,72)]'; % session 1
    trl.feature_ses(:,2) = [repelem(2,288) repelem(1,72) repelem(1,288) repelem(2,72)]'; % session 2
else
    trl.feature_ses(:,1) = [repelem(2,288) repelem(1,72) repelem(1,288) repelem(2,72)]'; % session 1
    trl.feature_ses(:,2) = [repelem(1,288) repelem(2,72) repelem(2,288) repelem(1,72)]'; % session 2
end

%%
% create matrix of trials for each session, as well as timings for cue and
% target appearance and target orientation.

for session = 1:2

    matrix_v1(:,2)   = trl.feature_ses(:,session);

    % Randomize trials separetly for saccade and neutral conditions.
    matrix_v1(1:360,:)   = Shuffle(matrix_v1(1:360,:),2);     % session part 1
    matrix_v1(361:720,:)   = Shuffle(matrix_v1(361:720,:),2); % session part 2


    % code related to training blocks at the beginning of each session
    % part. That is, before each most probable color.

    mat_trng1 = Shuffle(matrix_v1(1:30,:),2);
    mat_trng2 = Shuffle(matrix_v1(331:360,:),2);
    mat_trng3 = Shuffle(matrix_v1(361:390,:),2);
    mat_trng4 = Shuffle(matrix_v1(691:720,:),2);


    mat_trng11 = Shuffle([mat_trng1; mat_trng2],2);
    mat_trng22 = Shuffle([mat_trng3; mat_trng4],2);

    info.matrix = [mat_trng11;            % Training
        matrix_v1(1:360,:);    % Experiment
        mat_trng22;            % Training
        matrix_v1(361:end,:)]; % Experiment

    % This fifth column represents training (ones) and no training trials (zeros)
    info.matrix(:,8) = [repelem(1,60) repelem(0,360) repelem(1,60) repelem(0,360)]';


    % target orientation
    trl.targ_ori(info.matrix(:,6) == 1,1) = 90; % up orientation
    trl.targ_ori(info.matrix(:,6) == 2,1) = 270; % down orientation


    % ones mark the beginning of a block of trials.
    trl.onset_blocks = repmat([1 repelem(0,29)],1,28)';

    % ones mark the end of a block of trials.
    trl.offset_blocks = repmat([repelem(0,29) 1],1,28)';
    % twos mark the resting block
    trl.offset_blocks(60:60:840,1) = 2;

    % defines trial onset and offset. the onsets are randomized to occur
    % between 500 (60 frames) - 900 (109 frames) ms after fixation onset to avoid temporal
    % expectation.
    %     trl.cue_on = randi([60 109],1,840)';
    %     trl.cue_off = trl.cue_on + 9; % cue offset after 75 ms

    trl.cue_on = randi([30 54],1,840)';
    trl.cue_off = trl.cue_on + 5; % cue offset after 83 ms

    %     trl.targ_on = trl.cue_on + 18; % presents the target 150ms after cue onset (SOA)
    %     trl.targ_off = trl.targ_on + 5; % it will stay on the screen for 40ms

    trl.targ_on = trl.cue_on; % presents the target at the same time of the cue
    trl.targ_off = trl.targ_on + 12; % it will stay on the screen for 200 ms

    trl.repeated_blk = zeros(1,2);

    trl.coherence = zeros(840,4);

    trl.coherence(:,1) = info.matrix(:,2) == 1 & info.matrix(:,5) == 1 & info.matrix(:,7) == 0; % green Left
    trl.coherence(:,2) = info.matrix(:,2) == 2 & info.matrix(:,5) == 1 & info.matrix(:,7) == 0; % Red Left
    trl.coherence(:,3) = info.matrix(:,2) == 1 & info.matrix(:,5) == 2 & info.matrix(:,7) == 0; % Green Right
    trl.coherence(:,4) = info.matrix(:,2) == 2 & info.matrix(:,5) == 2 & info.matrix(:,7) == 0; % Red Right


    %% Create data directories

    if ~exist(sprintf('%s/Data/S%d/Task/', pc_path, sub.id_num), 'dir')
        mkdir(sprintf('%s/Data/S%d/Task/', pc_path, sub.id_num))
    end
    if ~exist(sprintf('%s/Data/S%d/Eye/', pc_path, sub.id_num), 'dir')
        mkdir(sprintf('%s/Data/S%d/Eye/', pc_path, sub.id_num))
    end


    %%
    %%% Save files

    % Save trials information
    sub.trlinfo_fname = sprintf('ses_%d_trlinfo_sub_%d_%s',session, sub.id_num, datestr(now,'yymmdd-HHMM')); %#ok<*TNOW1,*DATST>
    save(fullfile(sprintf('%s/Data/S%d/%s', pc_path, sub.id_num), [sub.trlinfo_fname, '.mat']), 'info', 'trl', 'sub','RDK','const','circle1', '-v7.3');

    fprintf('Sessão_%d...',session)
    fprintf('\nFeito!\n')


end



