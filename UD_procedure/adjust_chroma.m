function [new_color_rgb] = adjust_chroma(color_chroma_scale, baseline_color_lab)
    % PURPOSE: Adjust ONLY chroma while preserving original hue and lightness
    % INPUT:
    %   red_rgb, green_rgb: current RGB colors (can be ignored if we use baseline_lab)
    %   red_chroma_scale, green_chroma_scale: saturation multipliers (0.5-1.0)
    %   baseline_red_lab, baseline_green_lab: ORIGINAL isoluminant colors with 105° hue difference
    
    white_point = [0.95047, 1.00000, 1.08883];
    
    % STEP 1: Calculate ORIGINAL hue angles from baseline color
    % These never change throughout the staircase!
    baseline_color_hue = atan2d(baseline_color_lab(3), baseline_color_lab(2));
    
    % STEP 2: Calculate ORIGINAL chroma from baseline colors
    baseline_color_chroma = sqrt(baseline_color_lab(2)^2 + baseline_color_lab(3)^2);
    
    % STEP 3: Scale ONLY the chroma - hue and lightness stay the same!
    new_color_chroma = baseline_color_chroma * color_chroma_scale;
    
    % STEP 4: Calculate new a*b* coordinates using ORIGINAL hue angles
    new_color_a = new_color_chroma * cosd(baseline_color_hue);
    new_color_b = new_color_chroma * sind(baseline_color_hue);
    
    % STEP 5: Create new L*a*b* colors - preserve original L* and use original hues!
    new_color_lab = [baseline_color_lab(1), new_color_a, new_color_b];  % Same L*, new a*b*
    
    % STEP 6: Convert back to RGB
    new_color_xyz = lab2xyz(new_color_lab, 'WhitePoint', white_point);
    new_color_rgb = xyz2rgb(new_color_xyz, 'ColorSpace', 'srgb');
    
    % STEP 7: Clamp to valid range
    new_color_rgb = max(0, min(1, new_color_rgb));
end