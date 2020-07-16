classdef MicroscopeExtension <dynamicprops
    %MicroscopeExtension A class that represents a microscope extension.
    %   Detailed explanation goes here
    
    properties (SetAccess = protected)
        extension_struct
    end
    
    methods
        function obj = MicroscopeExtension(extension_struct)
            %UNTITLED4 Construct an instance of this class
            %   Detailed explanation goes here
            obj.extension_struct = extension_struct;
            fn = fieldnames(extension_struct.links);
            for i = 1: numel(fn)
                obj.addprop(fn{i});
                link = obj.extension_struct.links.(fn{i});
                obj.(fn{i}) =RequestableURI(link);
            end
        end
        
    end
    
end

