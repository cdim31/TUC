function [x] = bits_to_4PAM(b)

for i = 1:2:length(b)
    bits = b(i:i+1);
    if isequal(bits, [0;0])
        x((i+1)/2) = +3;
    elseif isequal(bits, [0;1])
        x((i+1)/2) = +1;
    elseif isequal(bits, [1;1])
        x((i+1)/2) = -1;
    elseif isequal(bits, [1;0])
        x((i+1)/2) = -3;
    end
end
end