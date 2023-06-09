var configuration = {
	epics: [".js-epic-block.block.epic", ".form-group.row.issue-epic"],
	iterations: ["*[data-qa-selector=\"iteration_container\"]"],
	weights: [".block.weight", ".datepicker.form-control.qa-issuable-weight-input", "label:contains('Weight')"], //, "label[for=\"issue_label_ids\"]"
	timeTracking: [".block.time-tracking",".time-tracker.time-tracking-component-wrap"],
	dueDate: [".block.due_date", "input[name=\"issue\[due_date\]\"]", "label[for=\"issue_due_date\"]"],
	subscriptions: [".block.subscriptions"],
	confidentiality: [".block.confidentiality", "label[for=\"issue_confidential\"]", "input[name=\"issue\[confidential\]\"]"],
	lock: [".block.issuable-sidebar-item.lock"],
	dropScreenshots: ["li[data-testid=\"design-dropzone-wrapper\"]"],
	issueType: [".dropdown.js-issuable-type-filter-dropdown-wrap", "label[for=\"issue_type\"]"],
	todos: [".block.issuable-sidebar-header", ".shortcuts-todos"],
	entireRightSidebar: ["aside.js-right-sidebar"]
}

var alter = {
	entireRightSidebar: function() {
		$('div.merge-request-overview').css('grid-template-columns', 'auto');
	}
}

function hideElement(name){
	var dataObj = {};
	dataObj[name] = true;
	chrome.storage.local.get(dataObj, function(items) {
		if(items[name]){

			configuration[name].forEach(element => {
				$(element).hide(); 
			});
			if (alter[name]) {
				alter[name]();
			}
			console.log(" > Hide " + name + " = " + dataObj[name]);
		}else{
			console.log(" > No configuration found for " + name)
		}
	  });
}

chrome.extension.sendMessage({}, function(response) {
	var readyStateCheckInterval = setInterval(function() {
	if (document.readyState === "complete") {
		clearInterval(readyStateCheckInterval);

		console.log("Starting Gitlab - Simplifier for chrome");

		// Checking each element of the configuration and whats saved in the confid
		for (const [key, value] of Object.entries(configuration)) {
			hideElement(key);
		}

	}
	}, 10);
});
