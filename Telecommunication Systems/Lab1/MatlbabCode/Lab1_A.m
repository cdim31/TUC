clear all;
close all;

%% Variable Decleration
T = 0.01;
over = 10;
Ts = T/over;
A = 4 ;
a = [0, 0.5, 1];
phi = {};
t = 0;

%% A.1.

figure(1)
grid on;
hold on;
for i=1:length(a)
    [phi{i}, t] = srrc_pulse(T, over, A, a(i));
    plot(t,phi{i});
end
legend("a=0", "a=0.5","a=1")
xlim([-A*T A*T])
hold off;

%% A.2.

Fs = 1/Ts;
Nf1 = 1024;
Nf2 = 2048;
phi_F = {};
phi_F2 = {};

f_axis =  linspace(-Fs/2,(Fs/2-Fs/Nf2),Nf2);
figure(2)
hold on;
grid on;
for i=1:length(a)
        phi_F{i} = fftshift(fft(phi{i}, Nf2)*Ts);
        phi_F2{i} = power(abs(phi_F{i}),2);
        plot(f_axis, phi_F2{i});
end
legend("a=0", "a=0.5","a=1");
xlim([-Fs/2 Fs/2])
hold off;
figure(3)
for i=1:length(a)
    semilogy(f_axis, phi_F2{i});
    hold on;
end
grid on;
legend("a=0", "a=0.5","a=1");
xlim([-Fs/2 Fs/2])
hold off;

%% A.3.

c1 = zeros(1,length(f_axis))+T/10^3;
c2 = zeros(1,length(f_axis))+T/10^5;

figure(4);
for i=1:length(a)
    semilogy(f_axis, phi_F2{i});
    hold on;
end
grid on;
title('Energy Spectrums of SRRC');
xlabel('Frequency');
ylabel('Logarithmic');
plot(f_axis, c1);
plot(f_axis, c2);
legend("a=0", "a=0.5","a=1", "c1 = T/10^3","c2 = T/10^5");
xlim([-Fs/2 Fs/2])
hold off;











