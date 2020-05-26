%% plots trajectories during a trial of the Corsi block-tapping task
group = 'day10';
subj = 3;
trial = {14, 13};
targets = [.52 .72 .55 .59 .53 .6 .65 .67 .69
           .32 .22 .27 .18 .21 .3 .26 .20 .34];

figure(1); clf
for i = 1:2
    t = trial{i};
    if i == 1
        p = data.(group){subj}.unimanual;
    else
        p = data.(group){subj}.bimanual;
    end
    subplot(1,2,i); hold on
    scatter(0.6,0.4,2000,'b','filled','MarkerFaceAlpha',0.4)
    scatter(targets(1,:),targets(2,:),3000,'k','filled','MarkerFaceAlpha',0.4)
    quiver(p.trajFilt{t}(p.analysisTime{t},1),...
        p.trajFilt{t}(p.analysisTime{t},2),...
        cos(p.initDir{t})',sin(p.initDir{t})',0.5,'LineWidth',2) % initial reach direction
%     quiver(p.trajFilt{t}(p.analysisTime{t},1),...
%         p.trajFilt{t}(p.analysisTime{t},2),...
%         cos(p.targAngle{t})',sin(p.targAngle{t})',0.5,'LineWidth',2) % direction of target that will be pressed
    plot(p.trajFilt{t}(:,1),p.trajFilt{t}(:,2),'k')
    plot(p.trajFilt{t}(p.press{t},1),p.trajFilt{t}(p.press{t},2),'r.','MarkerSize',15)
    axis([0.47 0.77 0.13 0.43])
    axis square
    if i == 1
        title('Unimanual')
    else
        title('Bimanual')
    end
end
%% plots the reach direction error of every trial
rng(1);
space = 6;
figure(2); clf
for j = 1:length(groups)
    subplot(3,1,j); hold on
    plot([0 space*length(subj_name2)+1],[0 0],'k','HandleVisibility','off')
    for i = 1:Nsubj(j)
        dir = d.(groups{j}){i}.initDir*180/pi;
        p = data.(groups{j}){i};
        
        n = 30;
        plot(space*repmat(i,[1 n])-3+0.3*(rand(1,n)-0.5),dir(1:30),'.','Color',colors(1,:),'MarkerSize',10)
        n = length(p.unimanual.error);
        plot(space*repmat(i,[1 n])-2+0.3*(rand(1,n)-0.5),p.unimanual.error,'.','Color',colors(2,:),'MarkerSize',10)
        
        n = 100;
        plot(space*repmat(i,[1 n])-1+0.3*(rand(1,n)-0.5),dir(31:end),'.','Color',colors(3,:),'MarkerSize',10)
        n = length(p.bimanual.error);
        plot(space*repmat(i,[1 n])+0.3*(rand(1,n)-0.5),p.bimanual.error,'.','Color',colors(4,:),'MarkerSize',10)
    end
    xticks(space-1:space:space*Nsubj(j))
    xticklabels(subj_name2)
    axis([space-4 space*Nsubj(j)+1 -180 180])
    yticks(-180:60:180)
    if j == 1
        title('2-day')
    elseif j == 2
        title('5-day')
        ylabel('Reach direction error')
    elseif j == 3
        title('10-day')
        legend({'Baseline (p2p)','Baseline (Corsi)','Bimanual (p2p)','Bimanual (Corsi)'},'Location','northwest')
    end
