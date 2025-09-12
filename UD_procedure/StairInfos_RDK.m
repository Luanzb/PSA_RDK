
git_path = 'C:/Users/activ/OneDrive/Documentos/GitHub/PSA_RDK';
addpath(genpath(git_path));

pc_path = 'C:/Users/activ/OneDrive/Documentos/Projects/PSA_RDK';
addpath(genpath(pc_path));

% Ask subject number
answer = inputdlg({'Número sujeito','Sessão'}, '', [1 25]);
sub.id = answer{1}; sub.id_num = str2double(answer{1});
sub.ses = answer{2}; sub.ses_num = str2double(answer{2}); 

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

info.ntrials = 60;

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

RDK.dotcolor1a = [88 198 219]/255;  % lab2rgb(dotcolor1); % Green

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

const.durMinLife = 0.200;           const.numMinLife = (round(const.durMinLife/const.frame_dur));
const.numMeanLife = 0.250;          const.numMeanLife = (round(const.numMeanLife/const.frame_dur));

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


target_side = repelem([1 2], 30)';
target_color = [repelem([1 2],15)'; repelem([1 2],15)'];
target_ori = [Shuffle(repelem([1 2],15))'; Shuffle(repelem([1 2],15))'];
catch_trl = repmat([repelem(0,12) repelem(1,3)],1,4)';


%               targ color       target side   target ori    catch trials
%                1 - green        1 = left       1=UP         1 = catch
%                2 - red          2 = right      2=Down       0 = no catch

mat.matrix =    [target_color     target_side  target_ori    catch_trl];

mat.matrix = Shuffle(mat.matrix,2);


    %%
    trl.targ_ori(mat.matrix(:,3)' == 1,1) = 90;  % UP orientation
    trl.targ_ori(mat.matrix(:,3)' == 2,1) = 270; % Down orientation

    % defines trial onset and offset. the onsets are randomized to occur
    % between 500 (60 frames) - 900 (109 frames) ms after fixation onset to avoid temporal
    % expectation.
    %     trl.cue_on = randi([60 109],1,60)';
    %     trl.cue_off = trl.cue_on + 9; % cue offset after 75 ms

    trl.cue_on = randi([30 54],1,60)';
    trl.cue_off = trl.cue_on + 5; % cue offset after 83 ms

    %     trl.targ_on = trl.cue_on + 18; % presents the target 150ms after cue onset (SOA)
    %     trl.targ_off = trl.targ_on + 5; % it will stay on the screen for 40ms

    trl.targ_on = trl.cue_on; % presents the target at the same time of the cue
    trl.targ_off = trl.targ_on + 12; % it will stay on the screen for 200 ms

    trl.coherence = zeros(60,4);

    trl.coherence(:,1) = mat.matrix(:,1) == 1 & mat.matrix(:,2) == 1 & mat.matrix(:,4) == 0; % green Left
    trl.coherence(:,2) = mat.matrix(:,1) == 2 & mat.matrix(:,2) == 1 & mat.matrix(:,4) == 0; % Red Left
    trl.coherence(:,3) = mat.matrix(:,1) == 1 & mat.matrix(:,2) == 2 & mat.matrix(:,4) == 0; % Green Right
    trl.coherence(:,4) = mat.matrix(:,1) == 2 & mat.matrix(:,2) == 2 & mat.matrix(:,4) == 0; % Red Right


    %%
% 1Up/1Down PARAMETERS
[info] = UD_info(info,sub);

    %% Create data directories

    if ~exist(sprintf('%s/Data/S%d/Staircase/', pc_path, sub.id_num), 'dir')
        mkdir(sprintf('%s/Data/S%d/Staircase/', pc_path, sub.id_num))
    end

    %%
    %%% Save files

    % Save trials information
    sub.trlinfo_fname = sprintf('ses_%d_staircase_sub_%d_%s',sub.ses_num, sub.id_num, datestr(now,'yymmdd-HHMM')); %#ok<*TNOW1,*DATST>
    save(fullfile(sprintf('%s/Data/S%d/Staircase/%s', pc_path, sub.id_num), [sub.trlinfo_fname, '.mat']), 'info', 'trl', 'sub','mat','circle1','const','RDK', '-v7.3');

    fprintf('\nFeito!\n')

