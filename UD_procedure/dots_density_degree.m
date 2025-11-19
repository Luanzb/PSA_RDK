% Define your parameters
desired_density = 1.4; % dots/deg²
aperture_diameter_deg = 4.0; % degrees

% Calculate number of dots
aperture_radius_deg = aperture_diameter_deg / 2;
aperture_area_deg2 = pi * (aperture_radius_deg ^ 2);
n_dots = round(desired_density * aperture_area_deg2);

fprintf('For density %.1f dots/deg² in a %.1f° aperture:\n', desired_density, aperture_diameter_deg);
fprintf('You need %d dots\n', n_dots);