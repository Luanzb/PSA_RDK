function [RDKcoordinates,dots] = hb_getRDK2( dots )
% Usage : RDKframes = hb_getRDK(dots)
% 
%  EXAMPLE USE
% % dots = [];
% % dots.params.fieldSize = [500 500];
% % dots.params.fieldShape = 1; % 0~1 : Spare factor, 1~ : Square-like field 
% % dots.params.nDots = 100; % number of dots
% % dots.params.coherence = .5; % 0~1 : Proportion of coherent dot (default/fallback)
% % dots.params.speed = 100; % Pixel per second (maintained across frame rates)
% % dots.params.duration = 2; %
% % dots.params.ori = 0; % 0~360 : Orientation for coherent motion
% % dots.params.frameRate = 60;
% % dots.params.dotLifeOption = 'N'; % 'N' for normal dist, 'U' for uniform dist
% % dots.params.dotLife = [50, 5]; % frames, [Mean, SD] of dots' life
% % 
% % NEW TEMPORAL COHERENCE PARAMETERS:
% % dots.params.coherenceSchedule = [0.0, 0.5, 0.0]; % Coherence values for each phase
% % dots.params.phaseDurations = [1.0, 1.0, 1.0]; % Duration in seconds for each phase
% % 
% % nFrames = dots.params.frameRate * dots.params.duration;
% % [RDKcoordinates,dots] = hb_getRDK(dots);
% % for frameIdx = 1:nFrames
% %     plot( RDKcoordinates(:, 1, frameIdx),RDKcoordinates(:, 2, frameIdx), 'kp' );
% %     axis([-1 1 -1 1]*.75*dots.circField.size(1));
% %     axis xy;
% %     drawnow;
% % end
% 
% Written by Hio-Been Han, hiobeen.han@seoultech.ac.kr, Written in 2016-08-01, Newly uploaded 2024-08-07
% Modified to include temporal coherence control and frame-rate independent speed
% Simple alternative for VCRDM Toolbox from Shadlen Lab (www.shadlenlab.columbia.edu) 
% 쉐들렌 코드가 구려서 직접 만들었음
% Visit Hio-Been Han's website: https://cogneuro.seoultech.ac.kr

warning off;
if nargin < 1
    disp(['No input argument detected. Make with default setting'])
    dots = [];
    dots.params.fieldSize = [200 200]; % Unit : Pixel
    dots.params.fieldShape = 1; % 0~1 : Spare factor, 1~ : Square-like field
    dots.params.nDots = 100; % number of dots
    dots.params.coherence = .5; % 0~1 : Default coherence (fallback if no schedule defined)
    
    dots.params.speed = 100; % Unit : Pixel per second (frame-rate independent)
    dots.params.duration = 2; % Total duration in seconds
    dots.params.ori = 0; % 0~360 : Orientation for coherent motion
    dots.params.frameRate = 60; % Monitor refresh rate
    dots.params.dotLifeOption = 'N'; % 'N' for normal dist, 'U' for uniform dist
    dots.params.dotLife = [50, 5]; % frames, [ Mean, SD ] of dots' life, SD is optional for 'N'
    
    % NEW: Temporal coherence control parameters
    dots.params.coherenceSchedule = []; % Will use default coherence if empty
    dots.params.phaseDurations = []; % Will use default behavior if empty
    
    nFrames = dots.params.frameRate * dots.params.duration;
end

%% Validate and setup temporal coherence parameters
if isempty(dots.params.coherenceSchedule) || isempty(dots.params.phaseDurations)
    % Use default behavior: constant coherence throughout
    dots.params.coherenceSchedule = dots.params.coherence;
    dots.params.phaseDurations = dots.params.duration;
elseif length(dots.params.coherenceSchedule) ~= length(dots.params.phaseDurations)
    error('coherenceSchedule and phaseDurations must have the same length');
elseif sum(dots.params.phaseDurations) ~= dots.params.duration
    warning('Sum of phaseDurations (%.2f) does not equal total duration (%.2f). Adjusting...', ...
        sum(dots.params.phaseDurations), dots.params.duration);
    % Scale phase durations to match total duration
    dots.params.phaseDurations = dots.params.phaseDurations * (dots.params.duration / sum(dots.params.phaseDurations));
end

%% Create frame-by-frame coherence mapping
nFrames = floor(dots.params.frameRate * dots.params.duration);
frameCoherence = zeros(1, nFrames);
currentFrame = 1;

for phaseIdx = 1:length(dots.params.coherenceSchedule)
    phaseFrames = round(dots.params.phaseDurations(phaseIdx) * dots.params.frameRate);
    endFrame = min(currentFrame + phaseFrames - 1, nFrames);
    frameCoherence(currentFrame:endFrame) = dots.params.coherenceSchedule(phaseIdx);
    currentFrame = endFrame + 1;
    if currentFrame > nFrames
        break;
    end
