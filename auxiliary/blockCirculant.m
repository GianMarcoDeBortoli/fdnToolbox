function B = blockCirculant(A, k, N)
    
    B = zeros(k, N, N);
    
    B(:,:,1) = circshift(A, 1, 2);
    for i = 2:N
        B(:,:,i) = circshift(B(:,:,i-1), 1, 2);
    end

end