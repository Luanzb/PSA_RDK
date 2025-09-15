function  [resp,dots4,dots] = Screen_RDK(info,trl,sub,RDK,const,circle1)


% First column  = Hits;
% Second column = False Alarms
% Third column  =  Correct rejections
% fourth column = Miss
% fifth column  = Reported target orientation if subject saw a target
resp = zeros(info.ntrials,5);

nFrames = const.max_fr;

%% Screen setup

FlushEvents;
PsychDefaultSetup(2);% default settings for setting up Psychtoolbox

Screen('Preference', 'SyncTestSettings', 0.01, 50, 0.25);
Screen('Preference', 'SuppressAllWarnings', 1);
Screen('Preference', 'Verbosity', 0);
Screen('Preference', 'SkipSyncTests', 1);

% Define black and white (white== 1 and black, 0).
info.white_idx = WhiteIndex(info.scr_num);
info.black_idx = BlackIndex(info.scr_num);
info.gray_idx = info.white_idx/2;

[win, info.scr_rect] = PsychImaging('OpenWindow', info.scr_num, info.black_idx, [], 32, 2, [], []); % RODA EM TELA TODA

%%

topPriorityLevel = MaxPriority(win);
Priority(topPriorityLevel);
HideCursor;
ListenChar(-1);

%%

block_counter = 0;

trial = 1;

RDK.kappa = sub.targ*100;               % test item motion coherence

