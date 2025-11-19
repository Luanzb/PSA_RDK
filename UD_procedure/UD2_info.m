
function [info] = UD2_info(info)
% 1Up/1Down PARAMETERS
info.UD2_step_size_down = .02; %log10(1 + .10); % exponential steps of 20% in log10    
info.UD2_step_size_up = info.UD2_step_size_down;
info.UD2_stop_criterion = 'trials';   
info.UD2_stop_rule = 80;
info.UD2_start_value = log10(90); % .3    
info.UD2_xmax = log10(100);
info.UD2_xmin = log10(40);

end