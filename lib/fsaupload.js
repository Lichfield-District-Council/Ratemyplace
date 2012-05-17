var slug = phantom.casperArgs.args[0]
var id = phantom.casperArgs.args[1]
var username = phantom.casperArgs.args[2]
var password = phantom.casperArgs.args[3]

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
	this.click('#ctl00_PortalHeader_linkUpload');
});

casper.then(function() {
	this.fill('form#aspnetForm', {
		'ctl00$ContentPlaceholder$File1': '/tmp/'+ slug +'.xml',
		'ctl00$ContentPlaceholder$checkBoxRelease': 'true'
	}, false);
	this.click('input#ctl00_ContentPlaceholder_uploadButton');
});

casper.then(function() {
	this.wait(5000, function() {
		if (this.visible('div[aria-labelledby="ui-dialog-title-dialogUploadContent"]')) {
			this.click('div[aria-labelledby="ui-dialog-title-dialogUploadContent"] .ui-state-default');
		} else {
			console.log('Error clicking the first confirmation box', 'error');
		}
	});
});

casper.then(function() {
	this.wait(5000, function() {
		if (this.visible('div[aria-labelledby="ui-dialog-title-dialogContent"]')) {
			this.click('div[aria-labelledby="ui-dialog-title-dialogContent"] .ui-state-default');
		} 
	});
});

casper.then(function() {
	this.wait(5000, function() {
	    this.evaluateOrDie(function() {
        	return /was successfully uploaded, validated and released/.test(document.body.innerText);
   		}, 'Upload failed!');		
	});
	this.capture(slug + '.png');
	this.click('#ctl00_PortalHeader_linkExit');
});

casper.run(function() {
    console.log('Upload successful').exit();
});