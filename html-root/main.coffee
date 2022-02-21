
run = (tabId) ->
    chrome.scripting.executeScript
        target: { tabId }
        func: -> navigator.clipboard.writeText(document.documentElement.outerHTML)

chrome.commands.onCommand.addListener (command) -> #async
    tabs = await chrome.tabs.query(currentWindow: true)
    activeTab = await tabs.find (t) -> t.active
    run activeTab.id

chrome.action.onClicked.addListener (tab) -> run tab.id
