
chrome.tabs.onUpdated.addListener (tabId, info, tab) ->
    return unless info.status is 'complete'
    setTimeout ->
        url = new URL(tab.url)
        if url.host.match /fandom\.com$/i
            chrome.tabs.executeScript tab.id, code: 'document.querySelector(".page__right-rail").remove()'
    , 500
