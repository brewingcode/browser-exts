url = new URL(window.location.href)
return if url.protocol is 'chrome:'

s = document.createElement('script')
s.src = chrome.runtime.getURL('grep.js')
(document.head or document.documentElement).appendChild(s)

window.addEventListener 'message', (e) ->
    return if e.source isnt window
    chrome.runtime.sendMessage(e.data) if e.data is 'clicked-close'
    return false
, false
