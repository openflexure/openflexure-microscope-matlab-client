classdef RequestableURI <handle
    %RequestableURI
    %
    %RequestableURI Properties:
    %   href - The href for the RequestableURI.
    %   description - The description of the RequestableURI.
    %   methods_ - The methods (e.g. GET, POST) available for the Requestable URI. 
    %
    %RequestableURI Methods:
    %   get_json - Make an HTTP GET request to the RequestableURI's href and return the response. 
    %   post_json - Make an HTTP POST request to the RequestableURI's href and return the result.
    %
    %   See also: is_a_task, poll_task.
    properties
        href        %The href for the RequestableURI. (char)
        description %The description of the RequestableURI. (char)
        methods_    %The methods (e.g. GET, POST) available for the Requestable URI. (cell)
    end
    
    methods
        function obj = RequestableURI(link)
            %RequestableURI Construct an instance of this class
            %   
            obj.href = link.href;
            obj.description = link.description;
            obj.methods_ = link.methods;
        end
        
        function outputArg = get_json(obj)
            %get_json Make an HTTP GET request to the RequestableURI's href and return the response.
            options = weboptions('Timeout',60);
            outputArg =  webread(obj.href, options);      
        end

        function outputArg = post_json(obj, payload, waitOnTask,headerFields)
            %post_json Make an HTTP GET request to the RequestableURI's
            %href and return the reponse.
            arguments
                obj
                payload struct  = struct;
                waitOnTask char = 'auto';             
                headerFields cell = {' ' ' '};
            end
                        
            if ~any(strcmp(obj.methods_,"POST"))
                error("This URI does not support POST requests");
            end
                
            
            options = weboptions('Timeout',60, 'RequestMethod', 'post','HeaderFields',headerFields);
            r = webwrite(obj.href, payload, options);
            
            if (strcmp(waitOnTask,'auto'))
                waitOnTask = is_a_task(r);
            end
            if waitOnTask
                outputArg = poll_task(r);
            else
                outputArg = r;
            end
        end
    end
end

