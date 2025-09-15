function [resp,UD,dots] = Stair_On_Screen(info,trl,sub,mat,RDK,const,circle1)
% First column = Hits;
% Second column = False Alarms
% Third column =  Correct rejections
% fourth column = Miss
resp = zeros(60,4);

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

[UD] = UD_setup(info);


try
    abort = false;

    for trial = 1:info.ntrials

        if mat.matrix(trial,4) == 0
            [RDK] = UD_alpha_update(RDK,UD);
        end

        RDK.dirSignal = trl.targ_ori(trial);
        % Trial timing (in frames)
        const.start_test_fr  = trl.targ_on(trial);    % test presentation start
        const.end_test_fr    =  round((trl.targ_on(trial)*const.frame_dur)/const.frame_dur)+const.test_dur_fr-1;  % trl.targ_off(trial);     % test presentation end

        % Create only distractor stimulus
        const.dotColorType = 1; % green/cyan
        [dots] = draw_rdk(const, RDK, trl.coherence(trial,1));

        const.dotColorType = 2; % red/pink
        [dots2] = draw_rdk(const,RDK,trl.coherence(trial,2));

        % Create only distractor stimulus
        const.dotColorType = 1; % green/cyan
        [dots3] = draw_rdk(const, RDK, trl.coherence(trial,3));

        const.dotColorType = 2; % red/pink
        [dots4] = draw_rdk(const,RDK,trl.coherence(trial,4));



        if trial == 1

            txt_ = '-----------------------';
            txt1 = 'Pressione o botão            para iniciar!';
            txt2 = ' branco';

            DrawFormattedText(win, [txt_ txt_ txt_], 'center', info.scr_ycenter -20,info.white_idx);
            DrawFormattedText(win, txt1, 'center', info.scr_ycenter, info.white_idx);
            DrawFormattedText(win, txt2, info.scr_xcenter - 8, info.scr_ycenter, [1 1 1]);
            DrawFormattedText(win, [txt_ txt_ txt_], 'center', info.scr_ycenter + 20,info.white_idx);

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


        tic
        for frame = 1:nFrames % TRIAL WILL END 300 MS AFTER TARG OFF (mask off)


            Screen('BlendFunction', win, GL_SRC_ALPHA, GL_ONE_MINUS_SRC_ALPHA);
            Screen('DrawDots', win, [0 0], info.fp_size_pix, info.white_idx, [info.scr_xcenter info.scr_ycenter], RDK.dottype);

            Screen('DrawDots',win, round(dots{1}(1).posi{frame})', dots{1}(1).siz, dots{1}(1).col, RDK.coordL,2);
            Screen('DrawDots',win, round(dots2{1}(1).posi{frame})', dots2{1}(1).siz,dots2{1}(1).col, RDK.coordL,2);

            Screen('DrawDots',win, round(dots3{1}(1).posi{frame})', dots3{1}(1).siz, dots3{1}(1).col, RDK.coordR,2);
            Screen('DrawDots',win, round(dots4{1}(1).posi{frame})', dots4{1}(1).siz, dots4{1}(1).col, RDK.coordR,2);


            % Draw dashed circle around left stimulus
            drawDashedCircle(win, circle1.leftCirclePos(1,1), circle1.leftCirclePos(1,2), ...
                circle1.rad_pix+5, circle1.Color, circle1.lineWidth, circle1.linegap);

            % Draw dashed circle around right stimulus
            drawDashedCircle(win, circle1.rightCirclePos(1,1), circle1.rightCirclePos(1,2), ...
                circle1.rad_pix+5, circle1.Color, circle1.lineWidth, circle1.linegap);


            Screen('BlendFunction',win,GL_SRC_ALPHA,GL_ONE_MINUS_SRC_ALPHA);

            % CUE ONSET
            if frame >= trl.cue_on(trial,1) && frame <= trl.cue_off(trial,1)

                Screen('DrawLine', win, info.white_idx, info.scr_xcenter,info.scr_ycenter ...
                    ,info.scr_xcenter + info.cue_length_px,info.scr_ycenter, info.cue_width_px);
                Screen('DrawLine', win, info.white_idx, info.scr_xcenter,info.scr_ycenter ...
                    ,info.scr_xcenter - info.cue_length_px,info.scr_ycenter, info.cue_width_px);
            end


            Screen('Flip', win);

        end


        Screen('BlendFunction', win, GL_SRC_ALPHA, GL_ONE_MINUS_SRC_ALPHA);
        Screen('DrawDots', win, [0 0], info.fp_size_pix, info.white_idx, [info.scr_xcenter info.scr_ycenter], RDK.dottype);


        if mat.matrix(trial,2) == 1
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
            elseif keyCode(info.leftKey) % left arrow: saw the target
                response = 1;
                respToBeMade = false;
            elseif keyCode(info.rightKey) % right arrow: didn't see the target
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
                elseif keyCode(info.uparrow) % up arrow:
                    response = 1;
                    respToBeMade = false;
                elseif keyCode(info.downarrow) % down arrow: 
                    response = 0;
                    respToBeMade = false;
                end
            end

        end


        % Colect answer for each trial.
        if response == 1 && mat.matrix(trial,4) == 0 % Hit
            resp(trial,1) = 1;
        elseif response == 1 && mat.matrix(trial,4) == 1 % False alarm
            resp(trial,2) = 1;
        elseif response == 0 && mat.matrix(trial,4) == 1 % Correct Rejection
            resp(trial,3) = 1;
        elseif response == 0 && mat.matrix(trial,4) == 0 % Miss
            resp(trial,4) = 1;
        end


        % update staircase value if the current trial had a target
        if mat.matrix(trial,4) == 0
            if response == 1
                outcome = 1;
            else
                outcome = 0;
            end

            [info,UD] = UD_update(info,UD,outcome);

        end


    end

    Screen('CloseAll');




    FlushEvents;
    ListenChar(0);
    ShowCursor;
    Priority(0);


catch

    psychrethrow(psychlasterror);
    sca; close all;

end


end