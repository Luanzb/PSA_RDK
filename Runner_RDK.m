
close all; clear; clc;

git_path = 'C:/Users/activ/OneDrive/Documentos/GitHub/PSA_RDK';
addpath(genpath(git_path));

pc_path = 'C:/Users/activ/OneDrive/Documentos/Projects/PSA_RDK';
addpath(genpath(pc_path));

cd(git_path);


% Ask subject information
answer = inputdlg({'Número sujeito', 'Número sessão','Coerência RDK'}, '', [1 26], {'', '',''});
sub_id = str2double(answer{1});
sub.ses_num = str2double(answer{2}); 


%%
% Load trial infos for this session
info_path = fullfile(sprintf('%s/Data/S%d/ses_%d_trlinfo_sub_%d*', pc_path, sub_id,sub.ses_num, sub_id));
info_file = dir(info_path);
load([info_file.folder '/' info_file.name])

sub.ses = answer{2};
sub.ses_num = str2double(answer{2});
sub.targ = str2double(answer{3});

if trl.feature_ses(1,sub.ses_num) == 1
    sub.RDK_color = 'Verde-Vermelho';
    trl.colorRDK = [1 2]; % 1 for green; 2 for red
else
    sub.RDK_color = 'Vermelho-Verde';
    trl.colorRDK = [2 1]; % 2 for red; 1 for green
end

% if rem(sub.id_num,2) == 1
%     sub.button = 'green (CW)';
% else
     sub.button = 'green (CCW)';
% end

% Ask (more) subject information
[sub] = Inputsubject(sub);
%save([info_file.folder '/' info_file.name], '-append', 'sub')

%% Run experiment

[resp,dots4,dots] = Screen_RDK(info,trl,sub,RDK,const,circle1);

%%
% 
% % Save data files
% sub.data_fname = sprintf('data_sub_%d_ses_%d_%s', sub.id_num, sub.ses_num, datestr(now,'yymmdd-HHMM')); %#ok<TNOW1,DATST>
% save(fullfile(sprintf('%s/Data/S%d/Task/%s', pc_path, sub.id_num), [sub.data_fname, '.mat']), 'info', 'trl', 'sub','resp','gabor','mask','time','srt', '-v7.3'); % resp
% 
% sub.eye_fname = 'FBAeye.edf';
% if exist(sub.eye_fname, 'file')
%     movefile(sub.eye_fname, sprintf('%s/Data/S%d/Eye/%s.edf', pc_path, sub.id_num, sub.data_fname));
% else
%     error('Eye-tracker data file not found!');
% end
% 
% 
% [s] = GetSRT(sub);
% 
% save(fullfile(sprintf('%s/Data/S%d/Task/%s', pc_path, sub.id_num), [sub.data_fname, '.mat']), 'info', 'trl', 'sub','resp','gabor','mask','time','srt','s', '-v7.3'); % resp
