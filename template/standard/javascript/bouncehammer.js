/* $Id: bouncehammer.js,v 1.2.2.1 2011/01/14 05:16:05 ak Exp $ */
function toggleIt(elements) {
	var e = $(elements);
	Element.toggle(e);
}

function toggleSign(elements) {
	var e = $(elements);
	e.innerHTML == '+' ? e.innerHTML = '-' : e.innerHTML = '+';
}

function disableIt(elements) {
	var e = $(elements);
	if( e.disabled == false ){ e.disabled = true; }
}

function enableIt(elements) {
	var e = $(elements);
	if( e.disabled == true ){ e.disabled = false; }
}

