//  COMMENT 

jQuery('.login-toggle').click(function(){
  console.log("ter")
  if (!jQuery('#login-tab').hasClass("invisible")) {
    jQuery('#login-tab').addClass("invisible");
    jQuery('#nav').addClass("hidden");
    //jQuery('#socialfixed').addClass("invisible");
    //jQuery('#langswitch').addClass("invisible");
    jQuery('#login-form').removeClass("invisible");
    jQuery("input:text:visible:first").focus();
  } else {
    jQuery('#login-tab').removeClass("invisible");
    jQuery('#nav').removeClass("hidden");
    //jQuery('#socialfixed').removeClass("invisible");
    //jQuery('#langswitch').removeClass("invisible");
    jQuery('#login-form').addClass("invisible");
  }
  
});


jQuery("[rel='tooltip']").tooltip();



//jQuery('.login-btn').removeClass("btn");

jQuery('.nav-collapse .nav > li > a').click(function(){
			
			jQuery('.collapse.in').removeClass('in').css('height', '0');

});
/*
jQuery('#main-nav a').click(function(){
  
  jQuery(this).siblings().removeClass('active');
  jQuery(this).addClass('active');

});
*/
//$(this).removeClass('active').addClass('active').siblings().removeClass('active all');

//  COMMENT 
//  COMMENT 
jQuery("a[data-gal^='prettyPhoto']").prettyPhoto();
//  COMMENT 

//  COMMENT 
		jQuery.noConflict()(function($){
			var $container = $('#container-folio');
					
			if($container.length) {
				$container.waitForImages(function() {
					
					// initialize isotope
					$container.isotope({
					  itemSelector : '.box',
					  layoutMode : 'fitRows'
					});
					
					// filter items when filter link is clicked
					$('#filters a').click(function(){
					  var selector = $(this).attr('data-filter');
					  $container.isotope({ filter: selector });
					  $(this).removeClass('active').addClass('active').siblings().removeClass('active all');
					  
					  return false;
					});
					
				},null,true);
			}});

//  COMMENT 


jQuery(document).ready(function(){
	jQuery('#nav').localScroll(3000);
	jQuery('#main-nav select').localScroll(400);
	
	//.parallax(xPosition, speedFactor, outerHeight) options:
	//xPosition - Horizontal position of the element
	//inertia - speed to move relative to vertical scroll. Example: 0.1 is one tenth the speed of scrolling, 2 is twice the speed of scrolling
	//outerHeight (true/false) - Whether or not jQuery should use it's outerHeight option to determine when a section is in the viewport
	jQuery('#features-section').parallax("50%", 0.1);
	jQuery('#team-section').parallax("50%", 0.1);
	jQuery('#portfolio-section').parallax("50%", 0.1);
	jQuery('#price-section').parallax("50%", 0.3);
	jQuery('#contact-section ').parallax("50%", 0.1);
	
})
//  COMMENT 




//  COMMENT 
		var topclick = jQuery('.top-link-click');
		var topscroll = jQuery('.top-link');
		var bottomclick = jQuery('.bottom-link-click');
		var bottomscroll = jQuery('.bottom-link');
		jQuery(window).scroll(function () {
				if (jQuery(this).scrollTop() > 30) {
					topclick.removeClass("right");	
					topscroll.removeClass("right");
					bottomclick.removeClass("right");	
					bottomscroll.removeClass("right");	
				} else {
					
					topclick.addClass("right");	
					topscroll.addClass("right");
					bottomclick.addClass("right");	
					bottomscroll.addClass("right");	
				}
			});
//  COMMENT 

					

//  COMMENT 
		var nav = jQuery('.navbar-inner');
		jQuery(window).scroll(function () {
				if (jQuery(this).scrollTop() > 30) {
					nav.addClass("scroll");	
				} else {
					nav.removeClass("scroll");	
				}
			});
//  COMMENT 
		
		
		

		

		

	//  COMMENT 
		jQuery(".top-link-click").click(function(){
			jQuery("body").scrollTo(jQuery(".top-corner"), 400);

		});
		jQuery(".bottom-link-click").click(function(){
			jQuery("body").scrollTo(jQuery(".bottom-corner"), 400);

		});
		jQuery(".top-link").hover(function(){
			jQuery("body").scrollTo(jQuery(".top-corner"), 3000);
		},function(){
			 jQuery("body").stop();
			// stop on unhover
		});
		jQuery(".bottom-link").hover(function(){
			jQuery("body").scrollTo(jQuery(".bottom-corner"), 6000);
		},function(){
			jQuery("body").stop();
			// stop on unhover
		});

	//  COMMENT 
	
	//  COMMENT 
jQuery('#show1').bind('inview', function (event, visible) {
        if (visible == true) {
            jQuery(this).addClass("animated fadeInRightBig");

			
        }else{
            jQuery(this).removeClass("animated fadeInRightBig");

			//jQuery('.effect-box').unbind('inview');
        }
    });

//  COMMENT 	

//  COMMENT 
jQuery('#show2').bind('inview', function (event, visible) {
        if (visible == true) {
            jQuery(this).addClass("animated fadeInLeftBig");

			
        }else{
            jQuery(this).removeClass("animated fadeInLeftBig");

			//jQuery('.effect-box').unbind('inview');
        }
    });

//  COMMENT 

//  COMMENT 
jQuery('#show3').bind('inview', function (event, visible) {
        if (visible == true) {
            jQuery('#show3 .feature-box').addClass("animated bounceIn");

			
        }else{
            jQuery('#show3 .feature-box').removeClass("animated bounceIn");

			//jQuery('.effect-box').unbind('inview');
        }
    });

//  COMMENT 

//  COMMENT 
jQuery('#show4').bind('inview', function (event, visible) {
        if (visible == true) {
            jQuery('#show4 .thumbnail').addClass("animated bounceIn");

			
        }else{
            jQuery('#show4 .thumbnail').removeClass("animated bounceIn");

			//jQuery('.effect-box').unbind('inview');
        }
    });

//  COMMENT 



//  COMMENT 
jQuery('#showprice').bind('inview', function (event, visible) {
        if (visible == true) {
            jQuery('.price-feature-box').addClass("animated bounceIn");

			
        }else{
            jQuery('.price-feature-box').removeClass("animated bounceIn");

			//jQuery('.effect-box').unbind('inview');
        }
    });

//  COMMENT 





//  COMMENT 
jQuery('#showbar').bind('inview', function (event, visible) {
        if (visible == true) {
            jQuery('.bar').removeClass("notactive");

			
        }else{
             jQuery('.bar').addClass("notactive");

			//jQuery('.effect-box').unbind('inview');
        }
    });

//  COMMENT 