end

% Store the frame-by-frame coherence for reference
dots.params.frameCoherence = frameCoherence;

%% (1) Create Field
dots.circField = [];
dots.circField.size= dots.params.fieldSize; 
dots.circField.oval = hb_cropOval( ones(dots.circField.size), dots.params.fieldShape, 0);
dots.circField.coords = [];
[dots.circField.coords(:,1),dots.circField.coords(:,2)]= ind2sub( size(dots.circField.oval), find(dots.circField.oval==1));
dots.circField.randperm = hb_randperm( size(dots.circField.coords,1) );

% Handle 3D speed field if dimension parameter exists
if isfield(dots.params, 'dimension') && dots.params.dimension == 3
    temp = [];
    temp.gaussField = hb_gaussianBlob( dots.params.speedField.size, dots.params.speedField.sd );
    temp.gaussField_mincut = temp.gaussField - min(min(temp.gaussField));
    temp.gaussField_maxcut = temp.gaussField_mincut / max(max(temp.gaussField_mincut));    
    dots.circField.gaussField =temp.gaussField_maxcut *dots.params.speedField.maxvalue;
    clear temp;    
    if dots.params.fieldShape == 2
        dots.circField.gaussField = repmat( dots.circField.gaussField( :, round(size(dots.circField.gaussField, 1)*.5)),...
            [1, size(dots.circField.gaussField, 2)]);
    end
    
    plotOption = 0;
    if plotOption
        meshz(dots.circField.gaussField); %colormap(gray);
    end
end

%% (2) Set movement parameters and assign coherent/random dots for first frame
% Determine which dots will be coherent in the first frame
firstFrameCoherence = frameCoherence(1);
coherentDots_initial = rand(1, dots.params.nDots) <= firstFrameCoherence;

% Assign angles based on initial coherence
initialAngles = zeros(1, dots.params.nDots);
for dotIdx = 1:dots.params.nDots
    if coherentDots_initial(dotIdx)
        initialAngles(dotIdx) = dots.params.ori; % Coherent direction
    else
        initialAngles(dotIdx) = rand() * 360; % Random direction
    end
end

% Store the assigned angles (this maintains original logic)
dots.params.angles = initialAngles;

%% (3) Initial prototype of dot configuration
dots.dotInfo = [];
for dotIdx = 1:dots.params.nDots
    dots.dotInfo(dotIdx).dotIdx = dotIdx;
    dots.dotInfo(dotIdx).angle = dots.params.angles(dotIdx);
    
    % Calculate frame-rate independent displacement per frame
    % Speed is in pixels per second, so divide by frameRate to get pixels per frame
    dots.dotInfo(dotIdx).dx = dots.params.speed*sin(dots.params.angles(dotIdx)*pi/180)/dots.params.frameRate;
    dots.dotInfo(dotIdx).dy = dots.params.speed*cos(dots.params.angles(dotIdx)*pi/180)/dots.params.frameRate;
    
    % Initial position
    dots.dotInfo(dotIdx).XY = [dots.circField.coords(dots.circField.randperm(dotIdx),1)-(dots.circField.size(1)*.5),...
    dots.circField.coords(dots.circField.randperm(dotIdx),2)-(dots.circField.size(2)*.5)];
    
    % Set initial dot life
    switch(dots.params.dotLifeOption)
        case('U') % Uniform
            dots.dotInfo(dotIdx).remained_life = floor(rand()*dots.params.dotLife(1)*2)+1;
        case('N') % Normal
            if length(dots.params.dotLife) > 1
                dots.dotInfo(dotIdx).remained_life = floor(normrnd(dots.params.dotLife(1),dots.params.dotLife(2)))+1;
            else
                dots.dotInfo(dotIdx).remained_life = dots.params.dotLife(1);
            end
    end    
end

%% (4) Generate struct type dotFrames with temporal coherence control
dots.dotFrames = [];
dots.dotFrames(1).dotInfo = dots.dotInfo;
dots.circField.randperm_counter = dots.params.nDots;