end
%% plots the mean and std of reach direction error across trials
space = 6;
figure(3); clf
for j = 1:length(groups)
    subplot(3,1,j); hold on
    plot([0 space*length(subj_name2)+1],[0 0],'k','HandleVisibility','off')
    for i = 1:Nsubj(j)
        dir = d.(groups{j}){i}.initDir*180/pi;
        p = data.(groups{j}){i};
        errorbar(space*i-3,mean(dir(1:30)),std(dir(1:30)),'.','Color',colors(1,:),'MarkerSize',20,'LineWidth',1.5)
        errorbar(space*i-2,mean(p.unimanual.error),p.unimanual.std,'.','Color',colors(2,:),'MarkerSize',20,'LineWidth',1.5)
        errorbar(space*i-1,mean(dir(31:end)),std(dir(31:end)),'.','Color',colors(3,:),'MarkerSize',20,'LineWidth',1.5)
        errorbar(space*i,mean(p.bimanual.error),p.bimanual.std,'.','Color',colors(4,:),'MarkerSize',20,'LineWidth',1.5)
    end
    xticks(space-1:space:space*Nsubj(j))
    xticklabels(subj_name2)
    axis([space-4 space*Nsubj(j)+1 -60 60])
    yticks(-90:30:90)
    if j == 1
        title('2-day')
    elseif j == 2
        title('5-day')
        ylabel('Reach direction error')
    elseif j == 3
        title('10-day')
        legend({'Baseline (p2p)','Baseline (Corsi)','Bimanual (p2p)','Bimanual (Corsi)'},'Location','northwest')
    end
