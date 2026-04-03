ResponsePixx('Close');
ResponsePixx('Open');

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
ListenChar(-1);

trl.new_sat1 = trl.dotcolor1_high_sat;
trl.new_sat2 = trl.dotcolor2_high_sat;

colors = [trl.new_sat1; trl.new_sat1; trl.new_sat2; trl.new_sat2];
target_side = [741-15; 741-15; 1179-15; 1179-15];
target_field = [540-120; 120+540;540-120;120+540];

trial = 1;

sat = [1:12 100 90 80 70];

try
    abort = false;

    while trial >= 1 && trial <= 16  % Modified condition


        if trial >= 13

            if trial == 13
                full_saturation_green = 1;
                full_saturation_red = 1;
            elseif trial == 14
                full_saturation_green = .90;
                full_saturation_red = .90;
            elseif trial == 15
                full_saturation_green = .80;
                full_saturation_red = .80;
            elseif trial == 16
                full_saturation_green = .70;
                full_saturation_red = .70;
            end

            [low_sat_green] = adjust_chroma(half_saturation_green, trl.baseline_green_lab);
            [low_sat_red] = adjust_chroma(half_saturation_red, trl.baseline_red_lab);

            [full_sat_green] = adjust_chroma(full_saturation_green, trl.baseline_green_lab);
            [full_sat_red] = adjust_chroma(full_saturation_red, trl.baseline_red_lab);

            trl.new_sat1 = full_sat_green;
            trl.new_sat2 = full_sat_red;

            txtt = sprintf('Saturação: %i', sat(trial));
            DrawFormattedText(win, [txtt], 'center', info.scr_ycenter - 360,info.white_idx);

        end

        txt = sprintf('Exemplo %i', trial);



        txt_ = '-------------------';
        DrawFormattedText(win, txt, 'center', info.scr_ycenter - 480, info.white_idx);
        DrawFormattedText(win, [txt_], 'center', info.scr_ycenter - 500,info.white_idx);

        DrawFormattedText(win, [txt_], 'center', info.scr_ycenter - 460,info.white_idx);

        const.max_fr = trl.targ_off(trial);

        % MOVED THIS HERE - Generate dots at the START of each trial
        % This ensures dots are regenerated when going backwards
        [dots]  = draw_rdk(const, RDK,0); % green left
        [dots2] = draw_rdk(const, RDK,0); % red left
        [dots3] = draw_rdk(const, RDK,0); % green right
        [dots4] = draw_rdk(const, RDK,0); % red right


        %% FIXAÇÃO INICIAL: SOMENTE PONTO DE FIXAÇÃO E PLACEHOLDERS
        Screen('BlendFunction', win, GL_SRC_ALPHA, GL_ONE_MINUS_SRC_ALPHA);
        Screen('DrawDots', win, [0 0], info.fp_size_pix, info.white_idx, [info.scr_xcenter info.scr_ycenter], RDK.dottype);

        % Draw dashed circle around left stimulus
        drawDashedCircle(win, circle1.leftCirclePos(1,1), circle1.leftCirclePos(1,2), ...
            circle1.rad_pix, circle1.Color, circle1.lineWidth, circle1.linegap);
        % Draw dashed circle around right stimulus
        drawDashedCircle(win, circle1.rightCirclePos(1,1), circle1.rightCirclePos(1,2), ...
            circle1.rad_pix, circle1.Color, circle1.lineWidth, circle1.linegap);

        Screen('Flip', win);

        if trial <= 4
            % Wait for mouse click
            [clicks, x, y, buttons] = GetClicks(win, 0);
            % Check which button was clicked
            if buttons == 1  % Left button (button 1)
            end
        else
            WaitSecs(1);
        end

        if trial <= 12
            count = 24;
        else
            count = 0;
        end

        %% ESTÍMULOS RDK
        for frame = 1:trl.targ_off(trial)+count

            txt = sprintf('Exemplo %i', trial);

            if trial >= 13
                txtt = sprintf('Saturação: %i', sat(trial));
                DrawFormattedText(win, [txtt], 'center', info.scr_ycenter - 360,info.white_idx);

            end
            txt_ = '-------------------';
            DrawFormattedText(win, txt, 'center', info.scr_ycenter - 480, info.white_idx);
            DrawFormattedText(win, [txt_], 'center', info.scr_ycenter - 500,info.white_idx);

            DrawFormattedText(win, [txt_], 'center', info.scr_ycenter - 460,info.white_idx);
            if trial <= 4

                if frame >= trl.targ_on(trial,1) && frame <= trl.targ_off(trial,1)

                    txt_ = 'Alvo';
                    DrawFormattedText(win, txt_, target_side(trial,1), target_field(trial,1), colors(trial,:));

                end
            end


            color11 = trl.color1_lsat;
            color22 = trl.color2_lsat;
            color33 = trl.color3_lsat;
            color44 = trl.color4_lsat;

            Screen('BlendFunction', win, GL_SRC_ALPHA, GL_ONE_MINUS_SRC_ALPHA);
            Screen('DrawDots', win, [0 0], info.fp_size_pix, info.white_idx, [info.scr_xcenter info.scr_ycenter], RDK.dottype);


            if frame <= trl.targ_off(trial)

                if trial <= 12

                    if frame >= trl.targ_on(trial)

                        if mat.matrix(trial,1) == 1 && mat.matrix(trial,2) == 1

                            if mat.matrix(trial,3) == 2 % lower quadrant
                                col_idx = dots{1,1}(1).posi{1,frame}(:,2) > 0;
                                color11(:, col_idx) = repmat(trl.new_sat1', 1, sum(col_idx));
                            else
                                col_idx = dots{1,1}(1).posi{1,frame}(:,2) < 0; % upper quadrant
                                color11(:, col_idx) = repmat(trl.new_sat1', 1, sum(col_idx));
                            end

                        elseif mat.matrix(trial,1) == 2 && mat.matrix(trial,2) == 1

                            if mat.matrix(trial,3) == 2 % lower quadrant
                                col_idx = dots2{1,1}(1).posi{1,frame}(:,2) > 0;
                                color22(:, col_idx) = repmat(trl.new_sat2', 1, sum(col_idx));
                            else
                                col_idx = dots2{1,1}(1).posi{1,frame}(:,2) < 0;
                                color22(:, col_idx) = repmat(trl.new_sat2', 1, sum(col_idx));
                            end

                        elseif mat.matrix(trial,1) == 1 && mat.matrix(trial,2) == 2

                            if mat.matrix(trial,3) == 2 % lower quadrant
                                col_idx = dots3{1,1}(1).posi{1,frame}(:,2) > 0;
                                color33(:, col_idx) = repmat(trl.new_sat1', 1, sum(col_idx));
                            else
                                col_idx = dots3{1,1}(1).posi{1,frame}(:,2) < 0;
                                color33(:, col_idx) = repmat(trl.new_sat1', 1, sum(col_idx));
                            end

                        elseif mat.matrix(trial,1) == 2 && mat.matrix(trial,2) == 2

                            if mat.matrix(trial,3) == 2 % lower quadrant

                                col_idx = dots4{1,1}(1).posi{1,frame}(:,2) > 0;
                                color44(:, col_idx) = repmat(trl.new_sat2', 1, sum(col_idx));
                            else
                                col_idx = dots4{1,1}(1).posi{1,frame}(:,2) < 0;
                                color44(:, col_idx) = repmat(trl.new_sat2', 1, sum(col_idx));
                            end
                        end
                        WaitSecs(.01);
                    else
                        color11 = trl.color1_lsat;
                        color22 = trl.color2_lsat;
                        color33 = trl.color3_lsat;
                        color44 = trl.color4_lsat;
                    end

                else

                    col_idx = dots{1,1}(1).posi{1,frame}(:,2) < 0;
                    color11(:, col_idx) = repmat(trl.new_sat1', 1, sum(col_idx));

                    col_idx = dots4{1,1}(1).posi{1,frame}(:,2) < 0;
                    color44(:, col_idx) = repmat(trl.new_sat2', 1, sum(col_idx));

                    WaitSecs(.01);

                end

                if trial <= 12
                    Screen('DrawDots',win, round(dots{1}(1).posi{frame})', dots{1}(1).siz, color11, RDK.coordL,2);
                    Screen('DrawDots',win, round(dots2{1}(1).posi{frame})', dots2{1}(1).siz,color22, RDK.coordL,2);

                    Screen('DrawDots',win, round(dots3{1}(1).posi{frame})', dots3{1}(1).siz, color33, RDK.coordR,2);
                    Screen('DrawDots',win, round(dots4{1}(1).posi{frame})', dots4{1}(1).siz, color44, RDK.coordR,2);

                else
                    Screen('DrawDots',win, round(dots{1}(1).posi{frame})', dots{1}(1).siz, color11, RDK.coordL,2);

                    Screen('DrawDots',win, round(dots4{1}(1).posi{frame})', dots4{1}(1).siz, color44, RDK.coordR,2);
                end
            end

            % Draw dashed circle around left stimulus
            drawDashedCircle(win, circle1.leftCirclePos(1,1), circle1.leftCirclePos(1,2), ...
                circle1.rad_pix, circle1.Color, circle1.lineWidth, circle1.linegap);

            % Draw dashed circle around right stimulus
            drawDashedCircle(win, circle1.rightCirclePos(1,1), circle1.rightCirclePos(1,2), ...
                circle1.rad_pix, circle1.Color, circle1.lineWidth, circle1.linegap);


            if trial <= 12
                if frame >= trl.cue_on(trial,1) && frame <= trl.cue_off(trial,1)
                    Screen('DrawLine', win, info.white_idx, info.scr_xcenter,info.scr_ycenter ...
                        ,info.scr_xcenter + info.cue_length_px,info.scr_ycenter, info.cue_width_px);
                    Screen('DrawLine', win, info.white_idx, info.scr_xcenter,info.scr_ycenter ...
                        ,info.scr_xcenter - info.cue_length_px,info.scr_ycenter, info.cue_width_px);
                end
            end

            Screen('Flip', win); WaitSecs(.01);

            if trial <= 4
                if frame == 1
                    % Wait for mouse click
                    [clicks, x, y, buttons] = GetClicks(win, 0);
                    % Check which button was clicked
                    if buttons == 1  % Left button (button 1)
                    end
                end

                if frame == trl.cue_on(trial,1)
                    % Wait for mouse click
                    [clicks, x, y, buttons] = GetClicks(win, 0);
                    % Check which button was clicked
                    if buttons == 1  % Left button (button 1)
                    end
                end
                if frame == trl.targ_on(trial,1)
                    % Wait for mouse click
                    [clicks, x, y, buttons] = GetClicks(win, 0);
                    % Check which button was clicked
                    if buttons == 1  % Left button (button 1)
                    end
                end
            end

            if trial >= 13
                if frame == 1
                    % Wait for mouse click
                    [clicks, x, y, buttons] = GetClicks(win, 0);
                    % Check which button was clicked
                    if buttons == 1  % Left button (button 1)
                    end
                end
            end

        end

        %% ESTÍMULOS PLACEHOLDERS E fp

        if trial <= 12
            txt = sprintf('Exemplo %i', trial);

            txt_ = '-------------------';
            DrawFormattedText(win, txt, 'center', info.scr_ycenter - 480, info.white_idx);
            DrawFormattedText(win, [txt_], 'center', info.scr_ycenter - 500,info.white_idx);

            DrawFormattedText(win, [txt_], 'center', info.scr_ycenter - 460,info.white_idx);

            Screen('BlendFunction', win, GL_SRC_ALPHA, GL_ONE_MINUS_SRC_ALPHA);
            Screen('DrawDots', win, [0 0], info.fp_size_pix, info.white_idx, [info.scr_xcenter info.scr_ycenter], RDK.dottype);

            % Draw dashed circle around left stimulus
            drawDashedCircle(win, circle1.leftCirclePos(1,1), circle1.leftCirclePos(1,2), ...
                circle1.rad_pix, circle1.Color, circle1.lineWidth, circle1.linegap);
            % Draw dashed circle around right stimulus
            drawDashedCircle(win, circle1.rightCirclePos(1,1), circle1.rightCirclePos(1,2), ...
                circle1.rad_pix, circle1.Color, circle1.lineWidth, circle1.linegap);

            Screen('Flip', win);

            if trial <= 4
                % Wait for mouse click
                [clicks, x, y, buttons] = GetClicks(win, 0);
                % Check which button was clicked
                if buttons == 1  % Left button (button 1)
                end
            else
                WaitSecs(.2);
            end


            %% PISTA DE RESPOSTA
            Screen('BlendFunction', win, GL_SRC_ALPHA, GL_ONE_MINUS_SRC_ALPHA);
            Screen('DrawDots', win, [0 0], info.fp_size_pix, info.white_idx, [info.scr_xcenter info.scr_ycenter], RDK.dottype);
            if mat.matrix(trial,2) == 1
                % Draw dashed circle around left stimulus
                drawDashedCircle(win, circle1.leftCirclePos(1,1), circle1.leftCirclePos(1,2), ...
                    circle1.rad_pix, circle1.Color, circle1.lineWidth*2, circle1.linegap);
                % Draw dashed circle around right stimulus
                drawDashedCircle(win, circle1.rightCirclePos(1,1), circle1.rightCirclePos(1,2), ...
                    circle1.rad_pix, circle1.Color, circle1.lineWidth, circle1.linegap);
            else
                % Draw dashed circle around left stimulus
                drawDashedCircle(win, circle1.leftCirclePos(1,1), circle1.leftCirclePos(1,2), ...
                    circle1.rad_pix, circle1.Color, circle1.lineWidth, circle1.linegap);
                % Draw dashed circle around right stimulus
                drawDashedCircle(win, circle1.rightCirclePos(1,1), circle1.rightCirclePos(1,2), ...
                    circle1.rad_pix, circle1.Color, circle1.lineWidth*2, circle1.linegap);
            end

            Screen('Flip', win);


            ResponsePixx('StartNow', 1, [0 1 0 1 0], 1);
            while 1
                [buttons_rp, ~, ~] = ResponsePixx('GetLoggedResponses', 1, 1, 2000);
                if ~isempty(buttons_rp)
                    if buttons_rp(1,2) == 1         % Yellow button up
                        response = 1;
                        break;
                    elseif buttons_rp(1,4) == 1     % Blue button down
                        response = 2;
                        break;
                    elseif buttons_rp(1,1) == 1         % Red button
                        abort = true;
                        break;
                    end
                end
            end
            ResponsePixx('StopNow', 1, [0 0 0 0 0], 0);

            %% RESPOSTA AO FINAL DA TENTATIVA

            color1 = trl.dotcolor1_reduc_sat;
            color2 = trl.dotcolor2_reduc_sat;


            Screen('BlendFunction', win, GL_SRC_ALPHA, GL_ONE_MINUS_SRC_ALPHA);

            if mat.matrix(trial,1) == 1 && mat.matrix(trial,3) == 1 % green up
                Screen('DrawLine', win, color1, info.scr_xcenter,info.scr_ycenter ...
                    ,info.scr_xcenter,info.scr_ycenter - info.cue_length_px, info.cue_width_px);
            elseif mat.matrix(trial,1) == 1 && mat.matrix(trial,3) == 2 % green down
                Screen('DrawLine', win, color1, info.scr_xcenter,info.scr_ycenter ...
                    ,info.scr_xcenter,info.scr_ycenter + info.cue_length_px, info.cue_width_px);
            elseif mat.matrix(trial,1) == 2 && mat.matrix(trial,3) == 1 % red up
                Screen('DrawLine', win, color2, info.scr_xcenter,info.scr_ycenter ...
                    ,info.scr_xcenter,info.scr_ycenter - info.cue_length_px, info.cue_width_px);
            elseif mat.matrix(trial,1) == 2 && mat.matrix(trial,3) == 2 % red down
                Screen('DrawLine', win, color2, info.scr_xcenter,info.scr_ycenter ...
                    ,info.scr_xcenter,info.scr_ycenter + info.cue_length_px, info.cue_width_px);
            end
            Screen('DrawDots', win, [0 0], info.fp_size_pix, [1 1 1], [info.scr_xcenter info.scr_ycenter], RDK.dottype);

            % Draw dashed circle around left stimulus
            drawDashedCircle(win, circle1.leftCirclePos(1,1), circle1.leftCirclePos(1,2), ...
                circle1.rad_pix, circle1.Color, circle1.lineWidth, circle1.linegap);

            % Draw dashed circle around right stimulus
            drawDashedCircle(win, circle1.rightCirclePos(1,1), circle1.rightCirclePos(1,2), ...
                circle1.rad_pix, circle1.Color, circle1.lineWidth, circle1.linegap);

            Screen('Flip', win);
        end

        % Wait for mouse click
        [clicks, x, y, buttons] = GetClicks(win, 0);

        % Check which button was clicked
        if buttons == 1  % Left button (button 1)
            % Move to next trial
            if trial <= 16  % Changed condition
                trial = trial + 1;
            end

        elseif buttons == 3  % Right button (button 3)
            % Move to previous trial
            if trial > 1
                trial = trial - 1;
            end
        end

        % Check for abort
        if abort
            break;
        end

    end



    sca;

catch


end