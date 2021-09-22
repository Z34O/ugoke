ART_ID="$1"
DELAY="$2"

if [ "$ART_ID" == "" ]; then
    # Output help if supplied with no arguments
    printf "ugoke v0.1\n"
    printf "Download Pixiv (ugoira) from the command line\n\n"
    printf "Usage: ugoke <art id> <delay>\n"
    printf "ART ID: Number that uniquely identifies the artwork\n"
    printf "        https://www.pixiv.net//member_illust.php?mode=medium&illust_id=<art id>\n"
    printf "DELAY:  Delay count for imagemagick's convert command\n\n"
    printf "Run './ugoke.sh setup' to install necessary packages\n"
    exit
fi

if [ "$ART_ID" == "setup" ]; then
    # Download necessary packages
    apt install jq > /dev/null          # For parsing JSON
    apt install imagemagick > /dev/null # Converting PNGs to GIF
    exit
fi

# URLs
META_INFO="https://www.pixiv.net/ajax/illust/${ART_ID}/ugoira_meta"
ART_URL="https://www.pixiv.net/member_illust.php?mode=medium&illust_id=${ART_ID}"

# Google Chrome User Agent (Very common)
USER_AGENT="Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/74.0.3729.169 Safari/537.36"

# Get original source file (zip)
printf "\033[1;33mGetting original source file...\n"
SOURCE=$(curl -s "$META_INFO" -A "$USER_AGENT" | jq .body | jq .src)
CSOURCE=$(echo "$SOURCE" | sed 's/\\//g' | tr -d '"')
printf "\033[1;33mDownloading original source file...\n"
curl -s "$CSOURCE" -e "$ART_URL" -A "$USER_AGENT" -o "${ART_ID}.zip" > /dev/null

# Extract and convert
printf "\033[1;33mExtracting contents...\n"
mkdir "$ART_ID"
cd "$ART_ID"
unzip "../${ART_ID}.zip" > /dev/null
printf "\033[1;33mConverting to gif with $DELAY delay...\n"
convert -delay "$DELAY" -loop 0 *.jpg "${ART_ID}.gif"
rm *.jpg

printf "\033[1;33mDone! Saved as ./${ART_ID}/${ART_ID}.gif"

# Restart colors
printf "\033[0;30m"