for frameIdx = 2:nFrames
    % Copy previous frame's dot info
    dots.dotFrames(frameIdx).dotInfo = dots.dotFrames(frameIdx-1).dotInfo;
    
    % Get current frame's coherence level
    currentCoherence = frameCoherence(frameIdx);
    previousCoherence = frameCoherence(frameIdx-1);
    
    % NEW: Check if coherence level changed from previous frame
    coherenceChanged = (currentCoherence ~= previousCoherence);
    
    for dotIdx = 1:dots.params.nDots        
        refresh = 0;
        directionUpdated = 0; % NEW: Track if direction was updated
        
        % Handle dot life cycle
        life = dots.dotFrames(frameIdx-1).dotInfo(dotIdx).remained_life - 1;
        if life > 0
            dots.dotFrames(frameIdx).dotInfo(dotIdx).remained_life = life;
        else
            % DOT DEATH: Need to refresh with new position AND potentially new direction
            % based on current frame's coherence level
            if rand() <= currentCoherence
                % New dot should be coherent
                newAngle = dots.params.ori;
            else
                % New dot should move randomly
                newAngle = rand() * 360;
            end
            
            % Update angle and dx, dy for the refreshed dot
            dots.dotFrames(frameIdx).dotInfo(dotIdx).angle = newAngle;
            dots.dotFrames(frameIdx).dotInfo(dotIdx).dx = dots.params.speed*sin(newAngle*pi/180)/dots.params.frameRate;
            dots.dotFrames(frameIdx).dotInfo(dotIdx).dy = dots.params.speed*cos(newAngle*pi/180)/dots.params.frameRate;
            
            % Get new position
            if dots.circField.randperm_counter > length(dots.circField.randperm)
                % Generate new random permutation if we've used all positions
                dots.circField.randperm = hb_randperm(size(dots.circField.coords,1));
                dots.circField.randperm_counter = 1;
            end
            
            newdotIdx = dots.circField.randperm(dots.circField.randperm_counter);
            dots.circField.randperm_counter = dots.circField.randperm_counter + 1;
            XY = [dots.circField.coords(newdotIdx,1)-(dots.circField.size(1)*.5),...
                  dots.circField.coords(newdotIdx,2)-(dots.circField.size(2)*.5)];
            
            % Reset dot life
            switch(dots.params.dotLifeOption)
                case('U') % Uniform
                    dots.dotFrames(frameIdx).dotInfo(dotIdx).remained_life = floor(rand()*dots.params.dotLife(1)*2)+1;
                case('N') % Normal
                    if length(dots.params.dotLife) > 1
                        dots.dotFrames(frameIdx).dotInfo(dotIdx).remained_life = floor(normrnd(dots.params.dotLife(1),dots.params.dotLife(2)))+1;
                    else
                        dots.dotFrames(frameIdx).dotInfo(dotIdx).remained_life = dots.params.dotLife(1);
                    end
            end
            refresh = 1;
            directionUpdated = 1; % Direction was updated due to refresh
        end
            
        if ~refresh
            % NEW: Check if coherence changed and update direction for living dots
            if coherenceChanged
                % Determine new direction based on current coherence
                if rand() <= currentCoherence
                    % Dot should now be coherent
                    newAngle = dots.params.ori;
                else
                    % Dot should now move randomly
                    newAngle = rand() * 360;
                end
                
                % Update angle and movement deltas
                dots.dotFrames(frameIdx).dotInfo(dotIdx).angle = newAngle;
                dots.dotFrames(frameIdx).dotInfo(dotIdx).dx = dots.params.speed*sin(newAngle*pi/180)/dots.params.frameRate;
                dots.dotFrames(frameIdx).dotInfo(dotIdx).dy = dots.params.speed*cos(newAngle*pi/180)/dots.params.frameRate;
                directionUpdated = 1;
            end
            
            % DOT ALIVE: Continue moving (potentially in new direction if updated above)
            % Calculate new position based on current dx, dy
            if isfield(dots.params, 'dimension') && dots.params.dimension == 3
                % 3D version with gaussian speed field
                XYidx = round(( dots.dotFrames(frameIdx-1).dotInfo(dotIdx).XY ) + dots.circField.size*.5);
                if XYidx(1) < 1; XYidx(1)=1; end; 
                if XYidx(1) > dots.circField.size(1); XYidx(1)=dots.circField.size(1); end; 
                if XYidx(2) < 1; XYidx(2)=1; end; 
                if XYidx(2) > dots.circField.size(2); XYidx(2)=dots.circField.size(2); end; 
                
                dx = dots.dotFrames(frameIdx).dotInfo(dotIdx).dx * ...
                    dots.circField.gaussField( XYidx(1),XYidx(2) );                
                dy = dots.dotFrames(frameIdx).dotInfo(dotIdx).dy * ...
                    dots.circField.gaussField(  XYidx(1),XYidx(2) );
                XY = dots.dotFrames(frameIdx-1).dotInfo(dotIdx).XY+ [dx, dy];
            else
                % 2D version with constant speed - use current dx, dy
                dx = dots.dotFrames(frameIdx).dotInfo(dotIdx).dx;
                dy = dots.dotFrames(frameIdx).dotInfo(dotIdx).dy;                
                XY = dots.dotFrames(frameIdx-1).dotInfo(dotIdx).XY+ [dx, dy];
            end
            
            % Check if dot is still within the field boundary
            try
                inCircle = dots.circField.oval(round(XY(1)+(dots.circField.size(1)*.5)),round(XY(2)+(dots.circField.size(2)*.5)));
            catch
                inCircle = false;
            end
            
            if ~inCircle
                % DOT HIT BOUNDARY: Refresh with new position and new direction based on current coherence
                if rand() <= currentCoherence
                    % New dot should be coherent
                    newAngle = dots.params.ori;
                else
                    % New dot should move randomly
                    newAngle = rand() * 360;
                end
                
                % Update angle and dx, dy for the boundary-refreshed dot
                dots.dotFrames(frameIdx).dotInfo(dotIdx).angle = newAngle;
                dots.dotFrames(frameIdx).dotInfo(dotIdx).dx = dots.params.speed*sin(newAngle*pi/180)/dots.params.frameRate;
                dots.dotFrames(frameIdx).dotInfo(dotIdx).dy = dots.params.speed*cos(newAngle*pi/180)/dots.params.frameRate;
                
                % Get new position
                if dots.circField.randperm_counter > length(dots.circField.randperm)
                    % Generate new random permutation if we've used all positions
                    dots.circField.randperm = hb_randperm(size(dots.circField.coords,1));
                    dots.circField.randperm_counter = 1;
                end
                
                newdotIdx = dots.circField.randperm(dots.circField.randperm_counter);
                dots.circField.randperm_counter = dots.circField.randperm_counter + 1;
                XY = [dots.circField.coords(newdotIdx,1)-(dots.circField.size(1)*.5),...
                      dots.circField.coords(newdotIdx,2)-(dots.circField.size(2)*.5)];
            end
        end
        
        % Store final position for this frame
        dots.dotFrames(frameIdx).dotInfo(dotIdx).XY = XY;
    end
