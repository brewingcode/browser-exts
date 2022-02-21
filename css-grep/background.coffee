tabs = {}

chrome.tabs.onActivated.addListener (obj) ->
  id = obj.tabId
  if !tabs[id]
    tabs[id] = showing: false
  chrome.browserAction.setIcon path: if tabs[id].showing then 'icon-green.png' else 'icon-white.png'

chrome.tabs.onUpdated.addListener (tabId, changeInfo, tab) ->
  if tabs[tabId] and changeInfo and changeInfo.status is 'loading'
    tabs[tabId].showing = false
    chrome.browserAction.setIcon path: 'icon-white.png'

chrome.browserAction.onClicked.addListener (tab) ->
  return unless tabs[tab.id]
  if tabs[tab.id].showing
    chrome.browserAction.setIcon path: 'icon-white.png'
    chrome.tabs.executeScript tab.id, code: 'hide()'
    tabs[tab.id].showing = false
  else
    chrome.browserAction.setIcon path: 'icon-green.png'
    chrome.tabs.executeScript tab.id, file: 'grep.js'
    tabs[tab.id].showing = true

chrome.extension.onRequest.addListener (request, sender, sendResponse) ->
  if request is 'hiding'
    chrome.browserAction.setIcon path: 'icon-white.png'
  else
    chrome.browserAction.setIcon path: 'icon-green.png'
  sendResponse {}
