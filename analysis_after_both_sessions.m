madc = '/home/kaneda/Documents/Projects/PSA_RDK/mADC-Model-master';
addpath(genpath(madc));

slan = '/home/kaneda/Documents/Projects/PSA_RDK/slanCM';
addpath(genpath(slan));

density = '/home/kaneda/Documents/Projects/PSA_RDK/Data density plot/DataDensity';
addpath(genpath(density));

load('/home/kaneda/Documents/Projects/PSA_RDK/colomap_v2.mat')
%%
valor = [1 720
    721 1440];

sac = zeros(720,1);
resp3 = zeros(720,1);
matrix = zeros(720,7);
response = zeros(720,1);


sacc_off = 300;
sacc_on = 170;


count = 1;

for subject = 1:3

    data_path = sprintf('/home/kaneda/Documents/Projects/PSA_RDK/Data/S%d/Task/', subject);
    addpath(genpath(data_path));

    for ses = 1


        files = fullfile(sprintf('%s/data_sub_%d_ses_%d_*.mat',data_path,subject,ses));
        file = dir(files);
        load(file.name);

         macrosacvec2 = s.macrosacvec;

         matrix(valor(ses,1):valor(ses,2),:) = [info.matrix(61:420,:); info.matrix(481:end,:)];
        sac_side = zeros(720,1);
        sac_side(matrix(valor(ses,1):valor(ses,2),4)==1 & macrosacvec2(:,4) < 0,1) = 1;
        sac_side(matrix(valor(ses,1):valor(ses,2),4)==2 & macrosacvec2(:,4) > 0,1) = 1;


        % data filtered by saccade accuracy (saccade error <= 2.6)

        sac_acc = hypot(RDK.EccDVA - abs(macrosacvec2(:,4)), abs(macrosacvec2(:,5))) >= 0 ...
            & hypot(RDK.EccDVA - abs(macrosacvec2(:,4)), abs(macrosacvec2(:,5))) <= 3.5;


        % data filtered by saccade latencies between 165 and 350 ms.

        sac_lat = macrosacvec2(:,1) >= sacc_on & macrosacvec2(:,1) <= sacc_off;

        sac_offset = macrosacvec2(:,2) >= 200;

        % create a vector of ones (non-rejected trials) and zeros
        % (rejected trials) regarding saccade latency, side and accuracy.

        sac1 = sac_lat(:,1)==1 & sac_side(:,1)==1 & sac_acc(:,1)==1 & sac_offset(:,1)==1;

        sac(valor(ses,1):valor(ses,2),1) = sac1;
        %%
      
        resp2 =  [resp(61:420,:); resp(481:end,:)];
        resp3(valor(ses,1):valor(ses,2),:) = resp2(:,1) == matrix(valor(ses,1):valor(ses,2),6);

        macvec1(valor(ses,1):valor(ses,2),:) = macrosacvec2;



    end

        pre_pc1 = resp3(matrix(:,1) == 1 & sac(:,1) == 1,1);% val high
        pre_pc2 = resp3(matrix(:,1) == 3 & sac(:,1) == 1,1);% val low
        pre_pc3 = resp3(matrix(:,1) == 2 & sac(:,1) == 1,1);%inval high
        pre_pc4 = resp3(matrix(:,1) == 4 & sac(:,1) == 1,1);% inval low

        pc1(subject,1) = (sum(pre_pc1) / size(pre_pc1,1)); % val high
        pc1(subject,2) = (sum(pre_pc2) / size(pre_pc2,1)); % val low
        pc1(subject,3) = (sum(pre_pc3) / size(pre_pc3,1)); % inval high
        pc1(subject,4) = (sum(pre_pc4) / size(pre_pc4,1)); % inval low


