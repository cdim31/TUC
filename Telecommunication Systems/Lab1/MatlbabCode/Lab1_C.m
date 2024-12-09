clear all;
close all;

T = 0.01;
over = 10;
Ts = T/over;
a = 0.5;
A = 4;

%% C.1.

N = 100;
b = (sign(randn(N, 1)) + 1)/2; 

%% C.2.
%% A)
x = bits_to_2PAM(b);
%% B)
x_delta = (1/Ts)*upsample(x, over);
t_pulse = 0:Ts:T*N-Ts;

figure
hold on;
stem(t_pulse, x_delta) ;
title("Upscaled Pulse Train")
xlim([0 T*N]) ;
xlabel("Time") ;

%% C)
[phi, t] = srrc_pulse(T, over, A, a);
X_conv = conv(x_delta, phi)*Ts;
X_time = t_pulse(1)+t(1):Ts:t_pulse(end)+t(end);

figure
plot(X_time, X_conv)
xlabel("TIme")
xlim([X_time(1) X_time(end)]) ;
title("X(t)");

%% D)
phi_flip = flip(phi);
Z_conv = conv(X_conv, phi_flip)*Ts;
Z_time = X_time(1)+t(1):Ts:X_time(end)+t(end);

figure
plot(Z_time, Z_conv)
xlabel("Time")
xlim ([Z_time(1) Z_time(end)]) ;
title("Z(t)");

% Sampling Z(t) 
index_first = find(abs(Z_time) < T);
index_last = find(abs(Z_time - t_pulse(end)) < T);

Z_sampled = Z_conv(index_first : index_last);
Z_sampled = downsample(Z_sampled, over);

figure
hold on;
plot(Z_time, Z_conv);
stem(0:T:(N-1)*T, Z_sampled, "k");
legend ("Z(t)", "Z_s(t)");
xlim([Z_time(1) Z_time(end)]);

figure
hold on;
stem(0:T:(N-1)*T, Z_sampled, "k");
stem([0:N-1]*T, x);
legend("Z(t)", "X(t)");

