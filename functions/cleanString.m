function cleanStr = cleanString(str)
%CLEANSTRING function to clean up a string and make it a valid variable
%name.  Could possibly be done with genvarname but I don't really like how
%that handles special characters
cleanStr = strrep(str,' ','');
cleanStr = strrep(cleanStr,'<','');
cleanStr = strrep(cleanStr,'>','');
cleanStr = strrep(cleanStr,'''','');
end

