var url = phantom.casperArgs.args[0]
var slug = phantom.casperArgs.args[1]
var id = phantom.casperArgs.args[2]
var username = phantom.casperArgs.args[3]
var password = phantom.casperArgs.args[4]

var casper = require('casper').create({
	pageSettings : {
		userAgent : 'Mozilla/5.0 (Macintosh; Intel Mac OS X 10_7_2) AppleWebKit/535.11 (KHTML, like Gecko) Chrome/17.0.963.79 Safari/535.11'
	}
});

casper.start(url);

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
	if (this.visible('div[aria-labelledby="ui-id-2"]')) {
		this.click('div[aria-labelledby="ui-id-2"] .ui-dialog-buttonset button:first-child');
	} 
});

casper.then(function() {
	if (this.visible('div[aria-labelledby="ui-id-1"]')) {
		this.click('div[aria-labelledby="ui-id-1"] .ui-dialog-buttonset button:first-child');
	} 
});
/*
casper.then(function() {
    if (this.fetchText('.statusMessageContainer').match(/Sorry, the file did not pass validation. Please review the validation errors in the report below/)) {
	    this.echo("Upload failed!", "ERROR");
	    errors = this.evaluate(function() {
		    var errorRows = __utils__.findAll({
		    	type: 'xpath',
		    	path: "//table[@id='uploadTable']/tr[position()>1]"
		    });
		    return Array.prototype.forEach.call(errorRows, function(e) {
		    	return e;
		    });
		});
		this.echo(JSON.stringify(errors));
    } else {
	    this.echo("Upload successful", "INFO");
    }
});
*/
casper.then(function() {
	this.capture('huh.png')
    if (this.fetchText('.statusMessageContainer').match(/Sorry, the file did not pass validation. Please review the validation errors in the report below/)) {
        this.echo("Upload failed!", "ERROR");
        errors = this.evaluate(function() {
            var errorRows = __utils__.getElementsByXPath("//table[@id='uploadTable']/tbody/tr[position()>1]");
            return Array.prototype.map.call(errorRows, function(e) {
                return e.innerText;
            });
        });
        this.echo(JSON.stringify(errors));
    } else {
        this.echo("Upload successful", "INFO");
    }
});

casper.then(function() { 
	this.click('#ctl00_PortalHeader_linkExit');
});

casper.run();