%% plots trajectories during a trial of the Corsi block-tapping task
group = 'day2';
subj = 3;
trial = 20;

figure(1); clf
for i = 1:2
    if i == 1
        p = data.(group){subj}.unimanual;
    else
        p = data.(group){subj}.bimanual;
    end
    subplot(1,2,i); hold on
    scatter(0.6,0.4,2000,'b','filled','MarkerFaceAlpha',0.4)
    scatter(targets(1,:),targets(2,:),3000,'k','filled','MarkerFaceAlpha',0.4)
    quiver(p.trajFilt{trial}(p.analysisTime{trial},1),...
        p.trajFilt{trial}(p.analysisTime{trial},2),...
        cos(p.initDir{trial})',sin(p.initDir{trial})',0.5,'LineWidth',2)
    plot(p.trajFilt{trial}(:,1),p.trajFilt{trial}(:,2),'k')
    plot(p.trajFilt{trial}(p.press{trial},1),p.trajFilt{trial}(p.press{trial},2),'r.','MarkerSize',15)
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
figure(2); clf
for j = 1:length(names)
    subplot(3,1,j); hold on
    plot([0 space*length(subj_name2)+1],[0 0],'k','HandleVisibility','off')
    for i = 1:Nsubj(j)
        dir = d.(names{j}){i}.initDir*180/pi;
        p = data.(names{j}){i};
        
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
        title('2 days of training')
    elseif j == 2
        title('5 days of training')
        ylabel('Reach direction error')
    elseif j == 3
        title('10 days of training')
        legend({'Baseline (p2p)','Baseline (Corsi)','Bimanual (p2p)','Bimanual (Corsi)'},'Location','northwest')
    end
end
%% plots the mean and std of reach direction error across trials
figure(3); clf
for j = 1:length(names)
    subplot(3,1,j); hold on
    plot([0 space*length(subj_name2)+1],[0 0],'k','HandleVisibility','off')
    for i = 1:Nsubj(j)
        dir = d.(names{j}){i}.initDir*180/pi;
        p = data.(names{j}){i};
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
        title('2 days of training')
    elseif j == 2
        title('5 days of training')
        ylabel('Reach direction error')
    elseif j == 3
        title('10 days of training')
        legend({'Baseline (p2p)','Baseline (Corsi)','Bimanual (p2p)','Bimanual (Corsi)'},'Location','northwest')
    end
end
%% plots the smoothed kernel of the reach direction errors
figure(4); clf
for j = 1:length(names)
    subplot(3,1,j); hold on
    [baseline_p2p,baseline_Corsi,bimanual_p2p,bimanual_Corsi] = deal([]);
    for i = 1:Nsubj(j)
        p = data.(names{j}){i};
        baseline_p2p = [baseline_p2p d.(names{j}){i}.initDir(1:30)*180/pi];
        baseline_Corsi = [baseline_Corsi data.(names{j}){i}.unimanual.error];
        bimanual_p2p = [bimanual_p2p d.(names{j}){i}.initDir(31:end)*180/pi];
        bimanual_Corsi = [bimanual_Corsi data.(names{j}){i}.bimanual.error];
    end
    [f,xi] = ksdensity(baseline_p2p);
    plot(xi,f,'Color',colors(1,:),'LineWidth',2);
    [f,xi] = ksdensity(baseline_Corsi);
    plot(xi,f,'Color',colors(2,:),'LineWidth',2);
    [f,xi] = ksdensity(bimanual_p2p);
    plot(xi,f,'Color',colors(3,:),'LineWidth',2);
    [f,xi] = ksdensity(bimanual_Corsi);
    plot(xi,f,'Color',colors(4,:),'LineWidth',2);
    if j == 1
        title('2 days of training')
        legend({'Baseline (p2p)','Baseline (Corsi)','Bimanual (p2p)','Bimanual (Corsi)'})
    elseif j == 2
        title('5 days of training')
        ylabel('Probability density')
    elseif j == 3
        title('10 days of training')
        xlabel('Reach direction error')
    end
    axis([-100 100 0 0.055])
end
%%
[d2,d5,d10] = deal([]);
for i = 1:length(subj_name2)
    d2(1,i) = std(d.day2{1}.initDir)*180/pi - data.day2{i}.bimanual.std;
    d2(2,i) = data.day2{i}.unimanual.blockSpan - data.day2{i}.bimanual.blockSpan;
    d2(3,i) = data.day2{i}.unimanual.totalScore - data.day2{i}.bimanual.totalScore;
    d2(4,i) = data.day2{i}.unimanual.meanCorrect - data.day2{i}.bimanual.meanCorrect;
end
for i = 1:length(subj_name5)
    d5(1,i) = std(d.day5{1}.initDir)*180/pi - data.day5{i}.bimanual.std;
    d5(2,i) = data.day5{i}.unimanual.blockSpan - data.day5{i}.bimanual.blockSpan;
    d5(3,i) = data.day5{i}.unimanual.totalScore - data.day5{i}.bimanual.totalScore;
    d5(4,i) = data.day5{i}.unimanual.meanCorrect - data.day5{i}.bimanual.meanCorrect;
end
for i = 1:length(subj_name10)
    d10(1,i) = std(d.day10{1}.initDir)*180/pi - data.day10{i}.bimanual.std;
    d10(2,i) = data.day10{i}.unimanual.blockSpan - data.day10{i}.bimanual.blockSpan;
    d10(3,i) = data.day10{i}.unimanual.totalScore - data.day10{i}.bimanual.totalScore;
    d10(4,i) = data.day10{i}.unimanual.meanCorrect - data.day10{i}.bimanual.meanCorrect;
end

figure(5); clf
subplot(1,3,1); hold on
plot([-45 10],[0 0],'k')
plot([0 0],[-1.5 2.5],'k')
for i = 1:length(subj_name2)
    plot(d2(1,i),d2(2,i),'r.','MarkerSize',20)
end
for i = 1:length(subj_name5)
    plot(d5(1,i),d5(2,i),'g.','MarkerSize',20)
end
for i = 1:length(subj_name10)
    plot(d10(1,i),d10(2,i),'b.','MarkerSize',20)
end
xlabel('Change in initial reach direction')
ylabel('Change in block span')

subplot(1,3,2); hold on
plot([-45 10],[0 0],'k')
plot([0 0],[-50 100],'k')
for i = 1:length(subj_name2)
    plot(d2(1,i),d2(3,i),'r.','MarkerSize',20)
end
for i = 1:length(subj_name5)
    plot(d5(1,i),d5(3,i),'g.','MarkerSize',20)
end
for i = 1:length(subj_name10)
    plot(d10(1,i),d10(3,i),'b.','MarkerSize',20)
end
xlabel('Change in initial reach direction')
ylabel('Change in total score')

subplot(1,3,3); hold on
plot([-45 10],[0 0],'k')
plot([0 0],[-0.3 0.3],'k')
for i = 1:length(subj_name2)
    plot(d2(1,i),d2(4,i),'r.','MarkerSize',20)
end
for i = 1:length(subj_name5)
    plot(d5(1,i),d5(4,i),'g.','MarkerSize',20)
end
for i = 1:length(subj_name10)
    plot(d10(1,i),d10(4,i),'b.','MarkerSize',20)
end
xlabel('Change in initial reach direction')
ylabel('Change in mean correct')