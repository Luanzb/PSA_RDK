function DriftCorrectCustom(el, scr)

    %%% original eyelink functions:
    % EyelinkDrawCalTarget
    % EyelinkInitDefaults
    % EyelinkDoDriftCorrect
    % EyelinkDoDriftCorrection(el, scr.center(1), scr.center(2), 1, 1)

    KEY_CONFIRM = KbName('space');
    KEY_ESCAPE  = KbName('ESCAPE');
    KEY_ABORT   = KbName('q');
    KEY_EYE     = KbName('e'); 

    FlushEvents
    while KbCheck; end
    
    x = scr.center(1);
    y = scr.center(2);

    targ_size  = round(el.calibrationtargetsize / 100 * scr.size(1));
    inset_size = round(el.calibrationtargetwidth / 100 * scr.size(1));

    targ_rect  = CenterRectOnPoint([0 0 targ_size targ_size], x, y);
    inset_rect = CenterRectOnPoint([0 0 inset_size inset_size], x, y);

    while 1	

        if Eyelink('IsConnected') == 0
		    return
        end
        Eyelink('Command', 'heuristic_filter = ON');
        
        Screen('FillRect', el.window, el.backgroundcolour);
        Screen('FillOval', el.window, 0, targ_rect);
        Screen('FillOval', el.window, 0.5, inset_rect);
        DrawFormattedText(el.window, 'Fixe o olhar no ponto central e pressione [ESPAÇO]', 'center', round(scr.center(2) - (scr.ppd * 6)), [0,0,0]);
        
        Screen('Flip', el.window);
                
        Eyelink('DriftCorrStart', x, y, [], [], 1);
        
        key = 1;
        err = el.NO_REPLY;
        while err == el.NO_REPLY
            
	        err = Eyelink('CalResult');
            
            [key_press, ~, key_code] = KbCheck;
            if key_press
                if key_code(KEY_ESCAPE) || key_code(KEY_EYE)
                    err = el.ESC_KEY;
                elseif key_code(KEY_CONFIRM)
                    key = el.SPACE_BAR;
                    Eyelink('AcceptTrigger');
                elseif key_code(KEY_ABORT) 
                    error('ABORT KEY PRESSED !')    % abort the experiment (if 'q' is pressed)
                end
                Eyelink('SendKeyButton', key, 0, el.KB_PRESS);
            end
        end 
        
	    Screen('FillRect', el.window, el.backgroundcolour);

        Screen('Flip', el.window);
        
        if err == el.ESC_KEY || err == -1	    
		    EyelinkDoTrackerSetup(el);
        else
            Eyelink('ApplyDriftCorr');
        end
       
        if (err ~= el.ESC_KEY) 
            break
        end
    end
end