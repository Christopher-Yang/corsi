clear history
Ngroup = 3;
maxSubj = 15;

vmPDF = @(x, mu, kappa) (exp(kappa*cos(x-mu)) / (2 * pi * besseli(0,kappa))); % PDF of von Mises distribution
tolerance = 0.01; % tolerance for stopping EM loop

% set values for initial parameters for EM loop
muInit = 0;
kappaInit = 1;
weightInit = 0.99;

% preallocate variables for parameters
mu_opt = NaN(Ngroup,maxSubj,4);
kappa_opt = NaN(Ngroup,maxSubj,4);
weight_opt = NaN(Ngroup,maxSubj,4);
sd = NaN(Ngroup,maxSubj,4);

% main loop for EM
for j = 1:4
    for k = 1:Ngroup
        if j <= 2
            Nsubj = length(d.(groups{k}));
        else
            Nsubj = length(data.(groups{k}));
        end
        for m = 1:Nsubj
            
            % select trials to analyze and store in samples
            if j == 1
                samples = d.(groups{k}){m}.initDir(1:30);
            elseif j == 2
                samples = d.(groups{k}){m}.initDir(31:end);
            elseif j == 3
                samples = data.(groups{k}){m}.unimanual.error*pi/180;
            elseif j == 4
                samples = data.(groups{k}){m}.bimanual.error*pi/180;
            end
            
            samples = samples(~isnan(samples));
            
            % initialize mu and kappa for the VM distribution and the
            % relative weight between the VM and uniform distributions
            mu = muInit;
            kappa = kappaInit;
            weight = weightInit;
            idx = 1; % index for tracking number of EM iterations
            proceed = true; % flag for stopping EM loop
            
            % EM loop
            while proceed
                
                % expectation step
                Pr_vm = weight * vmPDF(samples, mu, kappa) ./ (weight * vmPDF(samples, mu, kappa) + (1-weight) * (1 / (2*pi)));
                Pr_unif = (1-weight) * (1 / (2*pi)) ./ (weight * vmPDF(samples, mu, kappa) + (1-weight) * (1 / (2*pi)));
                
                % maximization step
                log_likelihood = @(params) calc_likelihood(params, samples, Pr_vm);
                paramsInit = [mu kappa weight]; % set parameters to current values of mu and kappa
                [params_opt, fval] = fmincon(log_likelihood, paramsInit, [], [], [], [], [-pi 0 0], [pi 200 1]);
                
                % assign optimized values of parameters
                mu = params_opt(1);
                kappa = params_opt(2);
                weight = params_opt(3);
                
                % keep track of log-likelihood to terminate EM loop
                history{k}{m}{j}(idx) = fval;
                
                % terminate loop if change in log-likelihood is smaller
                % than tolerance,
                if idx > 1 && abs(history{k}{m}{j}(idx) - history{k}{m}{j}(idx-1)) < tolerance
                    proceed = false;
                end
                idx = idx + 1; % increment loop iteration number
                
                %                 % analytical approach to solve MLE
                %                 xBar = mean(exp(1j*vmSamples));
                %                 R = norm(xBar);
                %                 mu = angle(xBar);
                %                 kappa = R * (2 - R^2) ./ (1 - R^2);
                %
                %                 if idx > 50
                %                     proceed = false;
                %                 end
                %                 idx = idx + 1;
            end
            
            % store fitted parameter values
            mu_opt(k,m,j) = mu;
            kappa_opt(k,m,j) = kappa;
            weight_opt(k,m,j) = weight;
            
            % compute circular standard deviation
            R = (besseli(1,kappa)/besseli(0,kappa));
            sd(k,m,j) = sqrt(-2 * log(R)); % circular standard deviation
        end
    end
end

%%
figure(1); clf; hold on
plot(1,sd(1,:,1)','k.','MarkerSize',20)
plot(2,sd(2,:,1)','r.','MarkerSize',20)
plot(3,sd(3,:,1)','b.','MarkerSize',20)

plot(5,sd(1,:,2)','k.','MarkerSize',20)
plot(6,sd(2,:,2)','r.','MarkerSize',20)
plot(7,sd(3,:,2)','b.','MarkerSize',20)

plot(9,sd(1,:,3)','k.','MarkerSize',20)
plot(10,sd(2,:,3)','r.','MarkerSize',20)
plot(11,sd(3,:,3)','b.','MarkerSize',20)

plot(13,sd(1,:,4)','k.','MarkerSize',20)
plot(14,sd(2,:,4)','r.','MarkerSize',20)
plot(15,sd(3,:,4)','b.','MarkerSize',20)

% for j = 1:length(groups)
%     [baseline_p2p,baseline_Corsi,bimanual_p2p,bimanual_Corsi] = deal([]);
%     for i = 1:Nsubj(j)
%         p = data.(groups{j}){i};
%         baseline_p2p = [baseline_p2p d.(groups{j}){i}.initDir(1:30)*180/pi];
%         bimanual_p2p = [bimanual_p2p d.(groups{j}){i}.initDir(31:end)*180/pi];
%         baseline_Corsi = [baseline_Corsi data.(groups{j}){i}.unimanual.error];
%         bimanual_Corsi = [bimanual_Corsi data.(groups{j}){i}.bimanual.error];
%         
%         pd = fitdist(d.(groups{j}){i}.initDir(1:30)'*180/pi,'Normal');
%         fits.baseline_p2p{j}(i) = pd.sigma;
%         
%         pd = fitdist(d.(groups{j}){i}.initDir(31:end)'*180/pi,'Normal');
%         fits.bimanual_p2p{j}(i) = pd.sigma;
%         
%         pd = fitdist(data.(groups{j}){i}.unimanual.error','Normal');
%         fits.baseline_Corsi{j}(i) = pd.sigma;
%         
%         pd = fitdist(data.(groups{j}){i}.bimanual.error','Normal');
%         fits.bimanual_Corsi{j}(i) = pd.sigma;
%     end
% end

% function for computing log-likelihod
function neg_log_likelihood = calc_likelihood(params,samples,Pr_vm)
    mu = params(1);
    kappa = params(2);
    weight = params(3);
    
    likelihood_unif = (1 - Pr_vm) .* log(1 - weight);
    likelihood_vm = Pr_vm .* (log(weight) + log(exp(kappa * cos(samples-mu)) / (2 * pi * besseli(0,kappa))));
    
    likelihood_all = [likelihood_unif likelihood_vm];
    neg_log_likelihood = -sum(sum(likelihood_all,2),1);
end
