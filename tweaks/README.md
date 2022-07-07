# tweaks

> Various tweaks and handy shortcuts for the browser

This Chrome extension adds commands that are only executable via keyboard
shortcut. And only four of them are mapped by default because Chrome only
allows an extension to claim up to four keybinds automatically (you the user
can add as many more keybinds as you want, manually). It also adds a
background script that automatically removes DOM elements from certain web
pages.

Commands:

```
    "commands": {
      "css-grep": {
        "description": "Toggle css-grep UI on/off",
        "suggested_key": "Alt+G"
      },
      "close-to-right": {
        "description": "Close tabs to the right of the active tab",
        "suggested_key": "Alt+Period"
      },
      "jira-rm-column": {
        "description": "Remove right-side Jira column",
        "suggested_key": "Alt+J"
      },
      "html-root": {
        "description": "Copy entire <html> DOM element to clipboard",
        "suggested_key": "Alt+R"
      },
      "pr-commits": {
        "description": "Open each commit in current PR in its own tab"
      },
      "clear-client-state": {
        "description": "Clears all cookies under the current tab's top-level-domain, AND localStorage for the current tab"
      }
    },
```
