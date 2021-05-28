function compare_two_images(detected, pattern)
%this function will compare two images: detected by the user and pattern
    
    detected = im2uint8(detected);
    pattern = im2uint8(pattern);
    
    %defining best value as 0
    st_best.angle = 0;
    st_best.ssimval = 0;

    %rotating the image to fing the right angle (pattern does not have to be
    %rotated the same way)

    for i = 0:5:355
        rotated_pattern = imrotate(pattern, i, 'crop');
        ssimval = ssim(detected, rotated_pattern);
        % if ssim (structural similarity) value is better in this
        % itteration, save ssim and rotation angle (i)
        if ssimval > st_best.ssimval
            st_best.ssimval = ssimval;
            st_best.angle = i;
        end
        
    end

    %save a pattern for best ssim value 
    best_pattern =  imrotate(pattern, st_best.angle, 'crop');
    
    %searching for characteristic points of image
    ptsOriginal  = detectSURFFeatures(best_pattern);
    ptsDistorted = detectSURFFeatures(detected);

    %function returnind feature vectors and their location
    [featuresOriginal,  validPtsOriginal]  = extractFeatures(best_pattern,  ptsOriginal);
    [featuresDistorted, validPtsDistorted] = extractFeatures(detected, ptsDistorted);
    
    %finding matching features of two given images
    indexPairs = matchFeatures(featuresOriginal, featuresDistorted);
    
    %creating objects storing matched points for both images 
    st_best.matched_pattern = validPtsOriginal(indexPairs(:,1));
    st_best.matched_detected = validPtsDistorted(indexPairs(:,2));

    %number of matched points
    st_best.score = size(indexPairs,1);
   
    subplot(3,1,1)
    imshowpair(pattern,detected,'montage');
    title('loaded images');
    
    subplot(3,1,2)
    imshowpair(insertMarker(best_pattern, st_best.matched_pattern),insertMarker(detected,st_best.matched_detected),'montage');
    title('Detected features and matched angle');

    subplot(3,1,3)
    showMatchedFeatures((best_pattern), (detected), st_best.matched_pattern, st_best.matched_detected,'montage');
    title(['Detected ' num2str(st_best.score) ' matched features'])

    
    msg_ssim = ['SSIM value is ',num2str(st_best.ssimval)]; % 1 means identical
    disp(msg_ssim);

    % add percentage of detected features
end