# PastePeek
"wait, what did I just copy?"

### A tiny window into your clipboard.

You copy things all day and then just... hope. Hope it grabbed the right thing.
Hope that website didn't sneak in a "read more at example.com" footer. Hope the
GIF is actually a GIF and not a sad frozen first frame. PastePeek is the little
friend that peeks at your clipboard and shows you, for half a second, what you
actually copied.

That's it. That's the app. It's quietly delightful.

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

## A peek under the hood

Curious how it works? The design notes live in [docs/](docs/): how it classifies
clipboard content, how it stays invisible, and the little decisions that add up to
something that feels nice to use.