end
%% plots the smoothed kernel of the reach direction errors
col = lines;
col = col(1:7,:);
figure(4); clf
for j = 1:length(groups)
    [baseline_p2p,baseline_Corsi,bimanual_p2p,bimanual_Corsi] = deal([]);
    for i = 1:Nsubj(j)
        p = data.(groups{j}){i};
        baseline_p2p = [baseline_p2p d.(groups{j}){i}.initDir(1:30)*180/pi];
        bimanual_p2p = [bimanual_p2p d.(groups{j}){i}.initDir(31:end)*180/pi];
        baseline_Corsi = [baseline_Corsi data.(groups{j}){i}.unimanual.error];
        bimanual_Corsi = [bimanual_Corsi data.(groups{j}){i}.bimanual.error];
        
        pd = fitdist(d.(groups{j}){i}.initDir(1:30)'*180/pi,'Normal');
        fits.baseline_p2p{j}(i) = pd.sigma;
        
        pd = fitdist(d.(groups{j}){i}.initDir(31:end)'*180/pi,'Normal');
        fits.bimanual_p2p{j}(i) = pd.sigma;
        
        pd = fitdist(data.(groups{j}){i}.unimanual.error','Normal');
        fits.baseline_Corsi{j}(i) = pd.sigma;
        
        pd = fitdist(data.(groups{j}){i}.bimanual.error','Normal');
        fits.bimanual_Corsi{j}(i) = pd.sigma;
    end
    
    subplot(1,4,1); hold on
    [f,xi] = ksdensity(baseline_p2p);
    plot(xi,f,'Color',col(j,:),'LineWidth',2);
    if j == 3
        axis([-90 90 0 0.06])
        xticks(-90:45:90)
        yticks(0:0.02:0.08)
        title('Baseline (p2p)')
        ylabel('Probability density')
    end
    
    subplot(1,4,2); hold on
    [f,xi] = ksdensity(baseline_Corsi);
    plot(xi,f,'Color',col(j,:),'LineWidth',2);
    if j == 3
        axis([-90 90 0 0.06])
        xticks(-90:45:90)
        yticks([])
        title('Baseline (Corsi)')
    end
    
    subplot(1,4,3); hold on
    [f,xi] = ksdensity(bimanual_p2p);
    plot(xi,f,'Color',col(j,:),'LineWidth',2);
    if j == 3
        axis([-90 90 0 0.06])
        xticks(-90:45:90)
        yticks([])
        title('Bimanual (p2p)')
    end
    
    subplot(1,4,4); hold on
    [f,xi] = ksdensity(bimanual_Corsi);
    plot(xi,f,'Color',col(j,:),'LineWidth',2);
    if j == 3
        axis([-90 90 0 0.06])
        xticks(-90:45:90)
        yticks([])
        title('Bimanual (Corsi)')
        legend({'2-day','5-day','10-day'})
    end
end

%% plot movement times
rng(1);
col = lines;
col = col(1:7,:);

col2 = [173 216 230
        255 160 122]./255;
    
figure(5); clf
for j = 1:length(groups)
    subplot(3,1,j); hold on
    for p = 1:Nsubj(j)
        for k = 1:length(hands)
            times = [];
            allTimes = data.(groups{j}){p}.(hands{k}).movementTime;
            for i = 1:length(allTimes)
                if ~isempty(allTimes{i})
                    times = [times; allTimes{i}/1000];
                    idx = times>10; % remove outliers (movement times > 10 secs
                    times(idx) = NaN;
                end
            end
            plot(3*p+(k-3)+(rand(length(times),1)-0.5)*0.3,times,'.','Color',col2(k,:),'MarkerSize',8)
            plot(3*p+(k-3),nanmean(times),'.','Color',col(k,:),'MarkerSize',30)
        end
    end
    xticks(1.5:3:42)
    xticklabels(subj_name2)
    if j == 1
        title('2-day')
        axis([0 42 0 10])
    elseif j == 2
        title('5-day')
        ylabel('Movement Time (s)')
        axis([0 36 0 10])
    else
        title('10-day')
        axis([0 15 0 10])
    end
end

%% plot path lengths
rng(1);
col = lines;
col = col(1:7,:);

col2 = [173 216 230
        255 160 122]./255;
    
figure(6); clf
for j = 1:length(groups)
    subplot(3,1,j); hold on
    for p = 1:Nsubj(j)
        for k = 1:length(hands)
            lengths = [];
            allLengths = data.(groups{j}){p}.(hands{k}).pathLength;
            for i = 1:length(allLengths)
                if ~isempty(allLengths{i})
                    lengths = [lengths; allLengths{i}];
                end
            end
            plot(3*p+(k-3)+(rand(length(lengths),1)-0.5)*0.3,lengths,'.','Color',col2(k,:),'MarkerSize',8)
            plot(3*p+(k-3),nanmean(lengths),'.','Color',col(k,:),'MarkerSize',30)
        end
    end
    xticks(1.5:3:42)
    xticklabels(subj_name2)
    if j == 1
        title('2-day')
        axis([0 42 0 1])
    elseif j == 2
        title('5-day')
        ylabel('Path Length (m)')
        axis([0 36 0 1])
    else
        title('10-day')
        axis([0 15 0 1])
    end
end

%%
[d2,d5,d10] = deal([]);
for i = 1:length(subj_name2)
    a = data.day2{i};
    d2(1,i) = std(d.day2{i}.initDir)*180/pi - a.bimanual.std;
    d2(2,i) = a.unimanual.blockSpan - a.bimanual.blockSpan;
    d2(3,i) = a.unimanual.totalScore - a.bimanual.totalScore;
    d2(4,i) = a.unimanual.meanCorrect - a.bimanual.meanCorrect;
end
subjects = [1 4 5 7:15]; % need this because not all 5-day subjects did Corsi
for i = 1:length(subj_name5)
    a = data.day2{i};
    d5(1,i) = std(d.day5{subjects(i)}.initDir)*180/pi - a.bimanual.std;
    d5(2,i) = a.unimanual.blockSpan - a.bimanual.blockSpan;
    d5(3,i) = a.unimanual.totalScore - a.bimanual.totalScore;
    d5(4,i) = a.unimanual.meanCorrect - a.bimanual.meanCorrect;
end
for i = 1:length(subj_name10)
    a = data.day2{i};
    d10(1,i) = std(d.day10{i}.initDir)*180/pi - a.bimanual.std;
    d10(2,i) = a.unimanual.blockSpan - a.bimanual.blockSpan;
    d10(3,i) = a.unimanual.totalScore - a.bimanual.totalScore;
    d10(4,i) = a.unimanual.meanCorrect - a.bimanual.meanCorrect;
end

figure(7); clf
subplot(1,3,1); hold on
plot([-45 10],[0 0],'k','HandleVisibility','off')
plot([0 0],[-1.5 2.5],'k','HandleVisibility','off')
plot(d2(1,:),d2(2,:),'r.','MarkerSize',20)
plot(d5(1,:),d5(2,:),'g.','MarkerSize',20)
plot(d10(1,:),d10(2,:),'b.','MarkerSize',20)
xlabel('Change in initial reach direction variance')
ylabel('Change in block span')
legend({'2-day','5-day','10-day'},'Location','northwest')

subplot(1,3,2); hold on
plot([-45 10],[0 0],'k')
plot([0 0],[-50 100],'k')
plot(d2(1,:),d2(3,:),'r.','MarkerSize',20)
plot(d5(1,:),d5(3,:),'g.','MarkerSize',20)
plot(d10(1,:),d10(3,:),'b.','MarkerSize',20)
xlabel('Change in initial reach direction variance')
ylabel('Change in total score')

subplot(1,3,3); hold on
plot([-45 10],[0 0],'k')
plot([0 0],[-0.3 0.3],'k')
plot(d2(1,:),d2(4,:),'r.','MarkerSize',20)
plot(d5(1,:),d5(4,:),'g.','MarkerSize',20)
plot(d10(1,:),d10(4,:),'b.','MarkerSize',20)
xlabel('Change in initial reach direction variance')
ylabel('Change in mean correct')

%%
[d2,d5,d10] = deal([]);
for i = 1:length(subj_name2)
    a = data.day2{i};
    d2.blockSpan(1,i) = a.unimanual.blockSpan;
    d2.blockSpan(2,i) = a.bimanual.blockSpan;
    d2.totalScore(1,i) = a.unimanual.totalScore;
    d2.totalScore(2,i) = a.bimanual.totalScore;
    d2.meanCorrect(1,i) = a.unimanual.meanCorrect*100;
    d2.meanCorrect(2,i) = a.bimanual.meanCorrect*100;
end
for i = 1:length(subj_name5)
    a = data.day5{i};
    d5.blockSpan(1,i) = a.unimanual.blockSpan;
    d5.blockSpan(2,i) = a.bimanual.blockSpan;
    d5.totalScore(1,i) = a.unimanual.totalScore;
    d5.totalScore(2,i) = a.bimanual.totalScore;
    d5.meanCorrect(1,i) = a.unimanual.meanCorrect*100;
    d5.meanCorrect(2,i) = a.bimanual.meanCorrect*100;
end
for i = 1:length(subj_name10)
    a = data.day10{i};
    d10.blockSpan(1,i) = a.unimanual.blockSpan;
    d10.blockSpan(2,i) = a.bimanual.blockSpan;
    d10.totalScore(1,i) = a.unimanual.totalScore;
    d10.totalScore(2,i) = a.bimanual.totalScore;
    d10.meanCorrect(1,i) = a.unimanual.meanCorrect*100;
    d10.meanCorrect(2,i) = a.bimanual.meanCorrect*100;
end

col = lines;
col = col(1:7,:);
names = {'blockSpan','totalScore','meanCorrect'};

figure(8); clf
for i = 1:3
    subplot(1,3,i); hold on
    plot(1:2,d2.(names{i}),'Color',[col(1,:) 0.5],'HandleVisibility','off')
    plot(3.5:4.5,d5.(names{i}),'Color',[col(2,:) 0.5],'HandleVisibility','off')
    plot(6:7,d10.(names{i}),'Color',[col(3,:) 0.5],'HandleVisibility','off')
    
    plot(1:2,mean(d2.(names{i}),2),'.','MarkerSize',40,'Color',[col(1,:) 0.5])
    plot(3.5:4.5,mean(d5.(names{i}),2),'.','MarkerSize',40,'Color',[col(2,:) 0.5])
    plot(6:7,mean(d10.(names{i}),2),'.','MarkerSize',40,'Color',[col(3,:) 0.5])
    
    xticks([1 2 3.5 4.5 6 7])
    xticklabels({'Uni','Bi','Uni','Bi','Uni','Bi'})
    if i == 1
        ylabel('Block Span')
        yticks(1:9)
        axis([0.5 7.5 0 9.5])
    elseif i == 2
        ylabel('Score')
        yticks(0:50:250)
        axis([0.5 7.5 0 220])
    elseif i == 3
        ylabel('Percent Correct')
        yticks(0:25:100)
        axis([0.5 7.5 0 100])
        legend({'2-day','5-day','10-day'})
    end
end