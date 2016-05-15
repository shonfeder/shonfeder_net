
$(window).scroll(function() {
    var scrollTop = $(window).scrollTop();
    var scrollHeight = $(document).height();
	  var scrollPosition = $(window).height() + $(window).scrollTop();

    if (scrollTop > 0) {
        $("#header").addClass("active");
    }
    else {
        $("#header").removeClass("active");
    }

	  if ((scrollHeight - scrollPosition) / scrollHeight === 0) {
        $("#footer").removeClass("active");
	  }
    else {
        $("#footer").addClass("active");
    }
});
