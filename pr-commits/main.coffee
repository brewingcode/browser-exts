code = '''
var tabs = document.querySelectorAll(".tabnav a");
tabs[1].click();
setTimeout(function() {
    var commits = document.querySelectorAll('a[aria-label="View commit details"]');
    commits.forEach(function(c) {
        window.open(c.href, '_blank');
    });
}, 1000 );
'''

chrome.browserAction.onClicked.addListener (tab) ->
  chrome.tabs.executeScript tab.id, code: code
