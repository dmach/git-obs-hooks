#!/bin/sh
set -eu

# REMOTE_NAME="$1" # This argument remains unused in the logic below
REMOTE_URL="$2"

parsed_output=$(echo "$REMOTE_URL" | awk '
{
    url = $0
    host = ""
    path = ""

    # Handle SCP-like syntax: user@host:path/repo.git
    # Match user@hostname:path_part
    if (match(url, /@([^:]+):(.*)/)) {
        # Extract host (part between @ and :)
        host_part = url
        sub(/:.*/, "", host_part) # Keep only user@host
        sub(/^[^@]+@/, "", host_part) # Keep only host
        host = host_part

        # Extract path (part after :)
        path_part = url
        sub(/^[^:]+:/, "", path_part) # Keep only path
        path = path_part
    }
    # Handle standard URL syntax: scheme://user@host[:port]/path/repo.git
    # Match :// followed by host part (non-slash) / path part
    else if (match(url, /:\/\/([^/]+)\/(.*)/)) {
        # Extract host part (might include user@ and :port)
        host_part = url
        sub(/^[^:]+:\/\//, "", host_part) # Remove scheme://
        sub(/\/.*/, "", host_part)        # Remove path onwards (/...)

        # Isolate host from user@host[:port]
        sub(/^[^@]+@/, "", host_part)     # Remove user@ prefix if present
        sub(/:[0-9]+$/, "", host_part)    # Remove :port suffix if present
        host = host_part

        # Extract path part
        path_part = url
        # Keep only the part after the first slash following the scheme://host
        sub(/^[^:]+:\/\/[^/]+\//, "", path_part)
        path = path_part
    } else {
         # Fallback: Cannot determine host/path from format
         path = url # Treat whole input as path
         host = ""  # Host unknown
    }

    # Clean path: Remove trailing .git if present
    sub(/\.git$/, "", path)
    # Clean path: Remove leading slash if present (important for API URL construction)
    sub(/^\//, "", path)

    # Output host and path separated by a pipe "|"
    print host "|" path
}')

host=$(echo "$parsed_output" | cut -d'|' -f1)
path=$(echo "$parsed_output" | cut -d'|' -f2-)

# Check if hostname extraction was successful
if [ -z "$host" ]; then
    echo "Error(awk): Could not extract hostname from URL: $REMOTE_URL" >&2
    # Exit code 6: Hostname extraction failed
    exit 6
fi

api_url="https://${host}/api/v1/repos/${path}"
count=""
api_response=""

# Make the API call. Handle potential curl errors gracefully with set -e.
api_response=$(curl --fail -s "$api_url" -H 'accept: application/json' || echo "curl_error")

if [ "$api_response" != "curl_error" ] && [ -n "$api_response" ]; then
    count=$(echo "$api_response" | awk '
    BEGIN { result = "awk_error" } # Default value if parsing fails
    {
        # Try to match the key, colon, and a number
        if (match($0, /"open_pr_counter"[[:space:]]*:[[:space:]]*[0-9]+/)) {
            matched_part = substr($0, RSTART, RLENGTH)
            gsub(/[^0-9]/, "", matched_part) # Remove non-digits
            if (matched_part != "") {
                result = matched_part
                exit # Found it
            }
        }
    }
    END { print result } # Print the found number or "awk_error"
    ')
elif [ "$api_response" = "curl_error" ]; then
    echo "Error(curl): Failed fetching or received error from API: $api_url" >&2
    exit 5
else
    echo "Warning: Received empty response from API (but no HTTP error): $api_url" >&2
    count="awk_error"
fi

case "$count" in
    awk_error|curl_error)
         echo "Warning: Could not determine open PR count (API/parse error)." >&2
         ;;
    *[!0-9]*)
         echo "Warning: Invalid non-numeric count value obtained: '$count'." >&2
         ;;
    0)
         # Count is 0, optionally print confirmation
         # echo "Info: Repository has 0 open pull requests."
         ;;
    *)
         echo "Remote repository ($host/$path) has $count open pull requests."
         ;;
esac

exit 0