end

%% (4) Convert into 3-D matrix 
dots.RDKcoordinates = [];
for frameIdx = 1:nFrames
    XYs = [];
    for dotIdx = 1:dots.params.nDots
        XY = dots.dotFrames(frameIdx).dotInfo(dotIdx).XY;
        XYs = [XYs;XY];
    end
    dots.RDKcoordinates = cat(3, dots.RDKcoordinates, XYs);
end
RDKcoordinates = dots.RDKcoordinates;
return


%% Define CropOval
function resultImg = hb_cropOval(inputImg, spareFactor, bgrcolor)
if nargin < 3
    bgrcolor = 0;
end
hwidth = size(inputImg, 2) / 2.0;
hheight = size(inputImg, 1) / 2.0;

spareWidth = hwidth * spareFactor;
spareHeight = hheight * spareFactor;

[ww, hh] = meshgrid(1:hwidth, 1:hheight);

% simple ellipse equation gets us part three of your mask
mask_rightBottom = (((ww.^2)/spareWidth^2+(hh.^2)/spareHeight^2)<=1); 
mask_rightTop = flipud(mask_rightBottom);
mask_leftBottom = fliplr(mask_rightBottom);
mask_leftTop = flipud(mask_leftBottom);

mask_integrated = [mask_leftTop, mask_rightTop; ...
    mask_leftBottom, mask_rightBottom];

resultImg = inputImg;
[~,~,nDim] = size(resultImg);
if nDim == 1
    resultImg(mask_integrated(:,:)==0) = bgrcolor;
else
    multichannel_mask = repmat(mask_integrated,[1 1 nDim]);
    resultImg(multichannel_mask==0) = bgrcolor;
end

return

function shuffled_v = hb_Shuffle(v)
shuffled_v = v([hb_randperm(length(v))]);
return

function perm = hb_randperm(N)
%  USAGE -> perm= hb_randperm(N)
%  perm = hb_randperm(N) returns a vector containing a random permutation of the
%    integers 1:N.  For example, randperm(6) might be [2 4 5 6 1 3].
% 
[~, perm]=sort(rand([N,1]));
return

function f3 = hb_gaussianBlob(N,sigma)

if nargin < 1
    N = 30^2;
    sigma = sqrt(N) ^ 1.5;
end

% Generate basic gaussian blob
[x, y] = meshgrid(floor(-N/2):floor(N/2)-1, floor(-N/2):floor(N/2)-1);
f0 = exp(-x.^2/(2*sigma^2)-y.^2/(2*sigma^2));
f1 = f0./sum(f0(:));

% Range re-scaling
f2 = (f1 - min(min(f1)));
f3 = 127.5  + (127.5 * (f2 / max(max(f2))));

return