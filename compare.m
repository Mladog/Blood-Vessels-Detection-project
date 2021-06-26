classdef compare < matlab.mixin.SetGet
    
    properties (Access = 'private')
        pattern_image %input value of loaded pattern
        detected_image %input value of detected pattern
    end
    
    properties (SetAccess = private, GetAccess = public)
        ssimval %best ssim value for two input images
        score %number of matched features detected
        matched_features %objects storing matched points
        percentage %percentage of matched features in all features
        best_pattern %image rotated with best angle
    end
    
     methods

        function set.pattern_image(obj, val)
            expected_size = [584 565];
            image_size = size(val);
            if image_size(1) ~= expected_size(1) || image_size(2) ~= expected_size(2)
                error('pattern was not processed')
            end
            obj.pattern_image = val;
        end

        function im = get.pattern_image(obj)
            im = obj.pattern_image;
        end

        function set.detected_image(obj, val)
            expected_size = [584 565];
            image_size = size(val);
            if image_size(1) ~= expected_size(1) || image_size(2) ~= expected_size(2)
                error('image was not processed')
            end
            obj.detected_image = val;
        end

        function im = get.detected_image(obj)
            im = obj.detected_image;
        end

        function set.best_pattern(obj, val)
            expected_size = [584 565];
            image_size = size(val);
            if image_size(1) ~= expected_size(1) || image_size(2) ~= expected_size(2)
                error('image was not processed')
            end
            obj.best_pattern = val;
        end

        function im = get.best_pattern(obj)
            im = obj.best_pattern;
        end        
        
        function set.ssimval(obj, val)
            if ~isnumeric(val)
                error('ssimval must be numeric')
            end
            obj.ssimval = val;
        end

        function ssim = get.ssimval(obj)
            ssim = obj.ssimval;
        end            
 
        function set.score(obj, val)
            if ~isnumeric(val)
                error('score must be numeric')
            end
            obj.score = val;
        end

        function sc = get.score(obj)
            sc = obj.score;
        end             
        
        function set.percentage(obj, val)
            if ~isnumeric(val)
                error('percentage must be numeric')
            end
            obj.percentage = val;
        end

        function perc = get.percentage(obj)
            perc = obj.percentage;
        end        
        
        function set.matched_features(obj, val)
            obj.matched_features = val;
        end

        function im = get.matched_features(obj)
            im = obj.matched_features;
        end        
                
        % constructor
        function obj = compare(detected, pattern)

            if nargin ~= 2
                error('error using compare - not enough input arguments')
            end

            obj.detected_image = im2uint8(detected);
            obj.pattern_image = im2uint8(pattern);
            obj.find_angle;
            obj.match_features;
        end
     end
    
    methods (Access = 'private')
        function find_angle(obj)
            % creating vector for ssimval to preallocate memory 
            ssimval_vect = zeros(72,1);
            best_angle_vect = (0:5:359);
            id=1;
            for i = 0:5:355
                rotated_pattern = imrotate(obj.pattern_image, i, 'crop');
                ssimval_vect(id) = ssim(obj.detected_image, rotated_pattern);  
                id =id+1;
            end
            
            [index] = find(ssimval_vect(:) == max(ssimval_vect(:)));
            obj.ssimval = max(ssimval_vect(:));
            
            %save a pattern for best ssim value 
            obj.best_pattern =  imrotate(obj.pattern_image, best_angle_vect(index), 'crop');
        end
        
        function match_features(obj)
            %searching for characteristic points of image
            ptsOriginal  = detectSURFFeatures(obj.best_pattern);
            ptsDistorted = detectSURFFeatures(obj.detected_image);

            %function returnind feature vectors and their location
            [featuresOriginal,  validPtsOriginal]  = extractFeatures(obj.best_pattern,  ptsOriginal);
            [featuresDistorted, validPtsDistorted] = extractFeatures(obj.detected_image, ptsDistorted);

            %finding matching features of two given images
            indexPairs = matchFeatures(featuresOriginal, featuresDistorted);

            %creating objects storing matched points for both images 
            matched_pattern = validPtsOriginal(indexPairs(:,1));
            matched_detected = validPtsDistorted(indexPairs(:,2));

            %number of matched points
            obj.score = size(indexPairs,1);

            % add percentage of detected features
            f_original = ptsOriginal.Count;
            f_distorted = ptsDistorted.Count;

            if f_original > f_distorted
                worse_quality_detected = f_distorted;
            else
                worse_quality_detected = f_original;
            end
            
            obj.percentage = obj.score/worse_quality_detected*100;

            % values to return - matched features
            obj.matched_features.matchedP = matched_pattern;
            obj.matched_features.matchedD = matched_detected;            
        end
    end    
end