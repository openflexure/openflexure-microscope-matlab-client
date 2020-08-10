classdef MicroscopeExtension <dynamicprops
    %MicroscopeExtension A class that represents a microscope extension.
    %   
    %MicroscopeExtension Properties:
    %   extension_struct  - A struct containing the RequestableURIs for a microscope extension.
    %
    %MicroscopeExtension Methods:
    %
    % See also RequestableURI.
    properties (SetAccess = protected)
        extension_struct %A struct containing the RequestableURIs for a microscope extension.
    end
    
    methods
        function obj = MicroscopeExtension(extension_struct)
            %MicroscopeExtension Construct an instance of this class
            % 
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

