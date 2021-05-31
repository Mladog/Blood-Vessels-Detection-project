%% testing eye pattern
obraz1 = eye_pattern;
obraz1.get_final_eye_pattern;
imshow(obraz1.processed_image)
%% testing raw eye image
obraz2 = raw_eye_image;
imshow(obraz2.processed_image)
%%
[best_pattern, detected, matchedP, matchedD, SSIM, score] = compare_two_images(obraz1.processed_image, obraz2.processed_image);
%%
detected_image = showMatchedFeatures((best_pattern), (detected), matchedP, matchedD,'montage');
    
% porownaj1 = imread('clean.jpg');
% porownaj2 = imread('rotate.jpg');
% compare_two_images(porownaj1, porownaj2);
