// Saves options to chrome.storage
function save_options() {
    var gitlabOptions = document.getElementsByClassName('gitlab_option');
    var testDivs = Array.prototype.filter.call(gitlabOptions, function(gitLabOption){
        var dataObj = {};
        dataObj[gitLabOption.id] = gitLabOption.checked;
        chrome.storage.local.set(dataObj, function() {
            // Update status to let user know options were saved.
            var status = document.getElementById('status');
            status.textContent = 'Options saved.';
            setTimeout(function() {
              status.textContent = '';
            }, 750);
          });
    });
  }
  
  // Restores select box and checkbox state using the preferences
  // stored in chrome.storage.
  function restore_options() {

    var gitlabOptions = document.getElementsByClassName('gitlab_option');
    var testDivs = Array.prototype.filter.call(gitlabOptions, function(gitLabOption){
        var dataObj = {};
        dataObj[gitLabOption.id] = true;
        chrome.storage.local.get(dataObj, function(items) {
            document.getElementById(gitLabOption.id).checked = items[gitLabOption.id];
        });
    });

    // Use default value color = 'red' and likesColor = true.
    /*chrome.storage.local.get({
      likesColor: true
    }, function(items) {
      document.getElementById('like').checked = items.likesColor;
    });*/
  }
  document.addEventListener('DOMContentLoaded', restore_options);
  document.getElementById('save').addEventListener('click',
      save_options);
