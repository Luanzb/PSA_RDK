% Your current baseline colors
current_red_lab = trl.baseline_red_lab;    % [L*, a*, b*]
current_green_lab = trl.baseline_green_lab; % [L*, a*, b*]

% Calculate current hues
current_red_hue = atan2d(current_red_lab(3), current_red_lab(2));
current_green_hue = atan2d(current_green_lab(3), current_green_lab(2));
current_diff = mod(current_green_hue - current_red_hue, 360);

% Calculate needed adjustment
target_diff = 105;
needed_adjustment = target_diff - current_diff;


% Split the adjustment between both colors
adjustment_per_color = needed_adjustment / 2;

% Move red counter-clockwise, green clockwise
new_red_hue = current_red_hue - adjustment_per_color;
new_green_hue = current_green_hue + adjustment_per_color;

% Calculate current chromas
red_chroma = sqrt(current_red_lab(2)^2 + current_red_lab(3)^2);
green_chroma = sqrt(current_green_lab(2)^2 + current_green_lab(3)^2);

% New coordinates for both colors
new_red_a = red_chroma * cosd(new_red_hue);
new_red_b = red_chroma * sind(new_red_hue);
new_green_a = green_chroma * cosd(new_green_hue);
new_green_b = green_chroma * sind(new_green_hue);

new_red_lab = [current_red_lab(1), new_red_a, new_red_b];
new_green_lab = [current_green_lab(1), new_green_a, new_green_b];


% Convert to RGB for measurement
new_green_xyz = lab2xyz(new_green_lab, 'WhitePoint', white_point);
new_green_rgb = xyz2rgb(new_green_xyz, 'ColorSpace', 'srgb');
new_green_rgb = max(0, min(1, new_green_rgb));


% Convert to RGB for measurement
new_red_xyz = lab2xyz(new_red_lab, 'WhitePoint', white_point);
new_red_rgb = xyz2rgb(new_red_xyz, 'ColorSpace', 'srgb');
new_red_rgb = max(0, min(1, new_red_rgb));