% Your current isoluminant colors
red_rgb_iso = [242 0 0]/255;
green_rgb_iso = [0 170 0]/255;

white_point = [0.95047, 1.00000, 1.08883];
 
% Convert to L*a*b*
red_xyz = rgb2xyz(red_rgb_iso, 'ColorSpace', 'srgb');
green_xyz = rgb2xyz(green_rgb_iso, 'ColorSpace', 'srgb');
red_lab = xyz2lab(red_xyz, 'WhitePoint', white_point);
green_lab = xyz2lab(green_xyz, 'WhitePoint', white_point);

% Current hue difference
current_diff = 96; % Your measured value
target_diff = 105;
needed_adjustment = target_diff - current_diff;

fprintf('Need to increase hue difference by %.1f°\n', needed_adjustment);

% Strategy: Keep red fixed, adjust green
% Calculate current chroma (saturation) for both colors
red_chroma = sqrt(red_lab(2)^2 + red_lab(3)^2);
green_chroma = sqrt(green_lab(2)^2 + green_lab(3)^2);

% Calculate current hues
red_hue = atan2d(red_lab(3), red_lab(2));
green_hue = atan2d(green_lab(3), green_lab(2));

% Increase green's hue angle by the needed adjustment
new_green_hue = green_hue + needed_adjustment;

% Convert back to a*b* coordinates (keep same chroma)
new_green_a = green_chroma * cosd(new_green_hue);
new_green_b = green_chroma * sind(new_green_hue);

% Create new green L*a*b* (same L* for isoluminance!)
new_green_lab = [green_lab(1), new_green_a, new_green_b];

% Convert back to RGB for verification
new_green_xyz = lab2xyz(new_green_lab, 'WhitePoint', white_point);
new_green_rgb = xyz2rgb(new_green_xyz, 'ColorSpace', 'srgb');

% Check if RGB values are in range [0, 1]
if any(new_green_rgb < 0 | new_green_rgb > 1)
    fprintf('Warning: New green RGB out of gamut: [%.3f, %.3f, %.3f]\n', new_green_rgb);
    % You may need to reduce chroma slightly
    new_green_rgb = max(0, min(1, new_green_rgb)); % Clamp to valid range
end

% Verify the new hue difference
new_green_xyz_check = rgb2xyz(new_green_rgb, 'ColorSpace', 'srgb');
new_green_lab_check = xyz2lab(new_green_xyz_check, 'WhitePoint', white_point);
new_green_hue = atan2d(new_green_lab_check(3), new_green_lab_check(2));
new_diff = mod(new_green_hue - red_hue, 360);

fprintf('New hue difference: %.1f°\n', new_diff);
fprintf('New green RGB: [%.3f, %.3f, %.3f]\n', new_green_rgb);