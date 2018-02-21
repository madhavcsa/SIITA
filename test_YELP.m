%% Test Yelp 
clc; clear all;
rng('default');
rng(101);
%% Load Data
load('YELP_1000x992x93');

Y = data.tensor;
B = data.B_city;

n1 = max(Y(:,1));
n2 = max(Y(:,2));
n3 = max(Y(:,3));
m1 = n1; m3 = n3;
m2 = max(B(:,2));

A = eye(n1);
C = eye(n3);

[a,b,c] = find(A);
A_si = [a b c];
[a,b,c] = find(C);
C_si = [a b c];

% Train-Test split
frac = 0.8; % Training fraction
n_entries = size(Y,1);
ntrain = round(frac * n_entries);
rand_order = randperm(n_entries);
Y_train = Y(rand_order(1:ntrain), :);
Y_test = Y(rand_order(ntrain+1:end),:);

subs = Y_train(:,1:3);
vals = Y_train(:,4);

t_mean = mean(vals(:));
% vals = vals ;%- t_mean;

test_data.subs = Y_test(:,1:3);
test_data.vals = Y_test(:,4) ;%- t_mean;



%% SIITA
clear opts;
opts.r = [3 3 3];
opts.maxepochs = 20;
opts.p = 0.1;
opts.lambda_1 = 0;
opts.lambda_2 = 0;
opts.lambda_3 = 0;
opts.lambda_g = 0;
opts.gamma = 1e-4; % Step size parameter
opts.alpha_step = 0.995;
% opts.batch = 1;  %% Set this to 1 for MAST mode
% opts.computeAUC = 1; %% Set this to 1 for Computing AUC

sideopts.A = A_si;
sideopts.A_cols = m1;
sideopts.B = B;
sideopts.B_cols= m2;
sideopts.C = C_si;
sideopts.C_cols = m3;

[X, train_rmse, test_rmse_side_info, batch_test, time_info_side_info, batch_time] = run_mast_si(subs, vals, [n1 n2 n3], test_data, opts, sideopts);

%% SIITA (w/o SI)
m2 = n2;
B = eye(n2);
[a,b,c] = find(B);
B_si = [a b c];
sideopts.B = B_si;
sideopts.B_cols = m2;

[X, train_rmse, test_rmse_no_side_info, batch_test, time_info_no_side_info, batch_time] = run_mast_si(subs, vals, [n1 n2 n3], test_data, opts, sideopts);


%% Plots
epochs = 1:opts.maxepochs;
plot(epochs, test_rmse_side_info, 'color', 'r', 'Linewidth', 5); hold on;
plot(epochs, test_rmse_no_side_info, 'color', 'b', 'Linewidth', 5);
hold off;
xlabel('epochs','Fontsize', 20, 'Fontweight', 'bold');
ylabel('test rmse','Fontsize', 20, 'Fontweight', 'bold');
legend('SIITA', 'SIITA (w/o side info)');

figure;
plot(epochs, time_info_side_info, 'color', 'r', 'Linewidth', 5); hold on;
plot(epochs, time_info_no_side_info, 'color', 'b', 'Linewidth', 5); hold off;
xlabel('epochs', 'Fontsize', 20, 'Fontweight', 'bold');
ylabel('run time','Fontsize', 20, 'Fontweight', 'bold');
legend('SIITA', 'SIITA (w/o side info)');
    