code = '''
n = document.getElementById("jira-issue-header-actions");
n = n.parentElement.parentElement;
n.remove();

n = document.getElementById("jira-issue-header");
n = n.nextSibling.nextSibling.nextSibling;
n.remove();
'''

chrome.browserAction.onClicked.addListener (tab) ->
  chrome.tabs.executeScript tab.id, code: code
