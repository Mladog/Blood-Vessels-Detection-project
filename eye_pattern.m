classdef eye_pattern < matlab.mixin.SetGet
    % values cannot be changed or got by program
    properties (SetAccess = protected, GetAccess = protected)
        original_image
        path
    end  
    
    % values cannot be set by the program, but it can call them
    properties (SetAccess = protected, GetAccess = public)
        processed_image
        resized_image
    end
    
    methods
        function set.original_image(obj, val)
            obj.original_image = val;
        end
        
        function set.resized_image(obj, val)
            obj.resized_image = val;
        end
        
        function set.processed_image(obj, val)
            obj.processed_image = val;
        end
        
        function im = get.original_image(obj)
            im = obj.original_image;
        end
        
        function im = get.resized_image(obj)
            im = obj.resized_image;
        end
        
        function im = get.processed_image(obj)
            im = obj.processed_image;
        end
        
        % constructor
        % subclass must run superclass constructor, so operations done only
        % on pattern cannot be called in the constructor
        function obj = eye_pattern
            obj.importData;
        end
        
        % functions to operate on pattern 
        function get_final_eye_pattern(obj)
            obj.binarize;
            obj.crop;            
        end
        
    end
        
        methods (Access = 'private')
        % cropping
        function crop(obj) % function to crop image by the area of interest
            edged_image = edge(obj.processed_image, 'nothinning'); %detecting the edges from image

            %finding detected area
            [x,y] = find(edged_image==1); 
            min_row = min(x);
            max_row = max(x);
            min_column = min(y);
            max_column = max(y);

           cropped_image = obj.processed_image(min_row:max_row, min_column:max_column, :);
           obj.resized_image = imresize(cropped_image, [584 565]);
        end   
    

        function importData(obj) %function to import photo from user's computer
            
            [file,pt] = uigetfile({'*.jpg';'*.png';},'File Selector');
            if isnumeric(file) || isnumeric(pt) %if there is no path given
                error('path not given')
            end
            fullpath = {pt, file};
            obj.path = strjoin(fullpath, '');

            imported = imread([pt, file]);
            obj.original_image = imported;
        end

        function binarize(obj) %function to check if given image is binary
            [~, ~, numberOfColorChannels] = size(obj.original_image);
            if numberOfColorChannels > 1 %means it's not binary, 
                error('wrong picture color')
            end
            image_info = imfinfo(obj.path);
            bits = image_info.BitDepth;
            
            if bits == 2
                binary_image = obj.original_image;
                %cleaning noise
                obj.processed_image = bwareaopen(binary_image, 80);
                
            %if BitDepth < 10 -> image is binary, but lost quality while compresion
            elseif bits < 10 
                binary_image = imbinarize(obj.original_image);
                %cleaning noise
                obj.processed_image = bwareaopen(binary_image, 80);
                
            else
                error('image is not black-white')
            end

        end
    end
    
end