%% sensitivity (d' rpime)
        

    dprime1(subject,1) = sqrt(2) * norminv(pc1(subject,1));
    dprime1(subject,2) = sqrt(2) * norminv(pc1(subject,2));
    dprime1(subject,3) = sqrt(2) * norminv(pc1(subject,3));
    dprime1(subject,4) = sqrt(2) * norminv(pc1(subject,4));



    %%

    pre_1 = sum(sac(:,1)==1 & matrix(:,1)==1);
    pre_2 = sum(sac(:,1)==1 & matrix(:,1)==3);
    pre_3 = sum(sac(:,1)==1 & matrix(:,1)==2);
    pre_4 = sum(sac(:,1)==1 & matrix(:,1)==4);


    trial_1 = 100 - ((pre_1 / sum(matrix(:,1)==1)) * 100);
    trial_2 = 100 - ((pre_2 / sum(matrix(:,1)==3)) * 100);
    trial_3 = 100 - ((pre_3 / sum(matrix(:,1)==2)) * 100);
    trial_4 = 100 - ((pre_4 / sum(matrix(:,1)==4)) * 100);


    %              percentage excluded   total number
    %                           trials   val trials    
    trials(count).total_trls = [trial_1     pre_1 
                                trial_2     pre_2 
                                trial_3     pre_3    
                                trial_4     pre_4];

    vec(subject).macv = macvec1; 

end

macvec = [vec(1).macv;vec(2).macv;vec(3).macv];
dprime = mean(dprime1);
pc = mean(pc1);
%% Sensitivity (d) for both saccade congrency and feature probability

%subplot(3,3,1)

plot3 = bar([1 2],[dprime(1:2);dprime(3:4)],LineWidth=1.5,BarWidth=.4);
plot3(1).EdgeColor = [205,101,0]/255;
plot3(1).FaceColor = [205,101,0]/255;
plot3(2).FaceColor = [0 0 0];

plot3(1).EdgeAlpha = 1;
plot3(2).EdgeAlpha = 1;
plot3(1).FaceAlpha = .2;
plot3(2).FaceAlpha = .2;

plot3(1).LineWidth = 1.2;
plot3(2).LineWidth = 1.2;

hold on;

error = (std(dprime1) / sqrt(length(dprime1)));
% Get the x-coordinates of the bar centers for positioning the error bars
% This is the most reliable way for all MATLAB versions, especially grouped bars
x_coords = [plot3(1).XEndPoints(1) plot3(2).XEndPoints(1)... 
            plot3(1).XEndPoints(2) plot3(2).XEndPoints(2)];

% Plot the error bars, using 'k.' for black point markers (which can be hidden) 
% and 'LineStyle','none' to ensure only the vertical error lines are shown
errorbar(x_coords, mean(dprime1), error, 'Color',[.4 .4 .4], 'LineStyle', 'none', 'CapSize', 0,'LineWidth',1.5);

hold on;

scatter([repelem(.85,3)], dprime1(:,1),30,'filled','o','MarkerFaceColor',[205,101,0]/255)
scatter([repelem(1.15,3)], dprime1(:,2),30,'filled','o','MarkerFaceColor',[0 0 0])
scatter([repelem(1.85,3)], dprime1(:,3),30,'filled','o','MarkerFaceColor',[205,101,0]/255)
scatter([repelem(2.15,3)], dprime1(:,4),30,'filled','o','MarkerFaceColor',[0 0 0])
title('Discrimination performance','FontSize',6);

name={'Congruent';'Incongruent'};
set(gca,'xticklabel',name,'FontWeight','normal');
ylabel('Sensitivity (d)','FontWeight', 'bold','FontSize',6);
xlabel('Saccadic Cue','FontWeight','bold','FontSize',6);

%-------------------------------------------------------------------------

hold on
ax = gca;
ax.LineWidth = .8;
ax.FontSize = 6;
set(gca,'TickDir','out');
set(gca, 'Box', 'off');
 ax.YLim = [0 2.8];

leg = legend(plot3, {'High';'Low';},'Location','northeast','FontSize', 6);
hold on;
legend('boxoff');
title(leg,'Color Probability');

%%

subplot(3,3,2)

plot3 = bar([mean(dprime(1:2));mean(dprime(3:4))],LineWidth=1.5,BarWidth=.4);
plot3.EdgeColor = [205,101,0]/255;
plot3.FaceColor = [205,101,0]/255;

name={'Congruent';'Incongruent'};
set(gca,'xticklabel',name,'FontWeight','normal');
ylabel('Sensitivity (d)','FontWeight', 'bold','FontSize',6);
xlabel('Saccadic Cue','FontWeight','bold','FontSize',6);

hold on
ax = gca;
ax.LineWidth = .8;
ax.FontSize = 6;
set(gca,'TickDir','out');
set(gca, 'Box', 'off');
 ax.YLim = [0 2.5];


%%

subplot(3,3,3)

plot3 = bar([mean([dprime(1) dprime(3)]);mean([dprime(2) dprime(4)])],LineWidth=1.5,BarWidth=.4);
plot3.EdgeColor = [205,101,0]/255;
plot3.FaceColor = [205,101,0]/255;

name={'High';'Low'};
set(gca,'xticklabel',name,'FontWeight','normal');
ylabel('Sensitivity (d)','FontWeight', 'bold','FontSize',6);
xlabel('Color probability','FontWeight','bold','FontSize',6);

hold on
ax = gca;
ax.LineWidth = .8;
ax.FontSize = 6;
set(gca,'TickDir','out');
set(gca, 'Box', 'off');
 ax.YLim = [0 2.5];

 %% Saccade accuracy

[ dmap, limits,fudge ] =dataDensity(rmmissing(macvec(:,4)),rmmissing(macvec(:,5)),1920,1080,[-26.6667 26.6667 -15 15],.001);

%% Saccade accuracy

subplot(3,3,4)
%cmap = colormap(slanCM('viridis',30)); % flipud( % colormap(viridis);
cmap = colormap(CustomColormap);
% cm =  imagesc(sacc_accuracy);
set(gca, 'YDir','normal');


[C,h] = contourf(dmap);
h.EdgeColor = 'flat';

viscircles([(960-216) (1080/2); (960+216) (1080/2)], [(72)  (72)], 'Color', 'w','LineStyle',':','LineWidth',1.2,'EnhanceVisibility',0);
%viscircles([(960-216) (1080/2); (960+216) (1080/2)], [(126)  (126)], 'Color', 'y','LineStyle',':','LineWidth',1.2,'EnhanceVisibility',0);

clb =   colorbar;
clb.Units = "normalized";
clb.Box = "off";
clb.LineWidth = .8;
clb.TickDirection = "out";
clb.Location = "northoutside";
hold on;

scatter(960, 1080/2, 10, 'w', 'filled', 'MarkerEdgeColor', 'w');

ax = gca;
set(gca,'TickDir','out');
set(gca, 'Box', 'off','XColor','k','YColor','k','XLimitMethod','tickaligned');
axis([654 1266 368 1080-368]);

ax.FontSize = 6;
ax.LineWidth = .8;


ax.XTick = [960-216 1920/2 960+216];
ax.YTick = [432 1080/2 648]; % 36 px (1dva). 36px*2dva=72 px

ax.XTickLabel = ["-6";"0";"6"];
ax.YTickLabel = ["-3";"0";"3"];
hold on;

xlabel('Saccade X-endpoint(º)','FontSize',6);
ylabel('Y-end.(º)','FontSize',6);


%% Saccade Reaction Times

lat1 = macvec(macvec(:,1) <= 200,1);
lat2 = macvec(macvec(:,1) >= 201 & macvec(:,1) <= 250,1);
lat3 = macvec(macvec(:,1) >= 251 & macvec(:,1) <= 300,1);
lat4 = macvec(macvec(:,1) >= 301 & macvec(:,1) <= 350,1);
lat5 = macvec(macvec(:,1) >= 351 & macvec(:,1) <= 400,1);
lat6 = macvec(macvec(:,1) >= 401,1);

subplot(3,3,5)
nn = 30;
bw = 5;
histogram(macvec(:,1),nn,'BinWidth',bw,"FaceColor",[1 1 1],"FaceAlpha",1,"EdgeColor",[1 1 1],"LineWidth",.8); hold on;

% Define rectangle vertices (x and y coordinates of all 4 corners)
% Order matters - we'll go clockwise from bottom-left
x1 = [170 300 300 170];  % x-coordinates of corners
y1 = [0 0 85 85];  % y-coordinates of corners

% Create a blue transparent rectangle
%patch(x, y, [205,101,0]/255,'FaceAlpha', .1,'EdgeColor', 'none','LineWidth', 1,'LineStyle', '--'); 
patch(x1, y1, [0.135826164342461,0.403526180316092,0.373020081220419],'FaceAlpha', .2,'EdgeColor', 'none','LineWidth', 1,'LineStyle', '--'); 
hold on;

histogram(lat1(:,1),nn,'BinWidth',bw,"FaceColor",[0.152187949374577,0.193376188218391,0.207947817613252],"FaceAlpha",.7,"EdgeColor",[0.152187949374577,0.193376188218391,0.207947817613252],"LineWidth",1.1); hold on;
histogram(lat2(:,1),nn,'BinWidth',bw,"FaceColor",[0.140500960065923,0.343483325431034,0.325856577332657],"FaceAlpha",.7,"EdgeColor",[0.140500960065923,0.343483325431034,0.325856577332657],"LineWidth",1.1); hold on;
histogram(lat3(:,1),nn,'BinWidth',bw,"FaceColor",[0.128813970757268,0.493590462643678,0.443765337052062],"FaceAlpha",.7,"EdgeColor",[0.128813970757268,0.493590462643678,0.443765337052062],"LineWidth",1.1); hold on;
histogram(lat4(:,1),nn,'BinWidth',bw,"FaceColor",[0.127176137931035,0.645865206896552,0.524432379310345],"FaceAlpha",.7,"EdgeColor",[0.127176137931035,0.645865206896552,0.524432379310345],"LineWidth",1.1); hold on;
histogram(lat5(:,1),nn,'BinWidth',bw,"FaceColor",[0.381658379310345,0.793064413793103,0.375673862068966],"FaceAlpha",.7,"EdgeColor",[0.381658379310345,0.793064413793103,0.375673862068966],"LineWidth",1.1); hold on;
histogram(lat6(:,1),nn,'BinWidth',bw,"FaceColor",[0.818864551724138,0.883942103448276,0.108638034482759],"FaceAlpha",.7,"EdgeColor",[0.818864551724138,0.883942103448276,0.108638034482759],"LineWidth",1.1); hold on;

xlabel('SRT (ms)','FontSize',6);
ylabel('Nº of Trials','FontSize',6);

    set(gca,'TickDir','out');
    set(gca, 'Box', 'off');
    ax = gca;
    ax.FontSize = 6;
    ax.LineWidth = .8;
    ax.XLim = [100 450];
    ax.YLim = [0 85];

    x = xline(median(rmmissing(macvec(:,1))),'-'); hold on;
    x.LineWidth = 1;
    x.Color = [0 0.4 1];

 %% Targ offset - Sacc onset

lat1 = macvec(macvec(:,1) <= 200,1);
lat2 = macvec(macvec(:,1) >= 201 & macvec(:,1) <= 250,1);
lat3 = macvec(macvec(:,1) >= 251 & macvec(:,1) <= 300,1);
lat4 = macvec(macvec(:,1) >= 301 & macvec(:,1) <= 350,1);
lat5 = macvec(macvec(:,1) >= 351 & macvec(:,1) <= 400,1);
lat6 = macvec(macvec(:,1) >= 401,1);

lat1 = 190-lat1;
lat2 = 190-lat2;
lat3 = 190-lat3;
lat4 = 190-lat4;
lat5 = 190-lat5;
lat6 = 190-lat6;

subplot(3,3,6)

nn = 30;
bw = 5;

histogram(macvec(:,1),nn,'BinWidth',bw,"FaceColor",[1 1 1],"FaceAlpha",1,"EdgeColor",[1 1 1],"LineWidth",1.3); hold on;

% Define rectangle vertices (x and y coordinates of all 4 corners)
% Order matters - we'll go clockwise from bottom-left
x1 = [-100 0 0 -100];  % x-coordinates of corners
y1 = [0 0 85 85];  % y-coordinates of corners

% Create a blue transparent rectangle
%patch(x, y, [205,101,0]/255,'FaceAlpha', .1,'EdgeColor', 'none','LineWidth', 1,'LineStyle', '--'); 
patch(x1, y1, [0.135826164342461,0.403526180316092,0.373020081220419],'FaceAlpha', .2,'EdgeColor', 'none','LineWidth', 1,'LineStyle', '--'); 
hold on;

histogram(lat1(:,1),nn,'BinWidth',bw,"FaceColor",[0.152187949374577,0.193376188218391,0.207947817613252],"FaceAlpha",.7,"EdgeColor",[0.152187949374577,0.193376188218391,0.207947817613252],"LineWidth",1.1); hold on;
histogram(lat2(:,1),nn,'BinWidth',bw,"FaceColor",[0.140500960065923,0.343483325431034,0.325856577332657],"FaceAlpha",.7,"EdgeColor",[0.140500960065923,0.343483325431034,0.325856577332657],"LineWidth",1.1); hold on;
histogram(lat3(:,1),nn,'BinWidth',bw,"FaceColor",[0.128813970757268,0.493590462643678,0.443765337052062],"FaceAlpha",.7,"EdgeColor",[0.128813970757268,0.493590462643678,0.443765337052062],"LineWidth",1.1); hold on;
histogram(lat4(:,1),nn,'BinWidth',bw,"FaceColor",[0.127176137931035,0.645865206896552,0.524432379310345],"FaceAlpha",.7,"EdgeColor",[0.127176137931035,0.645865206896552,0.524432379310345],"LineWidth",1.1); hold on;
histogram(lat5(:,1),nn,'BinWidth',bw,"FaceColor",[0.381658379310345,0.793064413793103,0.375673862068966],"FaceAlpha",.7,"EdgeColor",[0.381658379310345,0.793064413793103,0.375673862068966],"LineWidth",1.1); hold on;
histogram(lat6(:,1),nn,'BinWidth',bw,"FaceColor",[0.818864551724138,0.883942103448276,0.108638034482759],"FaceAlpha",.7,"EdgeColor",[0.818864551724138,0.883942103448276,0.108638034482759],"LineWidth",1.1); hold on;


xlabel('Targ offset - Sacc onset','FontSize',12);
ylabel('Nº of Trials','FontSize',12);

    set(gca,'TickDir','out');
    set(gca, 'Box', 'off');
    ax = gca;
    ax.FontSize = 6;
    ax.LineWidth = .8;
    ax.XLim = [-250 100];
    ax.YLim = [0 85];

    x = xline(0,'-'); hold on;
    x.LineWidth = 1;
    x.Color = [0 0.4 1];


%% Proportion correct both saccade and color relevance

subplot(3,3,7)

plot3 = bar([1 2],[pc(1:2)*100;pc(3:4)*100],LineWidth=1.5,BarWidth=.4);
plot3(1).EdgeColor = [205,101,0]/255;
plot3(1).FaceColor = [205,101,0]/255;
plot3(2).FaceColor = [0 0 0];

plot3(1).EdgeAlpha = 1;
plot3(2).EdgeAlpha = 1;
plot3(1).FaceAlpha = .2;
plot3(2).FaceAlpha = .2;

plot3(1).LineWidth = 1.2;
plot3(2).LineWidth = 1.2;

hold on;
error = (std(pc1) / sqrt(length(pc1))) * 100;
% Get the x-coordinates of the bar centers for positioning the error bars
% This is the most reliable way for all MATLAB versions, especially grouped bars
x_coords = [plot3(1).XEndPoints(1) plot3(2).XEndPoints(1)... 
            plot3(1).XEndPoints(2) plot3(2).XEndPoints(2)];

% Plot the error bars, using 'k.' for black point markers (which can be hidden) 
% and 'LineStyle','none' to ensure only the vertical error lines are shown
errorbar(x_coords, mean(pc1)*100, error, 'k', 'LineStyle', 'none', 'CapSize', 0,'LineWidth',1.5);

hold on;

scatter([repelem(.85,3)], pc1(:,1)*100,30,'filled','o','MarkerFaceColor',[205,101,0]/255)
scatter([repelem(1.15,3)], pc1(:,2)*100,30,'filled','o','MarkerFaceColor',[0 0 0])
scatter([repelem(1.85,3)], pc1(:,3)*100,30,'filled','o','MarkerFaceColor',[205,101,0]/255)
scatter([repelem(2.15,3)], pc1(:,4)*100,30,'filled','o','MarkerFaceColor',[0 0 0])


title('Discrimination performance','FontSize',6);

name={'Congruent';'Incongruent'};
set(gca,'xticklabel',name,'FontWeight','normal');
ylabel('Proportion Correct (%)','FontWeight', 'bold','FontSize',6);
xlabel('Saccadic Cue','FontWeight','bold','FontSize',6);

%-------------------------------------------------------------------------

hold on
ax = gca;
ax.LineWidth = .8;
ax.FontSize = 6;
set(gca,'TickDir','out');
set(gca, 'Box', 'off');
 ax.YLim = [50 100];

leg = legend(plot3, {'High';'Low';},'Location','northeast','FontSize', 6);
hold on;
legend('boxoff');
title(leg,'Color Probability');


%%

subplot(3,3,8)

plot3 = bar([mean(pc(1:2))*100;mean(pc(3:4))*100],LineWidth=1.5,BarWidth=.4);
plot3.EdgeColor = [205,101,0]/255;
plot3.FaceColor = [205,101,0]/255;

name={'Congruent';'Incongruent'};
set(gca,'xticklabel',name,'FontWeight','normal');
ylabel('Proportion Correct (%)','FontWeight', 'bold','FontSize',6);
xlabel('Saccadic Cue','FontWeight','bold','FontSize',6);

hold on
ax = gca;
ax.LineWidth = .8;
ax.FontSize = 6;
set(gca,'TickDir','out');
set(gca, 'Box', 'off');
 ax.YLim = [50 100];


%%

subplot(3,3,9)

plot3 = bar([mean([pc(1) pc(3)])*100;mean([pc(2) pc(4)])*100],LineWidth=1.5,BarWidth=.4);
plot3.EdgeColor = [205,101,0]/255;
plot3.FaceColor = [205,101,0]/255;

name={'High';'Low'};
set(gca,'xticklabel',name,'FontWeight','normal');
ylabel('Proportion Correct (%)','FontWeight', 'bold','FontSize',6);
xlabel('Color probability','FontWeight','bold','FontSize',6);

hold on
ax = gca;
ax.LineWidth = .8;
ax.FontSize = 6;
set(gca,'TickDir','out');
set(gca, 'Box', 'off');
 ax.YLim = [50 100];
