clear all;
close all;
%% Variable decleration
T = 0.001;
over = 10;
Ts = T / over;
Fs = 1 / Ts;
A = 4;
a = 0.5;
K = 500;
N = 100;
Nf = 4096;
%% A.1

% Pulse generator
grid on;
hold on;
[phi, t] = srrc_pulse(T, over, A, a);
plot(t,phi);
xlim([-A*T A*T]);
title("SRRC Pulse");
xlabel("Time");
ylabel("\phi(t)");
hold off;

% Frequency Range
f_axis = linspace(-Fs/2,(Fs/2-Fs/Nf), Nf);
% Fourier Transform 
phi_F = fftshift(fft(phi,Nf)*Ts);
abs_phi_F = abs(phi_F);
phi_Energy = power(abs_phi_F,2);
figure;
semilogy(f_axis, phi_Energy);
title("Energy Spectrum of SRRC");
xlabel("Frequency");
ylabel("Logarithmic");
xlim([-Fs/2 Fs/2]);

%% A.2

% 2-PAM bits generator
b = (sign(randn(N, 1)) + 1)/2;
x = bits_to_2PAM(b);

% Upsample the 2-PAM bit vector
upsample_x = (1/Ts)*upsample(x, over);
upsample_x_time = 0:Ts:N*T-Ts;

% Convolution of X and phi to compute the sum
X = conv(upsample_x,phi)*Ts;
X_time = upsample_x_time(1)+t(1):Ts:upsample_x_time(end)+t(end);
figure;
plot(X_time, X);
xlabel("Time");
ylabel("X(t)");
xlim([X_time(1) X_time(end)]);

%% A.3
%-----------------------1-----------------------
% Create the periodogram
X_F = fftshift(fft(X, Nf)*Ts);
num = power(abs(X_F),2);
T_total = X_time(end) - X_time(1);
Px_F = num/T_total;

% Visualize Px(F) and RF Rx(F) using log scale
figure;
subplot(1,2,1);
plot(f_axis, Px_F);
title("Px(F)");
xlabel("Frequency");
xlim([-Fs/2 Fs/2]);

subplot(1,2,2);
semilogy(f_axis,Px_F);
title("Px(F)");
xlabel("Frequency");
ylabel("Logarithmic");
xlim([-Fs/2 Fs/2]);

%------------------------2------------------------
Px_F_total = 0;
for i=1:K
    % 2-PAM bits generator
    b = (sign(randn(N, 1)) + 1)/2;
    x = bits_to_2PAM(b);

    % Upsample the 2-PAM bit vector
    upsample_x = (1/Ts)*upsample(x, over);
    %upsample_x_time = 0:Ts:N*T-Ts;

    % Convolution of X and phi to compute the sum
    X = conv(upsample_x,phi)*Ts;
    %X_time = upsample_x_time(1)+t(1):Ts:upsample_x_time(end)+t(end);

    % Create the periodogram
    X_F = fftshift(fft(X, Nf)*Ts);
    num = power(abs(X_F),2);
    T_total = X_time(end) - X_time(1);
    Px_F_total = Px_F_total + (num/T_total);
end
Px_F_estimated = Px_F_total/K;
Px_F_theoritical = 1/T*phi_Energy;

figure;
semilogy(f_axis,Px_F_estimated);
hold on;
semilogy(f_axis,Px_F_theoritical);
legend("Estimated","Theoritical");
title("P_x(F)");
xlim([-Fs/2 Fs/2]);
hold off;

%-----------------------3------------------------
K_options = [1000; 50];
N_options = [200; 50];
figure;
for i=1:length(K_options)
    Px_F_total = 0;
    K_3 = K_options(i);
    N_3 = N_options(i);
    for j=1:K_3
        % 2-PAM bits generator
        b = (sign(randn(N_3, 1)) + 1)/2;
        x = bits_to_2PAM(b);

        % Upsample the 2-PAM bit vector
        upsample_x = (1/Ts)*upsample(x, over);
        upsample_x_time = 0:Ts:N_3*T-Ts;

        % Convolution of X and phi to compute the sum
        X = conv(upsample_x,phi)*Ts;
        X_time = upsample_x_time(1)+t(1):Ts:upsample_x_time(end)+t(end);

        % Create the periodogram
        X_F = fftshift(fft(X, Nf)*Ts);
        num = power(abs(X_F),2);
        T_total = X_time(end) - X_time(1);
        Px_F_total = Px_F_total + (num/T_total);
    end
    Px_F_estimated_3 = Px_F_total/K_3;
    Px_F_theoritical = 1/T*phi_Energy;

    subplot(1,2,i);
    semilogy(f_axis,Px_F_estimated_3);
    hold on;
    semilogy(f_axis,Px_F_theoritical);
    legend("Estimated","Theoritical");
    ylabel("P_x(F)");
    xlabel("Frequency");
    title(["K = ",K_3," N = ",N_3])
    xlim([-Fs/2 Fs/2]);
    hold off;
end
%% A.4
% Creation of X(t) 
b = (sign(randn(N, 1)) + 1)/2;
x_4PAM = bits_to_4PAM(b);

% Upsample x signal and time
x_up = (1/Ts)*upsample(x_4PAM, over);
x_up_time = 0:Ts:(N/2)*T-Ts;

% Create the convolution
x = conv(x_up,phi)*Ts;
x_time = x_up_time(1)+t(1):Ts:x_up_time(end)+t(end);

