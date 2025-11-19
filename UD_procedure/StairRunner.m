
close all; clear; clc;


git_path = '/home/kaneda/Documents/GitHub/PSA_RDK';
addpath(genpath(git_path));

pc_path = '/home/kaneda/Documents/Projects/PSA_RDK';
addpath(genpath(pc_path));

pal_path = '/home/kaneda/Documents/Palamedes1_11_11/Palamedes';
addpath(genpath(pal_path));


% Ask subject number
answer = inputdlg({'Número Sujeito','Sessão'}, '', [1 25]);

sub.id = answer{1};  sub.id_num = str2double(answer{1});
sub.ses = answer{2}; sub.ses_num = str2double(answer{2});


info_path = fullfile(sprintf('%s/Data/S%d/Staircase/ses_%d_staircase_sub_%d_*', pc_path,sub.id_num,sub.ses_num,sub.id_num));
info_file = dir(info_path);
load([info_file.folder '/' info_file.name])


[sub,info] = Inputsubject2(sub,info);


if sub.treino == 's'

        % which kind of training?
    answertr = inputdlg({'Treino normal? s/n'}, '', [1 25]);


    if string(answertr) ~= 's'
        info.colorsat = 1; % easy training - colors full saturated
    else
        info.colorsat = 0;
    end

end


%% Run experiment

[UD,UD2,time,dots] = Stair_On_Screen(info,trl,sub,mat,RDK,const,circle1);



if sub.treino ~= 's'
    UD_analysis(UD,UD2, trl,time)

    save(fullfile(sprintf('%s/Data/S%d/Staircase/%s', pc_path, sub.id_num), [info_file.name]), 'UD','time','info','trl','sub','mat','RDK','const','circle1', '-v7.3');
end

