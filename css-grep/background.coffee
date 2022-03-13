tabs = {}

get = (id) ->
  if not tabs[id]
    console.log 'making new tab ', id, tabs
    tabs[id] = showing: false
  return tabs[id]

enable = (id) ->
  get(id).showing = true
  chrome.action.setIcon path: 'icon-green.png'
  chrome.scripting.executeScript
    target: tabId: id
    world: 'MAIN'
    func: -> show()

disable = (id) ->
  get(id).showing = false
  chrome.action.setIcon path: 'icon-white.png'
  chrome.scripting.executeScript
    target: tabId: id
    world: 'MAIN'
    func: -> hide()

commands =
  'css-grep': (id) ->
    if get(id).showing
      disable(id)
    else
      enable(id)

  'close-to-right': (id) ->
    all = await chrome.tabs.query(currentWindow: true)
    activeTab = await all.find (t) -> t.active or t.id is id
    removeIds = all
        .filter (t) -> not t.pinned and (t.index > activeTab.index)
        .map (t) -> t.id
    removeIds.reverse()
    chrome.tabs.remove(removeIds)

  'jira-rm-column': (id) ->
    chrome.scripting.executeScript
      target: tabId: id
      func: ->
        document.getElementById("jira-issue-header-actions")?.parentElement?.parentElement?.remove()
        document.getElementById("jira-issue-header")?.nextSibling?.nextSibling?.nextSibling?.remove()

  'pr-commits': (id) ->
    chrome.scripting.executeScript
      target: tabId: id
      func: ->
        document.querySelectorAll(".tabnav a")?[1]?.click()
        setTimeout ->
          document.querySelectorAll('a[aria-label="View commit details"]').forEach (c) ->
            window.open(c.href, '_blank')
        , 1000
  'html-root': (id) ->
    chrome.scripting.executeScript
      target: tabId: id
      func: -> navigator.clipboard.writeText(document.documentElement.outerHTML)

# make sure the extension icon stays up to date between tab switches
chrome.tabs.onActivated.addListener (obj) ->
  return if obj?.tabId is chrome.tabs.TAB_ID_NONE
  tab = get(obj.tabId)
  if tab.showing
    enable(obj.tabId)
  else
    disable(obj.tabId)

# handle keyboard commands
chrome.commands.onCommand.addListener (command, tab) ->
  return if tab?.id is chrome.tabs.TAB_ID_NONE
  commands[command](tab.id)

# handle the extension icon getting clicked
chrome.action.onClicked.addListener (tab) ->
  commands['css-grep'](tab.id)

# handle messages send from in-page javascript via window.postMessage -> runtime.sendMessage
chrome.runtime.onMessage.addListener (msg, sender, sendResponse) ->
  return unless msg is 'clicked-close'
  get(sender.tab.id).showing = false
  chrome.action.setIcon path: 'icon-white.png'
  sendResponse {}

# automaticallyd delete DOM elements for some sites
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

  return if url.protocol is 'chrome'

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
      world: 'MAIN'
      func: medium
    if url.host.match /redfin\.com$/i
      chrome.scripting.executeScript
        target: tabId: tab.id
        func: redfin
  , 5000
