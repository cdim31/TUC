function [est_bit] = PAM_4_to_bits(X,A)
    
for i = 1:length(X)
        if X(i) == 3*A
            est_bit(2*i-1:2*i) = [0; 0];
        elseif X(i) == A
            est_bit(2*i-1:2*i) = [0; 1];
        elseif X(i) == -A
            est_bit(2*i-1:2*i) = [1; 1];
        elseif X(i) == -3*A
            est_bit(2*i-1:2*i) = [1; 0];
        end
end
end
