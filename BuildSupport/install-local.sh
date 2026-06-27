#!/bin/sh
# install-local.sh — build PastePeek (ad-hoc signed, no Apple Developer account),
# install it to /Applications, and run it always-on via a personal LaunchAgent.
#
# Usage:  ./BuildSupport/install-local.sh
# Re-run any time after changing the code to pick up a new build.
set -eu

REPO="$(cd "$(dirname "$0")/.." && pwd)"
LABEL="com.lizard.pastepeek.agent"
APP_DST="/Applications/PastePeek.app"
PLIST="$HOME/Library/LaunchAgents/$LABEL.plist"
DOMAIN="gui/$(id -u)"

echo ">> Building Release (ad-hoc signed)…"
xcodebuild -project "$REPO/PastePeek.xcodeproj" -scheme PastePeek \
  -configuration Release -derivedDataPath "$REPO/build/dd" \
  CODE_SIGN_IDENTITY="-" CODE_SIGNING_REQUIRED=YES CODE_SIGNING_ALLOWED=YES \
  build >/dev/null

APP_SRC="$REPO/build/dd/Build/Products/Release/PastePeek.app"

echo ">> Stopping any running instance…"
launchctl bootout "$DOMAIN/$LABEL" 2>/dev/null || true
pkill -f "$APP_DST/Contents/MacOS/PastePeek" 2>/dev/null || true
sleep 1

echo ">> Installing to $APP_DST…"
rm -rf "$APP_DST"
cp -R "$APP_SRC" "$APP_DST"

echo ">> Writing LaunchAgent $PLIST…"
cat > "$PLIST" <<EOF
<?xml version="1.0" encoding="UTF-8"?>
<!DOCTYPE plist PUBLIC "-//Apple//DTD PLIST 1.0//EN" "http://www.apple.com/DTDs/PropertyList-1.0.dtd">
<plist version="1.0">
<dict>
	<key>Label</key>
	<string>$LABEL</string>
	<key>ProgramArguments</key>
	<array>
		<string>$APP_DST/Contents/MacOS/PastePeek</string>
		<string>--background</string>
	</array>
	<key>RunAtLoad</key>
	<true/>
	<key>KeepAlive</key>
	<true/>
	<key>LimitLoadToSessionType</key>
	<string>Aqua</string>
	<key>AssociatedBundleIdentifiers</key>
	<array>
		<string>com.lizard.pastepeek</string>
	</array>
</dict>
</plist>
EOF

echo ">> Loading and starting…"
launchctl bootstrap "$DOMAIN" "$PLIST"
launchctl enable "$DOMAIN/$LABEL"
launchctl kickstart -k "$DOMAIN/$LABEL"
sleep 2

if pgrep -f "$APP_DST/Contents/MacOS/PastePeek" >/dev/null; then
  echo ">> ✓ PastePeek is running and will auto-start at login."
else
  echo ">> ✗ Not running. Check: launchctl print $DOMAIN/$LABEL"
  exit 1
fi
