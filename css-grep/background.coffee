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

toggle = (tab) ->
  id = tab?.id
  if id and id isnt chrome.tabs.TAB_ID_NONE
    if get(tab.id).showing
      disable(id)
    else
      enable(id)

chrome.tabs.onActivated.addListener (obj) ->
  return if obj.tabId is chrome.tabs.TAB_ID_NONE
  tab = get(obj.tabId)
  if tab.showing
    enable(obj.tabId)
  else
    disable(obj.tabId)

chrome.commands.onCommand.addListener (command, tab) -> #async
  toggle(tab)

chrome.action.onClicked.addListener (tab) ->
  toggle(tab)

chrome.runtime.onMessage.addListener (msg, sender, sendResponse) ->
  return unless msg is 'clicked-close'
  get(sender.tab.id).showing = false
  chrome.action.setIcon path: 'icon-white.png'
  sendResponse {}
