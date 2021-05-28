classdef raw_eye_image < eye_pattern
    properties 
        gray_image
    end
    
    methods
        function set.gray_image(obj, val)
            obj.gray_image = val;
        end
        
        function im = get.gray_image(obj)
            im = obj.gray_image;
        end
    end
    
    methods
        % constructor
        function obj = raw_eye_image
            obj.crop_color_image;
            obj.process;
        end
        
        function crop_color_image(obj)
            obj.gray_image = rgb2gray(obj.original_image);
            [row, col] = size(obj.gray_image);
            
            %some raw images may have frames, that may be detected as edge
            obj.processed_image = obj.gray_image(3:row-3, 3:col-3, :);
            obj.crop;
        end
                
        function process(obj)
            enhanced_image = adapthisteq(obj.resized_image, 'numTiles', [8 8], 'nBins', 128); %wyostrzenie
            avg_filter = fspecial('average', [9 9]); %filtracja
            filtered_image = imfilter(enhanced_image, avg_filter);
            subtracted_image = imsubtract(filtered_image, enhanced_image);
            level = treshold(subtracted_image);
            binary_image = imbinarize(subtracted_image, level-0.005);
            obj.processed_image = bwareaopen(binary_image, 80);
        end
        
    end
    
end
