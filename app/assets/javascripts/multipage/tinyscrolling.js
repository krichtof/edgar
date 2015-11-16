/* Tiny Scrolling - a smooth navigation between internal links and their destinations
by Marco Rosella - http://www.centralscrutinizer.it/en/design/js-php/tiny-scrolling
based on the works by Travis Beckham and Brian McAllister.
                v0.3 - March 27, 2006
*/

window.onload = function() {
	tinyScrolling.init();
	}

var tinyScrolling = {
	speed : 50,      //set here the scroll speed: when this value increase, the speed decrease. 
	maxStep: 150,	 //set here the "uniform motion" step for long distances
	brakeK: 3,		 //set here the coefficient of slowing down
	hash:null,		
	currentBlock:null,
	requestedY:0,
	init: function() {
			var lnks = document.getElementsByTagName('a');   
			for(var i = 0, lnk; lnk = lnks[i]; i++) {   
				if ((lnk.href && lnk.href.indexOf('#') != -1) &&  ( (lnk.pathname == location.pathname) ||
				('/'+lnk.pathname == location.pathname) ) && (lnk.search == location.search)) {  
				lnk.onclick = tinyScrolling.initScroll;   		
				}   
			}
	},
	getElementYpos: function(el){
			var y = 0;
			while(el.offsetParent){  
				y += el.offsetTop    
				el = el.offsetParent;
			}	return y;
	},		
	getScrollTop: function(){
			if(document.all) return (document.documentElement.scrollTop) ? document.documentElement.scrollTop : document.body.scrollTop;
			else return window.pageYOffset;   
	},	
	getWindowHeight: function(){
			if (window.innerHeight)	return window.innerHeight;
			if(document.documentElement && document.documentElement.clientHeight) return document.documentElement.clientHeight;
	},
	getDocumentHeight: function(){
			if (document.height) return document.height;
			if(document.body.offsetHeight) return document.body.offsetHeight;
	},
	initScroll: function(e){
			var targ;  
			if (!e) var e = window.event;
			if (e.target) targ = e.target;
			else if (e.srcElement) targ = e.srcElement;   
			tinyScrolling.hash = targ.href.substr(targ.href.indexOf('#')+1,targ.href.length); 
			tinyScrolling.currentBlock = document.getElementById(tinyScrolling.hash);   
			if(!tinyScrolling.currentBlock) return;
			tinyScrolling.requestedY = tinyScrolling.getElementYpos(tinyScrolling.currentBlock); 
			tinyScrolling.scroll();  
			return false;
	},
	scroll: function(){
			var top  = tinyScrolling.getScrollTop();
			if(tinyScrolling.requestedY > top) {  
				var endDistance = Math.round((tinyScrolling.getDocumentHeight() - (top + tinyScrolling.getWindowHeight())) / tinyScrolling.brakeK);
				endDistance = Math.min(Math.round((tinyScrolling.requestedY-top)/ tinyScrolling.brakeK), endDistance);
				var offset = Math.max(2, Math.min(endDistance, tinyScrolling.maxStep));
			} else { var offset = - Math.min(Math.abs(Math.round((tinyScrolling.requestedY-top)/ tinyScrolling.brakeK)), tinyScrolling.maxStep);
			} window.scrollTo(0, top + offset);  
			if(Math.abs(top-tinyScrolling.requestedY) <= 1 || tinyScrolling.getScrollTop() == top) {
				window.scrollTo(0, tinyScrolling.requestedY);
				if(!document.all || window.opera) location.hash = tinyScrolling.hash;
				tinyScrolling.hash = null;
			} else 	setTimeout(tinyScrolling.scroll,tinyScrolling.speed);
	}		
}