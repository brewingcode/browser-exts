
chrome.tabs.onUpdated.addListener (tabId, info, tab) ->
    return unless info.status is 'complete'
    setTimeout ->
        url = new URL(tab.url)
        if url.host.match /fandom\.com$/i
            chrome.tabs.executeScript tab.id, code: '''
                document.querySelector(".page__right-rail").remove();
                document.querySelector(".global-navigation").remove();
                document.querySelector(".fandom-sticky-header").remove();
                document.querySelector('.main-container').style.setProperty('width', '100%');
                document.querySelector('.main-container').style.setProperty('margin-left', 0);
                document.getElementById('WikiaBar').remove();
            '''
        else if url.host.match /wikipedia\.org$/i
            chrome.tabs.executeScript tab.id, code: '''
                document.getElementById('siteNotice').remove();
                document.getElementById('mw-panel').remove();
                document.getElementById('content').style.setProperty('margin-left', 0);
              '''
    , 500
