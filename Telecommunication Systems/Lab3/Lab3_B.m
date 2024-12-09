clear all;
close all;

%% Variable decleration
N = 200;
A = 1;
A_SRRC = 4;
a = 0.5;
T = 0.01;
over = 10;
Ts = T/over;
Fs = 1/Ts;
Nf = 2048;
%K = 1000;
K = 200;

SNRdb = 0:2:16;
%% B.1
for i = 1:length(SNRdb)
    SNR = SNRdb(i);
    sum_errors_num = 0;
    sum_errors_in_bits = 0;
    for k = 1:K
        bits = (sign(randn(4*N, 1)) + 1)/2;

        % For bits in the [0,2N]
        bitXI = bits(1:2*N);
        XIn = bits_to_4_PAM(bitXI, A);

        % For bits in the [2N+1,4N]
        bitXQ = bits(2*N+1:4*N);
        XQn = bits_to_4_PAM(bitXQ, A);

        % Creating the pulse
        [phi, t] = srrc_pulse(T, over, A_SRRC, a);
        
        % Upsample the 2 sequencies
        XIn_up = (1/Ts)*upsample(XIn, over);
        XI_up_time = 0:Ts:N*T-Ts;

        XQn_up = (1/Ts)*upsample(XQn, over);
        XQ_up_time = XI_up_time;

        % Convolutions and time
        XIt = Ts*conv(XIn_up, phi);
        XQt = Ts*conv(XQn_up, phi);
        conv_t = t(1) + XQ_up_time(1):Ts:t(end) + XQ_up_time(end);

        % Frequency Range
        f_axis = linspace(-Fs/2,(Fs/2-Fs/Nf), Nf);

        % Periodograms creation
        XIF = fftshift(fft(XIt, Nf)*Ts);
        num = power(abs(XIF),2);
        T_total = conv_t(end) - conv_t(1);
        PXIF = num/T_total;

        XQF = fftshift(fft(XQt, Nf)*Ts);
        num = power(abs(XQF),2);
        T_total = conv_t(end) - conv_t(1);
        PXQF = num/T_total;

        Fo = 200;
        XImod_t = 2*XIt.*cos(2*pi*Fo*conv_t);
        XQmod_t = -2*XQt.*sin(2*pi*Fo*conv_t);

        % Periodograms creation
        XIFmod = fftshift(fft(XImod_t, Nf)*Ts);
        num = power(abs(XIFmod),2);
        T_total = conv_t(end) - conv_t(1);
        PXIFmod = num/T_total;

        XQFmod = fftshift(fft(XQmod_t, Nf)*Ts);
        num = power(abs(XQFmod),2);
        T_total = conv_t(end) - conv_t(1);
        PXQFmod = num/T_total;
    
        % Input signal creation 
        Xmod_t = XImod_t + XQmod_t;

        % Periodogram creation
        Xmod_F = fftshift(fft(Xmod_t, Nf)*Ts);
        num = power(abs(Xmod_F),2);
        T_total = conv_t(end) - conv_t(1);
        PXmod = num/T_total;

        % Noise creation
        variance = (10*(A^2))/(Ts*(10^(SNR/10)));
        gaussian_noise = sqrt(variance)*randn(1,length(Xmod_t));

        % Adding noise to the waveform
        Xmod_noise = Xmod_t + gaussian_noise;

        % Demodulating the signal
        XImod_noise = Xmod_noise.*cos(2*pi*Fo*conv_t);
        XQmod_noise = -Xmod_noise.*sin(2*pi*Fo*conv_t);

        % Periodograms creation
        XImod_noise_F = fftshift(fft(XImod_noise, Nf)*Ts);
        num = power(abs(XImod_noise_F),2);
        T_total = conv_t(end) - conv_t(1);
        PXImod_noise = num/T_total;

        XQmod_noise_F = fftshift(fft(XQmod_noise, Nf)*Ts);
        num = power(abs(XQmod_noise_F),2);
        T_total = conv_t(end) - conv_t(1);
        PXQmod_noise = num/T_total;

        % Filter the waveforms
        XIt_demodulated = Ts*conv(XImod_noise, phi);
        XQt_demodulated = Ts*conv(XQmod_noise, phi);
        conv_t2 = t(1) + conv_t(1):Ts:t(end) + conv_t(end);

        XIF_demodulated = fftshift(fft(XIt_demodulated, Nf)*Ts);
        num = power(abs(XIF_demodulated),2);
        T_total = conv_t2(end) - conv_t2(1);
        PXI_demodulated = num/T_total;

        XQF_demodulated = fftshift(fft(XQt_demodulated, Nf)*Ts);
        num = power(abs(XQF_demodulated),2);
        T_total = conv_t2(end) - conv_t2(1);
        PXQ_demodulated = num/T_total;

        XIt_demodulated_sampling= XIt_demodulated((2*A_SRRC*T/Ts)+1:over:length(XIt_demodulated)-(2*A_SRRC*T/Ts));
        XQt_demodulated_sampling= XQt_demodulated((2*A_SRRC*T/Ts)+1:over:length(XQt_demodulated)-(2*A_SRRC*T/Ts));

        for p=1:N
            sampling(p,1)=XIt_demodulated_sampling(p); 
            sampling(p,2)=XQt_demodulated_sampling(p);
        end

        % Estimating the symbols value
        for j = 1:N
            detected_XI(j) = detect_4_PAM(XIt_demodulated_sampling(j), A);
            detected_XQ(j) = detect_4_PAM(XQt_demodulated_sampling(j), A);
        end

        x_sent = [XIn; XQn];
        x_detected = [detected_XI; detected_XQ];

        errors_num = 0;
        for n = 1:N
            for j = 1:2
                if (x_sent(j,n) ~= x_detected(j,n))
                    errors_num = errors_num + 1;
                end
            end
        end

        bitXI_received = PAM_4_to_bits(detected_XI, A);
        bitXQ_received = PAM_4_to_bits(detected_XQ, A);

        estimated_bits = [bitXI_received bitXQ_received];
        
        errors_in_bits = 0;
        for m = 1:length(estimated_bits)
            if (estimated_bits(m) ~= bits(m))
                    errors_in_bits = errors_in_bits + 1;
            end
        end
    sum_errors_num = sum_errors_num + errors_num;
    sum_errors_in_bits = sum_errors_in_bits + errors_in_bits;
    end
    P_symbol(i) = sum_errors_num/(N*K);
    P_bit(i) = sum_errors_in_bits/(4*N*K);
    P_theor_symbol(i) = 3*Q(sqrt(0.2.*(10.^(SNR/10))));
    P_theor_bit(i) = P_theor_symbol(i)/4;
end
%% B.2 and B.3
figure;
semilogy(SNRdb, P_theor_symbol);
hold on;
semilogy(SNRdb, P_symbol);
legend ("Theoretical","Experimental")
hold off;
grid on;
title("Symbol Comparisson");

figure;
semilogy(SNRdb, P_theor_bit);
hold on;
semilogy(SNRdb, P_bit);
legend ("Theoretical","Experimental")
hold off;
grid on;
title("Bits Comparisson");

