/* $Id: bouncehammer.js,v 1.2 2010/02/21 23:31:32 ak Exp $ */
function toggleIt(elements) {
	var e = $(elements);
	Element.toggle(e);
}

function disableIt(elements) {
	var e = $(elements);
	if( e.disabled == false ){ e.disabled = true; }
}

function enableIt(elements) {
	var e = $(elements);
	if( e.disabled == true ){ e.disabled = false; }
}

