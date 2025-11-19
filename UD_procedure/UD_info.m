
function [info] = UD_info(info)
% 1Up/1Down PARAMETERS
info.UD_step_size_down = .02; %log10(1 + .10); % exponential steps of 20% in log10    
info.UD_step_size_up = info.UD_step_size_down;
info.UD_stop_criterion = 'trials';   
info.UD_stop_rule = 80;
info.UD_start_value = log10(90); % .3    
info.UD_xmax = log10(100);
info.UD_xmin = log10(40);

end


