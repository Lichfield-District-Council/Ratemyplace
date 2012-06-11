var url = phantom.casperArgs.args[0]
var id = phantom.casperArgs.args[1]
var username = phantom.casperArgs.args[2]
var password = phantom.casperArgs.args[3]
var inspectionid = phantom.casperArgs.args[4]
var date = phantom.casperArgs.args[5]

if (phantom.casperArgs.args[5] == "accept") {
	var buttonid = "a#ctl00_ContentPlaceholder_buttonAcceptAppeal"
} else if (phantom.casperArgs.args[5] == "reject") {
	var buttonid = "a#ctl00_ContentPlaceholder_buttonRejectAppeal"
}

var casper = require('casper').create({
	pageSettings : {
		userAgent : 'Mozilla/5.0 (Macintosh; Intel Mac OS X 10_7_2) AppleWebKit/535.11 (KHTML, like Gecko) Chrome/17.0.963.79 Safari/535.11'
	}
});

casper.start('http://176.227.216.36/fhrsuat/default.aspx');

casper.then(function() {   	 
    this.fill('form#logOnForm', {
    	'uxAuthorityCode': id,
    	'uxUsername': username,
    	'uxPassword': password
    }, false);  
    this.click('input#uxSubmit');
});

casper.then(function() {
	this.open('http://176.227.216.36/FHRSUAT/readdata/establishment.aspx?estID=' + inspectionid);
});

casper.then(function() {
	this.fill('#aspnetForm', {
		'ctl00$ContentPlaceholder$textBoxDeterminationDateText': date		
	}, false);
	this.click(buttonid);
});

casper.then(function() {
	if (this.visible('div[aria-labelledby="ui-dialog-title-dialogAcceptContent"]')) {
		this.click('div[aria-labelledby="ui-dialog-title-dialogAcceptContent"] .ui-state-default');
	}
	if (this.visible('div[aria-labelledby="ui-dialog-title-dialogRejectContent"]')) {
		this.click('div[aria-labelledby="ui-dialog-title-dialogRejectContent"] .ui-state-default');
	}
});

casper.then(function() {
	this.capture("WTF.png")
});

casper.run();