tabs = {}

get = (id) ->
  if not tabs[id]
    tabs[id] = showing: false
  return tabs[id]

enable = (id) ->
  get(id).showing = true
  chrome.action.setIcon path: 'icon-green.png'
  chrome.scripting.executeScript
    target: tabId: id
    func: -> show()

disable = (id) ->
  get(id).showing = false
  chrome.action.setIcon path: 'icon-white.png'
  chrome.scripting.executeScript
    target: tabId: id
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
  tab = await chrome.tabs.get obj.tabId
  # console.log 'tabs.onActivated', tab
  return unless tab.status is 'complete'
  url = new URL(tab.url)
  return if url.protocol is 'chrome:'

  if get(tab.id).showing
    enable(tab.id)
  else
    disable(tab.id)

# handle keyboard commands
chrome.commands.onCommand.addListener (command, tab) ->
  # console.log 'commands.onCommand'
  commands[command](tab.id)

# handle the extension icon getting clicked
chrome.action.onClicked.addListener (tab) ->
  # console.log 'action.onClicked'
  commands['css-grep'](tab.id)

# handle messages send from in-page javascript via window.postMessage -> runtime.sendMessage
chrome.runtime.onMessage.addListener (msg, sender, sendResponse) ->
  # console.log 'runtime.onMessage'
  return unless msg is 'clicked-close'
  get(sender.tab.id).showing = false
  chrome.action.setIcon path: 'icon-white.png'
  sendResponse {}

# automatically delete DOM elements for some sites
chrome.tabs.onUpdated.addListener (tabId, info, tab) ->
  # console.log 'tabs.onUpdated', tab
  return unless info.status is 'complete'
  url = new URL(tab.url)
  return if url.protocol is 'chrome:'

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
    document.querySelector(".SaleProceedsSection")?.remove()
    document.querySelector(".CostOfOwnership")?.remove()
    document.querySelector(".ListingScanSection")?.remove()
    document.querySelector(".RentalEstimateSection")?.remove()
    document.querySelector(".ClimateRiskDataSection")?.remove()

  # forces a scroll, don't do yet
  # document.querySelector(".bottom-link-propertyHistory")?.click()

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
