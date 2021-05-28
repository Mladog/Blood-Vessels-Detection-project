function level = treshold(Image)
    %use of iteration method for defining treshold
    Image = im2uint8(Image(:));
    [Histogram_Count, Bin_Number] = imhist(Image);

    i = 1;

    Cumulative_Sum = cumsum(Histogram_Count);
    T(i) = (sum(Bin_Number.*Histogram_Count))/Cumulative_Sum(end);

    T(i) = round(T(i));

    Cumulative_Sum_2 = cumsum(Histogram_Count(1:T(i)));
    mean_below_T = sum(Bin_Number(1:T(i)).*Histogram_Count(1:T(i)))/Cumulative_Sum_2(end);

    Cumulative_Sum_3 = cumsum(Histogram_Count(T(i):end));
    mean_above_T = sum(Bin_Number(T(i):end).*Histogram_Count(T(i):end))/Cumulative_Sum_3(end);

    i = i+1;
    T(i) = round((mean_above_T+mean_below_T)/2);

%     if abs(T(i) - T(i-1)) < 1
%         Threshold = T(i);
%     end

    while abs(T(i) - T(i-1))>=1

    Cumulative_Sum_2 = cumsum(Histogram_Count(1:T(i)));
    mean_below_T = sum(Bin_Number(1:T(i)).*Histogram_Count(1:T(i)))/Cumulative_Sum_2(end);

    Cumulative_Sum_3 = cumsum(Histogram_Count(T(i):end));
    mean_above_T = sum(Bin_Number(T(i):end).*Histogram_Count(T(i):end))/Cumulative_Sum_3(end);

    i = i+1;
    T(i) = round((mean_above_T+mean_below_T)/2);

    Threshold = T(i);

    end

    level = (Threshold - 1) / (Bin_Number(end) - 1);
end