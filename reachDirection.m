% clear all
% load P2Pdat

% targets = [.52 .72 .55 .59 .53 .6 .65 .67 .69
%            .32 .22 .27 .18 .21 .3 .26 .20 .34];
delayStep = 30;
space = 6;

folder = 'Data/denovo_2day/';
subj_name2 = {'subj1','subj2','subj3','subj4','subj5','subj6','subj7','subj8','subj9','subj10','subj11','subj12','subj13','subj14'};
data.day2 = loadData(folder,subj_name2,delayStep);

folder = 'Data/denovo_5day/';
subj_name5 = {'subj13','subj18','subj19','subj21','subj22','subj23','subj24','subj25','subj26','subj27','subj28','subj29'};
data.day5 = loadData(folder,subj_name5,delayStep);

folder = 'Data/denovo_10day/';
subj_name10 = {'subj1','subj2','subj3','subj4','subj5'};
data.day10 = loadData(folder,subj_name10,delayStep);

colors = [0 0 0
          128 128 128
          255 69 0
          255 165 0]./255;
Nsubj = [length(subj_name2),length(subj_name5),length(subj_name10)];
names = {'day2','day5','day10'};
disp('Done')

function data = loadData(folder, subj_name, delayStep)

targets = [.52 .72 .55 .59 .53 .6 .65 .67 .69
           .32 .22 .27 .18 .21 .3 .26 .20 .34];
disp('Analyzing...')
hands = {'unimanual','bimanual'};
Nsubj = length(subj_name);
increment = ones(30,4); % increment tOrder to eliminate ambiguity of ending 0's
for j = 1:5
    z = ones(30,1);
    z(1:5*j) = 0;
    increment = [increment z];
end

for l = 1:Nsubj
    disp(['    ',subj_name{l}])
    for k = 1:2
        error = [];
        path = [folder subj_name{l} '/' hands{k} '/'];
        tOrder = dlmread([path 'tOrder.txt']); % read in tOrder
        tOrder = tOrder+increment;
        
        fnames = dir(path); % get filenames in path
        fnames = fnames(not([fnames.isdir])); % get rid of directories
        Ncorrect = 0;
        Nbad = 0;
        Ntrials = size(fnames,1)-1;
        for j = 1:Ntrials
            [releaseTime,initDir,targRel,targAngle] = deal([]);
            d = dlmread([path fnames(j).name],' ',6,0); % read data into d
            input = d(:,12); % get button press data as input
            
            % analyze block tapping accuracy
            guess = input(1); % guess is the blocks subjects tapped
            for i = 2:length(input)
                if input(i) ~= input(i-1)
                    guess = [guess; input(i)]; 
                end
            end
            guess = guess(guess~=-1)'+1; % gets rid of data when there's no button presses
            answer = tOrder(j,:); % extract the correct answer for trial j
            answer(answer==0) = []; % get rid of 0's when sequence length<9
            if length(guess) ~= length(answer) % extract trials where hardware screwed up
                Nbad = Nbad + 1;
            elseif (sum(guess - answer) == 0) % check if guess matches answer
                Ncorrect = Ncorrect + 1;
            end
            
            % analyze kinematics during block tapping
            press = input~=-1; % find times when the button was pressed
            for i = 2:length(press)
                if press(i) == 0 && press(i-1) == 1 % find times when the button was released
                    releaseTime = [releaseTime i];
                end
            end 

            time = d(:,11); % time vector
            trajRaw = d(:,7:8); % raw trajectory
            trajFilt = sgolayfilt(trajRaw,3,11); % savitzky-golay filtered trajectories
            vel = diff(trajFilt)./diff(time/1000); % compute velocity of movements

            analysisTime = releaseTime(1:end-1)+delayStep;
            
            if length(releaseTime) ~= length(answer)
                initDir = [];
                targAngle = [];
                error = [];
            else
                for i = 1:length(analysisTime) % compute movement direction
                    initDir(i) = atan2(vel(analysisTime(i),2),vel(analysisTime(i),1));
                end
                
                for i = 1:length(releaseTime)-1
                    targRel(i,:) = trajFilt(releaseTime(i+1),:) - trajFilt(releaseTime(i),:); % relative position of next target
                    targAngle(i) = atan2(targRel(i,2),targRel(i,1)); % relative angle of next target
                end
                
                error = [error initDir-targAngle]; % error in initial movement direction
            end
            
            data{l}.(hands{k}).trajRaw{j} = trajRaw;
            data{l}.(hands{k}).trajFilt{j} = trajFilt;
            data{l}.(hands{k}).vel{j} = vel;
            data{l}.(hands{k}).initDir{j} = initDir;
            data{l}.(hands{k}).targAngle{j} = targAngle;
            data{l}.(hands{k}).press{j} = press;
            data{l}.(hands{k}).analysisTime{j} = analysisTime;
        end
        
        data{l}.(hands{k}).blockSpan = length(answer);
        data{l}.(hands{k}).totalScore = Ncorrect*length(answer);
        data{l}.(hands{k}).meanCorrect = Ncorrect/Ntrials;
        data{l}.(hands{k}).systemError = Nbad;
        
        for i = 1:length(error) % wrap all errors between (-pi,pi]
            while error(i) > pi
                error(i) = error(i)-2*pi;
            end
            while error(i) <= -pi
                error(i) = error(i)+2*pi;
            end
        end
        data{l}.(hands{k}).error = error*180/pi; % convert error from radians to degrees
        data{l}.(hands{k}).std = std(error*180/pi); % standard deviation of error
    end
end
end