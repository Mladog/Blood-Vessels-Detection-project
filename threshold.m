function level = threshold(Image)
    expected_size = [584 565];
    image_size = size(Image);
    if image_size(1) ~= expected_size(1) || image_size(2) ~= expected_size(2)
        error('image was not processed')
    end

    %use of iteration method for defining threshold
    Image = im2uint8(Image(:));
    [Histogram_Count, Bin_Number] = imhist(Image);

    
    % calculating the cumulative sum of histogram
    i = 1;
    Cumulative_Sum = cumsum(Histogram_Count);
    T(i) = (sum(Bin_Number.*Histogram_Count))/Cumulative_Sum(end); 
    
    % T(i) will be an index, so it must have integer value
    T(i) = round(T(i));

    % Using T(1) as first threshold and dividing pixels into two groups
    % (below and above T). Then calculating the mean value in each group
    % and setting new threshold as average of two calculated mean values.
    Cumulative_Sum_2 = cumsum(Histogram_Count(1:T(i)));
    mean_below_T = sum(Bin_Number(1:T(i)).*Histogram_Count(1:T(i)))/Cumulative_Sum_2(end);

    Cumulative_Sum_3 = cumsum(Histogram_Count(T(i):end));
    mean_above_T = sum(Bin_Number(T(i):end).*Histogram_Count(T(i):end))/Cumulative_Sum_3(end);

    i = i+1;
    T(i) = round((mean_above_T+mean_below_T)/2);
    
    % Repeating the steps as long as the threshold is giving better results.
    % T(i) is always integer value, so the threshold is changing only when
    % thir absolute value is bigger than 1.
    while abs(T(i) - T(i-1)) >= 1
        Cumulative_Sum_2 = cumsum(Histogram_Count(1:T(i)));
        mean_below_T = sum(Bin_Number(1:T(i)).*Histogram_Count(1:T(i)))/Cumulative_Sum_2(end);

        Cumulative_Sum_3 = cumsum(Histogram_Count(T(i):end));
        mean_above_T = sum(Bin_Number(T(i):end).*Histogram_Count(T(i):end))/Cumulative_Sum_3(end);

        i = i+1;
        T(i) = round((mean_above_T+mean_below_T)/2);

        Threshold = T(i);
    end
    
    % searching if variable exists in workspace
    if ~exist('Threshold', 'var')
        error("the image's quality is too low")
    end

    % Normalization of the threshold (0-1 scale needed for imbinarize
    % function) using the min-max normalization method. Threshold can take
    % values from 1 to 255. 
    % The formula is V' = (V-min)/(max-min)*(new_max - new_min) + new_min
    level = (Threshold - 1) / (Bin_Number(end) - 1);
end