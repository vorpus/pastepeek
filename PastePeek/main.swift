import AppKit

// PastePeek uses an explicit AppKit entry point (no SwiftUI App lifecycle and no
// @main) so we have full control over the activation policy and window lifecycle.
// Top-level code in main.swift runs on the main actor, so touching NSApplication
// here is safe.
let app = NSApplication.shared
let delegate = AppDelegate()
app.delegate = delegate
app.run()
