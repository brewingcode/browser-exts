chrome.commands.onCommand.addListener (command) -> #async
    tabs = await chrome.tabs.query(currentWindow: true)
    activeTab = await tabs.find (t) -> t.active
    removeIds = tabs
        .filter (t) -> not t.pinned and (t.index > activeTab.index)
        .map (t) -> t.id
    removeIds.reverse()
    chrome.tabs.remove(removeIds)

chrome.tabs.onUpdated.addListener (tabId, info, tab) ->

    return unless info.status is 'complete'

    fandom = ->
        document.querySelector(".page__right-rail")?.remove()
        document.querySelector(".global-navigation")?.remove()
        document.querySelector(".fandom-sticky-header")?.remove()
        document.querySelector("#mixed-content-footer")?.remove()
        document.querySelector(".wds-global-footer")?.remove()
        document.querySelector('.main-container')?.style.setProperty('width', '100%')
        document.querySelector('.main-container')?.style.setProperty('margin-left', 0)
        document.getElementById('WikiaBar')?.remove()

    wikipedia = ->
        document.getElementById('content')?.style.setProperty('margin-left', 0)
        document.getElementById('mw-panel')?.remove()
        document.getElementById('siteNotice')?.remove()
        document.getElementById('frb-inline')?.remove()

    medium = ->
        document.querySelector('[aria-label="Sign in with Google"]')?.parentElement?.parentElement?.remove()

    redfin = ->
        document.querySelector(".AskAnAgentSection")?.remove()
        document.querySelector(".OpenHouseSectionDesktop")?.remove()
        document.querySelector(".HigherSimilarsSection")?.remove()
        document.querySelector(".AmenitiesInfoSection")?.remove()
        document.querySelector(".SchoolsSection")?.remove()
        document.querySelector(".theRail")?.remove()
        document.querySelector(".DPRedfinEstimateSection")?.remove()
        document.querySelector(".RecommendedsSection")?.remove()
        document.querySelector(".SimilarSoldsSection")?.remove()
        document.querySelector(".SimilarsSection")?.remove()
        document.querySelector(".SmartInterlinksSection")?.remove()
        document.querySelector(".FAQSection")?.remove()
        document.querySelector(".OwnerToolsSection")?.remove()

        # forces a scroll, don't do yet
        # document.querySelector(".bottom-link-propertyHistory")?.click()

    url = new URL(tab.url)

    setTimeout ->
        if url.host.match /fandom\.com$/i
            chrome.scripting.executeScript
                target: tabId: tab.id
                func: fandom
        else if url.host.match /wikipedia\.org$/i
            chrome.scripting.executeScript
                target: tabId: tab.id
                func: wikipedia
    , 500

    setTimeout ->
        chrome.scripting.executeScript
            target: tabId: tab.id
            func: medium
        if url.host.match /redfin\.com$/i
            chrome.scripting.executeScript
                target: tabId: tab.id
                func: redfin
    , 5000
