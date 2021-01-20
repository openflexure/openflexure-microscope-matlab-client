function outputArg = replace_dots_dashes(text)
    %replace_dots Replace . with _DOT_
    %
    text = replace(text,'-','_DASH_');
    outputArg = replace(text,'.','_DOT_');
end  