function [x] = bits_to_4_PAM(bit_seq, A)

for i = 1:2:length(bit_seq)
    bits = bit_seq(i:i+1);
    if isequal(bits, [0;0])
        x((i+1)/2) = 3*A;
    elseif isequal(bits, [0;1])
        x((i+1)/2) = 1*A;
    elseif isequal(bits, [1;1])
        x((i+1)/2) = -1*A;
    elseif isequal(bits, [1;0])
        x((i+1)/2) = -3*A;
    end
end
end
