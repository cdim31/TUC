function [x] = bits_to_2PAM(b)

for i=1:length(b)
    x(i) = (-1)^b(i);
end
end