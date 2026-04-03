
git_path = '/home/kaneda/Documents/GitHub/PSA_RDK';
addpath(genpath(git_path));

%% INFORMAÇÕES SOBRE O TECLADO
KbName('UnifyKeyNames');
info.escapeKey = KbName('ESCAPE');
info.leftKey = KbName('LeftArrow');
info.rightKey = KbName('RightArrow');
info.uparrow = KbName('UpArrow');
info.downarrow = KbName('DownArrow');
info.s         = KbName('S');
info.n         = KbName('N');

%% Screen setup
Screen('Preference', 'SyncTestSettings', 0.01, 50, 0.25);
Screen('Preference', 'SuppressAllWarnings', 1);
Screen('Preference', 'Verbosity', 0);
Screen('Preference', 'SkipSyncTests', 1);

% Seed the random number generator. Here we use an older way to be
% compatible with older systems.
rng('shuffle')

screens = Screen('Screens');% Get the screen numbers.
info.scr_num = screens(1);% draw to the externalscreen.

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

% parameters for fixation period before every trial onset.
info.fix_dur_sec = 0.5;         % Duration of fixation at ROI to start trial in secs
info.roi_fix_dva = 2;           % size of fixation window ROI
info.roi_fix_pix = dva2pix(info.scr_dist_cm,info.scr_xsize_cm,info.scr_xsize,info.roi_fix_dva);
%% Infos Fixation Dot
info.fp_size_dva = 0.3;        % fixation Dot diameter
info.fp_size_pix = round(dva2pix(info.scr_dist_cm, info.scr_xsize_cm, info.scr_xsize, info.fp_size_dva));

%% Infos Saccade_Cue
info.cue_width_dva = 0.15; % saccade cue width in dva
info.cue_length_dva = 0.55; % saccade cue length in dva

info.cue_width_px = round(dva2pix(info.scr_dist_cm, info.scr_xsize_cm, info.scr_xsize, info.cue_width_dva));% saccade cue width converted to pixels
info.cue_length_px = round(dva2pix(info.scr_dist_cm, info.scr_xsize_cm, info.scr_xsize, info.cue_length_dva)); % saccade cue length converted to pixels

%% Tamanho, velocidade e Posicoes dos RDK

% tamnho do estimulo RDK
RDK.size_dva = 4;
RDK.size_pix = dva2pix(info.scr_dist_cm,info.scr_xsize_cm,info.scr_xsize,RDK.size_dva);
% tamanho dos pontos do RDK
RDK.size_dot_dva = .2;
RDK.size_dot_pix = dva2pix(info.scr_dist_cm,info.scr_xsize_cm,info.scr_xsize,RDK.size_dot_dva);

% velocidade de movimento dos pontos por segundo. uma velocidade de 5 dva,
% equvale a um deslocamento de XX pixels por segundo.
RDK.speed_dot = 1.5; % 5
RDK.speed_dot_pix = dva2pix(info.scr_dist_cm,info.scr_xsize_cm,info.scr_xsize,RDK.speed_dot);

% RDK Eccentricity
RDK.EccDVA = 6;
RDK.Ecc = round(dva2pix(info.scr_dist_cm,info.scr_xsize_cm,info.scr_xsize,RDK.EccDVA));

% RDK coordinates on the left and right side from FP
RDK.coordL = [info.scr_xcenter-RDK.Ecc info.scr_ycenter];
RDK.coordR = [info.scr_xcenter+RDK.Ecc info.scr_ycenter];

% Random dot kinematograms
RDK.rad         = RDK.size_pix/2;               % item radius
const.stimRad   = RDK.rad;          % item size

%% General settings
% Ajust screen size and specify item positions and trial timing
% space between stimuli

const.pos = [960 540]; % it will be changed to the right and left side.

% Temporal configurations
const.frame_dur = 1/info.scr_rrate;                     % frame duration in seconds (e.g. 1/60 for screen refresh rate of 60 Hz)
const.start_fr = 1; 

