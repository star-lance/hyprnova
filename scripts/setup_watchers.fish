#!/usr/bin/env fish

# Simple script to watch files and run commands when they change
# Usage: setup_watchers.fish

# Process JSON configuration file using jq
set json_output (cat ~/.config/hypr/file_edit_triggers.jsonc | sed 's|//.*||' | jq -r 'to_entries[] | .key, (.value | length), (.value | .[])')

# Process output in chunks of command + file count + files
set i 1
while test $i -le (count $json_output)
    # First item is the command to run
    set cmd $json_output[$i]
    set i (math $i + 1)
    
    # Second item is the number of files
    set file_count $json_output[$i]
    set i (math $i + 1)
    
    # Get all files for this command
    set files
    for j in (seq $file_count)
        # Expand environment variables in the path
        set file (eval echo $json_output[$i])
        set -a files $file
        set i (math $i + 1)
    end
    
    # Start a single entr process for all files with this command
    printf "%s\n" $files | entr -n sh -c $cmd &
    echo "Watching" (count $files) "files for command:" $cmd
end

