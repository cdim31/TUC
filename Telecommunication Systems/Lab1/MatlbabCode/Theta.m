clear all;
close all;

T = 16;
t = -20:0.01:20;
%% 1

y = zeros(1,length(t));
y(t<T/2 & t>-T/2) = 1./sqrt(T);

figure(1)

subplot(3,1,1)
plot(t, y);
title('\phi(t)');
xlabel('Time')
ylim([0 0.4]);

subplot(3,1,2)
y_flip = flip(y);
t_y_flip = t;
plot(t, y_flip);
title('\phi(-t)');
xlabel('Time')
ylim([0 0.4]);

subplot(3,1,3)
Y = conv(y, y_flip)*0.01;
t_conv = (t(1) + t_y_flip(1)):0.01:(t(end)+t_y_flip(end));
subplot(3,1,3);
plot(t_conv, Y);
title('R\phi\phi(τ)');
xlabel('Time');
ylim([0 2]);

%% 2
y = zeros(1,length(t));
y(t<2+T/2 & t>2-T/2) = 1./sqrt(T);

figure(2)

subplot(3,1,1)
plot(t, y);
title('\phi(t-2)');
xlabel('Time')
ylim([0 0.4]);

subplot(3,1,2)
y_flip = flip(y);
t_y_flip = t;
plot(t, y_flip);
title('\phi(-t+2)');
xlabel('Time')
ylim([0 0.4]);

subplot(3,1,3)
Y = conv(y, y_flip)*0.01;
t_conv = (t(1) + t_y_flip(1)):0.01:(t(end)+t_y_flip(end));
subplot(3,1,3);
plot(t_conv, Y);
title('R\phi\phi(τ)');
xlabel('Time');
ylim([0 2]);
%% 3

y = zeros(1,length(t));
y(t>=0 & t<T/2) = 1./sqrt(T);
y(t>=T/2 & t<=T) = (-1)./sqrt(T);

figure(3)

subplot(3,1,1)
plot(t, y);
title('\phi(t)');
xlabel('Time')
ylim([-1.5 1.5]);

subplot(3,1,2)
y_flip = flip(y);
t_y_flip = t;
plot(t, y_flip);
title('\phi(-t)');
xlabel('Time')
ylim([-1.5 1.5]);

subplot(3,1,3)
Y = conv(y, y_flip)*0.01;
t_conv = (t(1) + t_y_flip(1)):0.01:(t(end)+t_y_flip(end));
subplot(3,1,3);
plot(t_conv, Y);
title('R\phi\phi(τ)');
xlabel('Time');
ylim([-1.5 1.5]);