% See genVonMisesDotInfo for details
const.dotRadSize = RDK.size_dot_pix;   %%%% GOOD PROXY? %%%
const.theta_noise = 100;
const.kappa_noise = 0;

const.numDots = 25;
const.dotSpeed_pix = RDK.speed_dot_pix;   % dot speed [pix/dec] %%%% GOOD PROXY? %%%
const.sigDotSpeedMulti = 1; % acceleration (put 1 for without)

const.durMinLife = 0.083;           const.numMinLife = (round(const.durMinLife/const.frame_dur)); % 0.083
const.numMeanLife = 0.150;          const.numMeanLife = (round(const.numMeanLife/const.frame_dur));

%% Color RDKs
% filled dot
RDK.dottype = 2;

trl.dotcolor1 = [0  172   0]/255;  % Green
trl.dotcolor2 = [244 0 0]/255;  % Red

% Convert them to L*a*b* to get the baseline hues
white_point = [0.95047, 1.00000, 1.08883];

baseline_green_xyz = rgb2xyz(trl.dotcolor1, 'ColorSpace', 'srgb');
baseline_red_xyz = rgb2xyz(trl.dotcolor2, 'ColorSpace', 'srgb');

trl.baseline_green_lab = xyz2lab(baseline_green_xyz, 'WhitePoint', white_point);
trl.baseline_red_lab = xyz2lab(baseline_red_xyz, 'WhitePoint', white_point);

% Calculate baseline chroma (saturation) for each color
half_saturation_green = .5;
half_saturation_red = .5;

full_saturation_green = 1;
full_saturation_red = 1;

[low_sat_green] = adjust_chroma(half_saturation_green, trl.baseline_green_lab);
[low_sat_red] = adjust_chroma(half_saturation_red, trl.baseline_red_lab);

[full_sat_green] = adjust_chroma(full_saturation_green, trl.baseline_green_lab);
[full_sat_red] = adjust_chroma(full_saturation_red, trl.baseline_red_lab);


trl.dotcolor1_reduc_sat = low_sat_green;
trl.dotcolor2_reduc_sat = low_sat_red;

trl.dotcolor1_high_sat = full_sat_green;
trl.dotcolor2_high_sat = full_sat_red;


trl.color1_lsat = repmat(low_sat_green, const.numDots, 1)';
trl.color2_lsat = repmat(low_sat_red, const.numDots, 1)';
trl.color3_lsat = repmat(low_sat_green, const.numDots, 1)';
trl.color4_lsat = repmat(low_sat_red, const.numDots, 1)';
%% Define circle parameters (dashed circle around the RDK)

circle1.ecc_dva = RDK.EccDVA; % 8 degrees of visual angle
circle1.rad_dva = (RDK.size_dva/2)+.5;     % 4 degrees of visual angle

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


target_side =  [1 1 2 2 1 1 1 1 2 2 2 2 1 1 1 1]';
target_color = [1 1 2 2 1 1 2 2 1 1 2 2 1 1 1 1]';
target_ori =   [1 2 1 2 1 2 1 2 1 2 1 2 1 1 1 1]';

%               targ color       target side   target ori   
%                1 - green        1 = left       1=UP        
%                2 - red          2 = right      2=Down     

mat.matrix =    [target_color   target_side  target_ori];

mat.matrix(5:12,:) = Shuffle(mat.matrix(5:12,:),2);

    %%
    trl.targ_ori(mat.matrix(:,3)' == 1,1) = 90;  % UP orientation
    trl.targ_ori(mat.matrix(:,3)' == 2,1) = 270; % Down orientation

    % defines trial onset and offset. the onsets are randomized to occur
    % between 500 (60 frames) - 900 (109 frames) ms after fixation onset to avoid temporal
    % expectation.
        trl.cue_on = randi([120 168],1,16)';
        trl.cue_off = trl.cue_on + 9; % cue offset after 75 ms

        trl.targ_on = trl.cue_on + 8; % presents the target 66 ms after cue onset (SOA)
        trl.targ_off = trl.targ_on + 15; % it will stay on the screen for 125ms 

%%