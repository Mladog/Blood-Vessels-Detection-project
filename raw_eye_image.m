classdef raw_eye_image < eye_pattern
    properties (Access = 'private')
        green_channel
    end
    
    methods
        
        function set.green_channel(obj, val)
            obj.green_channel = val;
        end
        
        function im = get.green_channel(obj)
            im = obj.green_channel;
        end
    end
    
    methods
        % constructor
        function obj = raw_eye_image
            obj.crop;
            obj.process;
        end
        
        % update raw image
        function update(obj)
            obj.importData;
            obj.crop;
            obj.process;
        end
        
        function crop(obj) % function to crop image by the area of interest
            gray_image = rgb2gray(obj.original_image);
            [row, col] = size(gray_image);
            
            %some raw images have frames, that could be detected as edges
            cut_image = gray_image(5:row-5, 5:col-5, :);
            
            %brightening the image to make edges more visible (necessary
            %for dark images)
            brighten_image = imlocalbrighten(cut_image);
            
            edged_image = edge(brighten_image, 'nothinning'); %detecting the edges in image
            edged_image = bwareaopen(edged_image,30); %deleting noise

            %finding detected area
            [x,y] = find(edged_image == 1); 
            min_row = min(x); 
            max_row = max(x);
            min_column = min(y);
            max_column = max(y);
            
            %in the process function, we will be operating on green
            %channel, as the vessels are the easiest to be found then
            obj.green_channel = obj.original_image(:, :, 2);
            obj.resized_image = obj.original_image(min_row:max_row, min_column:max_column, :);
            obj.resized_image = imresize(obj.resized_image, [584 565]);
            cropped_image = obj.green_channel(min_row:max_row, min_column:max_column, :);
            
            
            %resizing image to have both raw image and patter in the same
            %size and to have better calculation time 
            obj.green_channel = imresize(cropped_image, [584 565]);
        end   
                
        function process(obj)
            %brightening the image to find treshold more efficienty
            brighten_image = imlocalbrighten(obj.green_channel, 0.3);
            
            %making better contrast
            enhanced_image = adapthisteq(brighten_image, 'numTiles', [8 8], 'nBins', 128);
            
            %creating a filter
            avg_filter = fspecial('average', [9 9]);
            
            %use of created filter
            filtered_image = imfilter(enhanced_image, avg_filter);
            
            %subtracting filtrated image from enhanced
            subtracted_image = imsubtract(filtered_image, enhanced_image);
            
            %defining an treshold level
            level = treshold(subtracted_image);
            
            %binarizing the image using calculated treshold
            binary_image = imbinarize(subtracted_image, level-0.005);
            
            %deleting the noise
            obj.processed_image = bwareaopen(binary_image, 80);
        end 
    end
end
