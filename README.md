# PastePeek
"wait, what did I just copy?"

### A tiny window into your clipboard.

You copy things all day and then just... hope. Hope it grabbed the right thing.
Hope that website didn't sneak in a "read more at example.com" footer. Hope the
GIF is actually a GIF and not a sad frozen first frame. PastePeek is the little
friend that peeks at your clipboard and shows you, for half a second, what you
actually copied.

That's it. That's the app. It's quietly delightful.

## Watch it in action
<a href="https://www.youtube.com/watch?v=ZdvUT1rVees"><img width="843" height="513" alt="Screenshot 2026-06-20 at 3 38 30 PM" src="https://github.com/user-attachments/assets/890d56a7-d329-4d4f-a955-ad2e6304da08" /></a>




## Getting it running

PastePeek is a native macOS app (macOS 14 and up). Built with Swift and a healthy
amount of affection.

```sh
open PastePeek.xcodeproj   # then hit Run
```

Via CLI

```sh
xcodebuild -project PastePeek.xcodeproj -scheme PastePeek -configuration Debug build
open ~/Library/Developer/Xcode/DerivedData/PastePeek-*/Build/Products/Debug/PastePeek.app
```

## Always-on, just for you (no Apple Developer account)

Want PastePeek running quietly in the background and starting itself at every
login? You don't need a paid Developer account — an ad-hoc-signed build plus a
personal LaunchAgent is enough for your own Mac.

```sh
./BuildSupport/install-local.sh
```

That script builds a Release (ad-hoc signed), installs it to
`/Applications/PastePeek.app`, and writes a LaunchAgent to
`~/Library/LaunchAgents/com.lizard.pastepeek.agent.plist` that launches it with
`--background` (so it stays invisible). `RunAtLoad` starts it at login and
`KeepAlive` brings it back if it ever quits. Re-run the script any time after
changing the code to pick up a new build.

Handy follow-ups:

```sh
launchctl print gui/$(id -u)/com.lizard.pastepeek.agent    # status
launchctl bootout gui/$(id -u)/com.lizard.pastepeek.agent  # stop it now
rm ~/Library/LaunchAgents/com.lizard.pastepeek.agent.plist # don't start at login
```

Since PastePeek is an accessory app (no Dock or menu-bar icon), its only UI once
running is the corner toast. To reach Settings, launch it without the background
flag: `open -a PastePeek`.

## A peek under the hood

Curious how it works? The design notes live in [docs/](docs/): how it classifies
clipboard content, how it stays invisible, and the little decisions that add up to
something that feels nice to use.

