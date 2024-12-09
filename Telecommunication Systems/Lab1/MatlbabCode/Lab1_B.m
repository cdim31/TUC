clear all;
close all;

%% B.1.
T = 0.01;
A = 4;
a = [0, 0.5, 1];
over = 10;  %Oversampling factor
kStep = 1;
k = [0, 1, 2];
t_delay = k.*T;

Ts = T/over;
phi = {};

for i=1:length(a)
    [phi{i}, t] = srrc_pulse(T, over, A, a(i));
    subplot(3,1,i);
    for j=1:length(k)
        plot(t+t_delay(j),phi{i});
        hold on;
    end
    title(['SRRC Pusles with roll-off factor: a = ' num2str(a(i))]);
    legend('k = 0', 'k = 1', 'k = 2', 'k = 3');
    xlabel('Time');
    xlim([-A*T A*T]);
end
hold off;

%% B.2.
t_delay2 = k*T;
for i=1:length(a)
    figure
    for j=1:length(k)
        subplot(4,1,j);
        time = -A*T:Ts:A*T+k(j)*T;
        phi_t = [phi{i} zeros(1,k(j)*T/Ts)];
        phi_kT = [zeros(1,k(j)*T/Ts) phi{i}];
        result = phi_t.*phi_kT;
        plot(time, result);
        xlim([-A*T A*T+k(j)*T]);
        title(['Product of \phi(t) and \phi(t-KT) with: a = ' num2str(a(i)) ', k = ' num2str(k(j))]);
    end
    xlabel('Time');
end

%% B.3.
k = [0,1,2,3];
for i=1:length(a)
    fprintf('Integral of φ(t) * φ(t-KT) with a = %.1f and\n', a(i));
    for j=1:length(k)
        phi_t = [phi{i} zeros(1,k(j)*T/Ts)];
        phi_kT = [zeros(1,k(j)*T/Ts) phi{i}];
        result = phi_t.*phi_kT;
        v(i) = sum(result)*Ts;
        fprintf('k = %d: %.6f\n',k(j), v(i));
    end
end


