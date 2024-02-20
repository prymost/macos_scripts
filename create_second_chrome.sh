#!/bin/bash

PROFILE_NAME=$1
mkdir -p "/Applications/Google Chrome $PROFILE_NAME.app/Contents/MacOS"

F="/Applications/Google Chrome $PROFILE_NAME.app/Contents/MacOS/Google Chrome $PROFILE_NAME"
cat > "$F" <<\EOF
#!/bin/bash

#
# Google Chrome for Mac with additional profile.
#

# Name your profile:
EOF

echo "PROFILE_NAME='$PROFILE_NAME'\n" >> "$F"

cat >> "$F" <<\EOF
# Store the profile here:
PROFILE_DIR="/Users/$USER/Library/Application Support/Google/Chrome/${PROFILE_NAME}"

# Find the Google Chrome binary:
CHROME_APP=$(mdfind 'kMDItemCFBundleIdentifier == "com.google.Chrome"' | head -1)
CHROME_BIN="$CHROME_APP/Contents/MacOS/Google Chrome"
if [[ ! -e "$CHROME_BIN" ]]; then
  echo "ERROR: Can not find Google Chrome.  Exiting."
  exit -1
fi

# Start me up!
exec "$CHROME_BIN" --enable-udd-profiles --user-data-dir="$PROFILE_DIR"
EOF

sudo chmod +x "$F"