while trial <= info.ntrials

    resp_trng = 2;

    RDK.dirSignal = trl.targ_ori(trial);
    % Trial timing (in frames)
    const.start_test_fr  = trl.targ_on(trial);    % test presentation start
    const.end_test_fr    =  round((trl.targ_on(trial)*const.frame_dur)/const.frame_dur)+const.test_dur_fr-1;  % trl.targ_off(trial);     % test presentation end

    % Create only distractor stimulus
    const.dotColorType = 1; % green/cyan
    [dots] = draw_rdk(const, RDK, 1);

    const.dotColorType = 2; % red/pink
    [dots2] = draw_rdk(const,RDK,trl.coherence(trial,2));

    % Create only distractor stimulus
    const.dotColorType = 1; % green/cyan
    [dots3] = draw_rdk(const, RDK, trl.coherence(trial,3));

    const.dotColorType = 2; % red/pink
    [dots4] = draw_rdk(const,RDK,trl.coherence(trial,4));

    % condicional flipa a cada inicio de bloco (a cada 30 tentativas)
    if trl.onset_blocks(trial,1) == 1

        block_counter = block_counter + 1;


        if trial == 421

            Screen('TextSize',win, 45);
            texto1 = 'Cor mais provável mudou!' ;
            texto2 = 'Chame o pesquisador! (Pressione espaço para continuar)';
            DrawFormattedText(win, [texto1 '\n' texto2], 'center', info.scr_ycenter,[1 1 1]);
            Screen('FrameRect',win,[1 1 1], [960-500 540-400 960+500 540+400],4);

            Screen('Flip', win);


            respToBeMade = true;
            while respToBeMade
                [~,~, keyCode] = KbCheck;
                if keyCode(info.escapeKey)
                    ShowCursor;
                    sca;
                    return
                elseif keyCode(info.return)
                    respToBeMade = false;
                end
            end

        end


        Screen('TextSize',win, 24);
        % show colored dots depending on the most probable color in the

        % Draw dashed circle around central stimulus
        drawDashedCircle(win, 960, 540, circle1.rad_pix+5, circle1.Color, circle1.lineWidth, circle1.linegap);


        txt_ = '----------------------';
        txt4 = 'COR MAIS PROVÁVEL ABAIXO!';
        color = [1 1 1];


        txt5 = '';

        DrawFormattedText(win, [txt_ txt_ txt_ txt_ '\n' txt5 '\n' txt_ txt_ txt_ txt_], 'center', info.scr_ycenter - 130, info.white_idx);
        DrawFormattedText(win, [txt5 '\n' txt4 '\n' txt5], 'center', info.scr_ycenter - 130, color);



        txt1 = 'Pressione o botão            para iniciar!';
        txt2 = ' branco';
        txt3 = sprintf('Bloco %d/%d', block_counter, sum(trl.onset_blocks));
        DrawFormattedText(win, [txt_ txt_ txt_ txt_], 'center', info.scr_ycenter +100,info.white_idx);
        DrawFormattedText(win, txt1, 'center', info.scr_ycenter + 130, info.white_idx);
        DrawFormattedText(win, txt2, info.scr_xcenter - 8, info.scr_ycenter + 130, [1 1 1]);
        DrawFormattedText(win, [txt_ txt_ txt_ txt_], 'center', info.scr_ycenter + 150,info.white_idx);
        DrawFormattedText(win, txt3, 'center', info.scr_ycenter + 180,info.white_idx);
        DrawFormattedText(win, txt_, 'center', info.scr_ycenter + 200,info.white_idx);


        if ismember(trial,[1 31 421 451])

            texto1 = 'HORA DO TREINO!' ;
            DrawFormattedText(win, texto1, 'center', info.scr_ycenter - 300,color);
            Screen('FrameRect',win,color, [960-500 540-400 960+500 540+400],4);

        end

        Screen('Flip', win);


        respToBeMade = true;
        while respToBeMade
            [~,~, keyCode] = KbCheck;
            if keyCode(info.escapeKey)
                ShowCursor;
                sca;
                return
            elseif keyCode(info.return)
                respToBeMade = false;
            end
        end

    end


    Screen('BlendFunction', win, GL_SRC_ALPHA, GL_ONE_MINUS_SRC_ALPHA);

    tic
    for frameIdx = 1:nFrames

        Screen('BlendFunction', win, GL_SRC_ALPHA, GL_ONE_MINUS_SRC_ALPHA);
        Screen('DrawDots', win, [0 0], info.fp_size_pix, info.white_idx, [info.scr_xcenter info.scr_ycenter], RDK.dottype);

        Screen('DrawDots',win, round(dots{1}(1).posi{frameIdx})', dots{1}(1).siz, dots{1}(1).col/255, RDK.coordL,2);
        Screen('DrawDots',win, round(dots2{1}(1).posi{frameIdx})', dots2{1}(1).siz,dots2{1}(1).col/255, RDK.coordL,2);

        Screen('DrawDots',win, round(dots3{1}(1).posi{frameIdx})', dots3{1}(1).siz, dots3{1}(1).col/255, RDK.coordR,2);
        Screen('DrawDots',win, round(dots4{1}(1).posi{frameIdx})', dots4{1}(1).siz, dots4{1}(1).col/255, RDK.coordR,2);


        % Draw dashed circle around left stimulus
        drawDashedCircle(win, circle1.leftCirclePos(1,1), circle1.leftCirclePos(1,2), ...
            circle1.rad_pix+5, circle1.Color, circle1.lineWidth, circle1.linegap);

        % Draw dashed circle around right stimulus
        drawDashedCircle(win, circle1.rightCirclePos(1,1), circle1.rightCirclePos(1,2), ...
            circle1.rad_pix+5, circle1.Color, circle1.lineWidth, circle1.linegap);


        Screen('BlendFunction',win,GL_SRC_ALPHA,GL_ONE_MINUS_SRC_ALPHA);

        % CUE ONSET
        if frameIdx >= trl.cue_on(trial,1) && frameIdx <= trl.cue_off(trial,1)
            if info.matrix(trial,4) == 2
                Screen('DrawLine', win, info.white_idx, info.scr_xcenter,info.scr_ycenter ...
                    ,info.scr_xcenter + info.cue_length_px,info.scr_ycenter, info.cue_width_px);
            else
                Screen('DrawLine', win, info.white_idx, info.scr_xcenter,info.scr_ycenter ...
                    ,info.scr_xcenter - info.cue_length_px,info.scr_ycenter, info.cue_width_px);
            end
        end



        Screen('Flip', win);
        %         if frameIdx >= trl.targ_on(trial) && frameIdx <= trl.targ_off(trial)
        %             WaitSecs(.07);
        %         end

    end


    Screen('BlendFunction', win, GL_SRC_ALPHA, GL_ONE_MINUS_SRC_ALPHA);
    Screen('DrawDots', win, [0 0], info.fp_size_pix, info.white_idx, [info.scr_xcenter info.scr_ycenter], RDK.dottype);


    if info.matrix(trial,5) == 1
        % Draw dashed circle around left stimulus
        drawDashedCircle(win, circle1.leftCirclePos(1,1), circle1.leftCirclePos(1,2), ...
            circle1.rad_pix+5, circle1.Color, circle1.lineWidth*2, circle1.linegap);
        % Draw dashed circle around right stimulus
        drawDashedCircle(win, circle1.rightCirclePos(1,1), circle1.rightCirclePos(1,2), ...
            circle1.rad_pix+5, circle1.Color, circle1.lineWidth, circle1.linegap);
    else
        % Draw dashed circle around left stimulus
        drawDashedCircle(win, circle1.leftCirclePos(1,1), circle1.leftCirclePos(1,2), ...
            circle1.rad_pix+5, circle1.Color, circle1.lineWidth, circle1.linegap);
        % Draw dashed circle around right stimulus
        drawDashedCircle(win, circle1.rightCirclePos(1,1), circle1.rightCirclePos(1,2), ...
            circle1.rad_pix+5, circle1.Color, circle1.lineWidth*2, circle1.linegap);
    end

    Screen('Flip', win);

    toc



    respToBeMade = true;
    while respToBeMade
        [~,~, keyCode] = KbCheck;
        if keyCode(info.escapeKey)
            ShowCursor;
            sca;
            return
        elseif keyCode(info.uparrow) % up arrow: saw the target
            response = 1;
            respToBeMade = false;
        elseif keyCode(info.downarrow) % down arrow: didn't see the target
            response = 0;
            respToBeMade = false;
        end
    end

    if response == 1

        respToBeMade = true;
        while respToBeMade
            [~,~, keyCode] = KbCheck;
            if keyCode(info.escapeKey)
                ShowCursor;
                sca;
                return
            elseif keyCode(info.leftKey) % left arrow: CCW (225º)
                response = 1;
                respToBeMade = false;
            elseif keyCode(info.rightKey) % right arrow: CW (135º)
                response = 0;
                respToBeMade = false;
            end
        end



    end


    % Colect answer for each trial.
    if response == 1 && info.matrix(trial,7) == 0 % Hit
        resp(trial,1) = 1;
        resp(trial,5) = trl.targ_ori(trial);
    elseif response == 1 && info.matrix(trial,7) == 1 % False alarm
        resp(trial,2) = 1;
        resp(trial,5) = trl.targ_ori(trial);
    elseif response == 0 && info.matrix(trial,7) == 1 % Correct Rejection
        resp(trial,3) = 1;
    elseif response == 0 && info.matrix(trial,7) == 0 % Miss
        resp(trial,4) = 1;
    end


    if (trial >= 1 && trial <= 60) || (trial >= 421 && trial <= 480)

        if resp(trial,1) == 1 || resp(trial,4) == 1
            fp = imread('C:/Users/activ/OneDrive/Documentos/GitHub/PSA_RDK/Images/yfp.png');
        elseif resp(trial,2) == 1 || resp(trial,3) == 1
            fp = imread('C:/Users/activ/OneDrive/Documentos/GitHub/PSA_RDK/Images/bfp.png');
        end

        tex_col = Screen('MakeTexture', win, fp); clear fp;

        Screen('BlendFunction', win, GL_SRC_ALPHA, GL_ONE_MINUS_SRC_ALPHA);
        Screen('DrawTexture', win, tex_col, [], [info.scr_xcenter - info.fp_size_pix/2 ...
            info.scr_ycenter - info.fp_size_pix/2 ...
            info.scr_xcenter + info.fp_size_pix/2 ...
            info.scr_ycenter + info.fp_size_pix/2], 0);

        % Draw dashed circle around left stimulus
        drawDashedCircle(win, circle1.leftCirclePos(1,1), circle1.leftCirclePos(1,2), ...
            circle1.rad_pix+5, circle1.Color, circle1.lineWidth, circle1.linegap);

        % Draw dashed circle around right stimulus
        drawDashedCircle(win, circle1.rightCirclePos(1,1), circle1.rightCirclePos(1,2), ...
            circle1.rad_pix+5, circle1.Color, circle1.lineWidth, circle1.linegap);

        Screen('Flip', win); WaitSecs(0.3);



        % DRAW FIXATION POINT AND PLACEHOLDERS
        Screen('BlendFunction', win, GL_SRC_ALPHA, GL_ONE_MINUS_SRC_ALPHA);
        Screen('DrawDots', win, [0 0], info.fp_size_pix, info.white_idx, [info.scr_xcenter info.scr_ycenter], RDK.dottype);

        % Draw dashed circle around left stimulus
        drawDashedCircle(win, circle1.leftCirclePos(1,1), circle1.leftCirclePos(1,2), ...
            circle1.rad_pix+5, circle1.Color, circle1.lineWidth, circle1.linegap);

        % Draw dashed circle around right stimulus
        drawDashedCircle(win, circle1.rightCirclePos(1,1), circle1.rightCirclePos(1,2), ...
            circle1.rad_pix+5, circle1.Color, circle1.lineWidth, circle1.linegap);
        Screen('Flip', win); WaitSecs(0.2);

    end


    %--------------------------------------------------------------------------

    if trial == 60 || trial == 480

        txt6 = 'Deseja realizar o treino novamente? \n\n (Sim - verde / Não - Vermelho)';
        DrawFormattedText(win, txt6, 'center', info.scr_ycenter - 250, info.white_idx);
        Screen('Flip', win);



        respToBeMade = true;
        while respToBeMade
            [~,~, keyCode] = KbCheck;
            if keyCode(info.escapeKey)
                ShowCursor;
                sca;
                return
            elseif keyCode(info.s) % repeat training again
                resp_trng = 0;
                respToBeMade = false;
            elseif keyCode(info.n) % got to the experiment
                resp_trng = 1;
                respToBeMade = false;
            end
        end


        if resp_trng == 0
            if trial == 60
                trl.repeated_blk(1,1) = 1;
            elseif trial == 480
                trl.repeated_blk(1,2) = 1;
            end
        end


    end


    %--------------------------------------------------------------------------


    if trl.offset_blocks(trial,1) ~= 0

        if trial == size(trl.onset_blocks,1)
            txt = 'Voce completou todos os blocos da sessão. \n\n Parabéns!';
            DrawFormattedText(win, txt, 'center', info.scr_ycenter - 250, info.white_idx);

        elseif trl.offset_blocks(trial,1) == 1

            txt = sprintf('Bloco %i/%i completo.', block_counter, sum(trl.onset_blocks));
            txt1 = 'Pressione o botão            para continuar!';
            txt2 = ' branco';

            txt_ = '----------------------';
            DrawFormattedText(win, txt, 'center', info.scr_ycenter, info.white_idx);
            DrawFormattedText(win, [txt_ txt_ txt_], 'center', info.scr_ycenter +100,info.white_idx);
            DrawFormattedText(win, txt1, 'center', info.scr_ycenter + 130, info.white_idx);
            DrawFormattedText(win, txt2, info.scr_xcenter - 24, info.scr_ycenter + 130, [1 1 1]);
            DrawFormattedText(win, [txt_ txt_ txt_], 'center', info.scr_ycenter + 150,info.white_idx);

        elseif trl.offset_blocks(trial,1) == 2

            txt = sprintf('Bloco %i/%i completo.', block_counter, sum(trl.onset_blocks));
            txt1 = 'Pressione o botão            para continuar!';
            txt2 = ' branco';
            txt3 = 'Hora do descanso!';

            txt_ = '----------------------';
            DrawFormattedText(win, txt, 'center', info.scr_ycenter, info.white_idx);
            DrawFormattedText(win, txt3, 'center', info.scr_ycenter+65, color);
            DrawFormattedText(win, [txt_ txt_ txt_], 'center', info.scr_ycenter +100,info.white_idx);
            DrawFormattedText(win, txt1, 'center', info.scr_ycenter + 130, info.white_idx);
            DrawFormattedText(win, txt2, info.scr_xcenter - 24, info.scr_ycenter + 130, [1 1 1]);
            DrawFormattedText(win, [txt_ txt_ txt_], 'center', info.scr_ycenter + 150,info.white_idx);

        end
        Screen('Flip', win);


        respToBeMade = true;
        while respToBeMade
            [~,~, keyCode] = KbCheck;
            if keyCode(info.escapeKey)
                ShowCursor;
                sca;
                return
            elseif keyCode(info.return) % press space to continue
                respToBeMade = false;
            end


        end

    end

    if resp_trng == 0

        trial = abs(trial - 60);

        block_counter = block_counter - 2;
    end

    trial = trial + 1;



end

KbStrokeWait;
Screen('CloseAll');

FlushEvents;
ListenChar(0);
ShowCursor;
Priority(0);


end