figure;
plot(x_time,x);
title("X(t),4-PAM");
xlabel("Time");
xlim([x_time(1) x_time(end)]);

%----------------------1-----------------------
P_x_4PAM_total = 0;
for i=1:K
    % 2-PAM bits generator
    b = (sign(randn(N, 1)) + 1)/2;
    x = bits_to_4PAM(b);

    % Upsample the 2-PAM bit vector
    x_up = (1/Ts)*upsample(x, over);
    x_up_time = 0:Ts:(N/2)*T-Ts;

    % Convolution of X and phi to compute the sum
    X = conv(x_up,phi)*Ts;
    X_time = x_up_time(1)+t(1):Ts:x_up_time(end)+t(end);

    % Fourier transform of X(t)
    x_F_4PAM = fftshift(fft(X,Nf)*Ts);

    % Create the periodogram
    T_total = X_time(end) - X_time(1);
    P_x_4PAM_num = power(abs(x_F_4PAM),2);
    P_x_4PAM_total = P_x_4PAM_total + (P_x_4PAM_num/T_total);
end

Px_F_estimated_4PAM = P_x_4PAM_total/K;
Px_F_theoritical_4PAM = 5/T*phi_Energy;

figure;
semilogy(f_axis,Px_F_estimated);
hold on;
semilogy(f_axis,Px_F_theoritical);
legend("Estimated","Theoritical");
title("P_x(F)");
xlim([-Fs/2 Fs/2]);
hold off;

%---------------------2----------------------
figure;
subplot(1,2,1);
plot(f_axis, Px_F_estimated);
hold on;
plot(f_axis,Px_F_estimated_4PAM)
title("P_X(F)");
xlabel("Frequency");
legend("2PAM","4PAM");
xlim([-Fs/2 Fs/2]);
hold off;

subplot(1,2,2);
semilogy(f_axis,Px_F_estimated);
hold on;
semilogy(f_axis,Px_F_estimated_4PAM);
title("P_X(F)");
xlabel("Frequency");
legend("2PAM","4PAM");
xlim([-Fs/2 Fs/2]);
hold off;

%% A.5
T = 2*T;
over = 2*over;
% Create the new pulse
[phi, t] = srrc_pulse(T, over, A, a);

phi_F = fftshift(fft(phi, Nf)*Ts);
abs_phi_F = abs(phi_F);
phi_Energy = power(abs_phi_F,2);

% 2-PAM bits generator
b = (sign(randn(N, 1)) + 1)/2;
x = bits_to_2PAM(b);

% Upsample the 2-PAM bit vector
upsample_x = (1/Ts)*upsample(x, over);
upsample_x_time = 0:Ts:N*T-Ts;

% Convolution of X and phi to compute the sum
X = conv(upsample_x,phi)*Ts;
X_time = upsample_x_time(1)+t(1):Ts:upsample_x_time(end)+t(end);

%-----------------------1-----------------------
% Create the periodogram
X_F = fftshift(fft(X, Nf)*Ts);
num = power(abs(X_F),2);
T_total = X_time(end) - X_time(1);
Px_F = num/T_total;

% Visualize Px(F) and RF Rx(F) using log scale
figure;
subplot(1,2,1);
plot(f_axis, Px_F);
title("Px(F)");
xlabel("Frequency");
xlim([-Fs/2 Fs/2]);

subplot(1,2,2);
semilogy(f_axis,Px_F);
title("Px(F)");
xlabel("Frequency");
ylabel("Logarithmic");
xlim([-Fs/2 Fs/2]);

%------------------------2------------------------
Px_F_total_2T = 0;
K = 500;
for i=1:K
    % 2-PAM bits generator
    b = (sign(randn(N, 1)) + 1)/2;
    x = bits_to_2PAM(b);

    % Upsample the 2-PAM bit vector
    upsample_x = (1/Ts)*upsample(x, over);

    % Convolution of X and phi to compute the sum
    X_t = conv(upsample_x,phi)*Ts;

    % Fourier Transform
    X_F = fftshift(fft(X_t, Nf)*Ts);
    % Create the periodogram
    num = power(abs(X_F),2);
    Px_F_total_2T = Px_F_total_2T + (num/T_total);
end
Px_F_estimated_2T = Px_F_total_2T/K;
Px_F_theoritical = 1/T*phi_Energy;

figure;
semilogy(f_axis,Px_F_estimated_2T,f_axis,Px_F_theoritical);
legend("Estimated","Theoritical");
title("P_x(F)");
xlim([-Fs/2 Fs/2]);
legend("Average","Theoritical");

figure;
plot(f_axis,Px_F_estimated_2T,f_axis,Px_F_theoritical);
legend("Estimated","Theoritical");
title("P_x(F)");
xlim([-Fs/2 Fs/2]);
legend("Average","Theoritical");

% Compare T' with T
figure;
semilogy(f_axis, Px_F_estimated_2T,f_axis, Px_F_estimated);
title('P_X(F)');
xlim([-Fs/2 Fs/2]);
legend('P_X(F)_{2T}','P_X(F)_{T}'); 

figure;
plot(f_axis, Px_F_estimated_2T,f_axis, Px_F_estimated);
title('P_X(F)');
xlim([-Fs/2 Fs/2]);
legend('P_X(F)_{2T}','P_X(F)_{T}');
