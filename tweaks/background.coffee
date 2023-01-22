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

tabsToRight = (id) ->
    all = await chrome.tabs.query(currentWindow: true)
    activeTab = await all.find (t) -> t.active or t.id is id
    toRight = all
        .filter (t) -> not t.pinned and (t.index > activeTab.index)
    toRight.reverse()
    return [activeTab, toRight...]

commands =
  'css-grep': (id) ->
    if get(id).showing
      disable(id)
    else
      enable(id)

  'close-to-right': (id) ->
    chrome.tabs.remove (await tabsToRight id).slice(1).map (t) -> t.id

  'new-window-to-right': (id) ->
    tabs = await tabsToRight(id) # NOTE: must come before chrome.windows.create()

    wind = await chrome.windows.create
      focused: true
      tabId: tabs.shift().id

    tabs.reverse()
    await chrome.tabs.move (tabs.map (t) -> t.id),
      index: -1
      windowId: wind.id

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

  'clear-client-state': (id) ->
    tab = await chrome.tabs.get id
    cookies = await chrome.cookies.getAll
      url: tab.url

    await chrome.scripting.executeScript
      target: tabId: id
      args: [ tab.url, cookies ]
      func: (url, cookies) ->
        console.log "clearing localStorage for #{url}"
        console.table Object.entries(localStorage)
        console.table cookies
        localStorage.clear()
        console.log "clearing cookies for url: #{url}"

    for c in cookies
      proto = 'http' + if c.secure then 's' else ''
      await chrome.cookies.remove
        url: "#{proto}://#{c.domain}#{c.path}"
        name: c.name

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

listening = {}

# automatically delete DOM elements for some sites
chrome.tabs.onUpdated.addListener (tabId, info, tab) ->

  # console.log 'tabs.onUpdated', tab
  return unless info.status is 'complete'
  url = new URL(tab.url)
  return if url.protocol is 'chrome:'

  return if listening[tabId]
  listening[tabId] = true

  fandom = ->
    document.querySelector(".page__right-rail")?.remove()
    document.querySelector(".global-navigation")?.remove()
    document.querySelector(".global-footer")?.remove()
    document.querySelector(".fandom-sticky-header")?.remove()
    document.querySelector("#mixed-content-footer")?.remove()
    document.querySelector(".wds-global-footer")?.remove()
    document.querySelector('.notifications-placeholder')?.remove()
    document.querySelector('.main-container')?.style.setProperty('width', '100%')
    document.querySelector('.main-container')?.style.setProperty('margin-left', 0)
    document.getElementById('WikiaBar')?.remove()
    document.getElementById("mixed-content-footer")?.remove()

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

    # add link to Zillow
    h = document.querySelector('h1.homeAddress')
    if not h.querySelector('a')
      space = document.createElement('span')
      space.innerHTML = '&nbsp;'

      addr = h.textContent.replace /[\s,]/g, '-'
      a = document.createElement('a')
      a.target = '_blank'
      a.href = 'https://www.zillow.com/homes/'+addr+'_rb/'
      a.textContent = '[Z]'

      h.appendChild(space)
      h.appendChild(a)

  zillow = ->
    document.querySelector('ul.zsg-tooltip-viewport').querySelector('li').remove()

    details = document.querySelector('#Home-details')
    divs = details.nextSibling.querySelectorAll('.hdp__sc-1j01zad-1.hmkpQE')

    dest = document.querySelector('#Home-value').nextSibling.querySelector('.hdp__sc-1j01zad-0.bNxDKz').parentElement
    dest.prepend(divs[2])

  # forces a scroll, don't do yet
  # document.querySelector(".bottom-link-propertyHistory")?.click()

  github = ->
    a = document.querySelector('a#pull-requests-tab')
    if (window.location.href.indexOf('?') is -1) and (a.href.indexOf('?') is -1)
      a.href = a.href + '?q=is%3Apr+-label%3Adependencies+sort%3Aupdated-desc'
    else
      i = window.location.href.indexOf('?')
      if i > 0
        a.href = window.location.href.slice(0,i)

  setTimeout ->
    if url.host.match /fandom\.com$/i
      chrome.scripting.executeScript
        target: tabId: tab.id
        func: fandom
    else if url.host.match /wikipedia\.org$/i
      chrome.scripting.executeScript
        target: tabId: tab.id
        func: wikipedia
    else if  url.host.match /zillow\.com$/i
      chrome.scripting.executeScript
        target: tabId: tab.id
        func: zillow
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
  , 3000

  setInterval ->
    if  url.host.match /github\.com$/i
      chrome.scripting.executeScript
        target: tabId: tab.id
        func: github
  , 2000
