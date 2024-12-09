clear all;
close all;
%% Variable declaration
Fo = 1;
T = 1;
Fs = 1000;
num_of_realizations = 5;
%% B.1

% Create time axis
t = linspace(0, T, T*Fs);

% Plot realizations
figure;
hold on;
for i = 1:num_of_realizations
    X = randn;
    phi = 2*pi*rand;
    Y = X* cos(2*pi*Fo*t + phi);
    plot(t, Y);
end

xlabel('Time');
ylabel('X(t)');
title('5 Realizations of X(t)');
legend show;
hold off;
