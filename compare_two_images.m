function returned = compare_two_images(detected, pattern)
%this function will compare two images: detected by the user and pattern
    
    detected = im2uint8(detected);
    pattern = im2uint8(pattern);
    
    %defining best value and angle as 0
    best_angle = 0;
    ssimval = 0;

    %rotating the image to fing the right angle (pattern does not have to be
    %rotated the same way)

    for i = 0:5:355
        rotated_pattern = imrotate(pattern, i, 'crop');
        ssimval_temp = ssim(detected, rotated_pattern);
        % if ssim (structural similarity) value is better in this
        % itteration, save ssim and rotation angle (i)
        if ssimval_temp > ssimval
            ssimval = ssimval_temp;
            best_angle = i;
        end
        
    end

    %save a pattern for best ssim value 
    best_pattern =  imrotate(pattern, best_angle, 'crop');
    
    %searching for characteristic points of image
    ptsOriginal  = detectSURFFeatures(best_pattern);
    ptsDistorted = detectSURFFeatures(detected);

    %function returnind feature vectors and their location
    [featuresOriginal,  validPtsOriginal]  = extractFeatures(best_pattern,  ptsOriginal);
    [featuresDistorted, validPtsDistorted] = extractFeatures(detected, ptsDistorted);
    
    %finding matching features of two given images
    indexPairs = matchFeatures(featuresOriginal, featuresDistorted);
    
    %creating objects storing matched points for both images 
    matched_pattern = validPtsOriginal(indexPairs(:,1));
    matched_detected = validPtsDistorted(indexPairs(:,2));

    %number of matched points
    score = size(indexPairs,1);
        
    % add percentage of detected features
    f_original = ptsOriginal.Count;
    f_distorted = ptsDistorted.Count;
    
    if f_original > f_distorted
        worse_quality_detected = f_distorted;
    else
        worse_quality_detected = f_original;
    end
    
    % values to return
    returned.best_pattern = best_pattern;
    returned.detected = detected;
    returned.matchedP = matched_pattern;
    returned.matchedD = matched_detected;
    returned.score = score;
    returned.SSIM = ssimval;
    returned.percentage = score/worse_quality_detected*100;
    
end