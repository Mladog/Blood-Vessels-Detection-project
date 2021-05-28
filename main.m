%% testing eye pattern
obraz1 = eye_pattern;
obraz1.get_final_eye_pattern;
%% testing raw eye image
obraz2 = raw_eye_image;

%%
porownaj1 = imread('clean.jpg');
porownaj2 = imread('rotate.jpg');
compare_two_images(obraz1.processed_image, obraz2.processed_image)

%compare_two_images(porownaj1, porownaj2);
