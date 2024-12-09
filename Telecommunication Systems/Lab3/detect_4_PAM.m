function [est_x] = detect_4_PAM(Y,A)
    Y_size = size(Y,2);
    est_x = zeros(1,Y_size);
    x = zeros(1,4);

    symbols = [-3*A, -A, A, 3*A];
    for i = 1:Y_size
        distances = zeros(1,4);
        for j = 1:4
            distances(j) = power((Y(i)-symbols(j)),2);
        end
        [~, minIndex] = min(distances);
        est_x(i) = symbols(minIndex);
    end
end
