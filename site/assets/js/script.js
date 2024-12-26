window.onscroll = function () {
  fancyHeadFancyFoot();
};

function hideAuthorTitle() {
  var title = document.getElementById("author-title");
  if (title) {
    title.style.display = "none";
  }
}

function showAuthorTitle() {
  var title = document.getElementById("author-title");
  if (title) {
    title.style.display = "block";
  }
}

function activateElement(elt) {
  elt.classList.add("active");
}

function deactivateElement(elt) {
  elt.classList.remove("active");
}

function fancyHeadFancyFoot() {
  var scrollBarPosition = window.pageYOffset | document.body.scrollTop;

  if (scrollBarPosition < 10) {
    showAuthorTitle();
    deactivateElement(document.getElementById("header"));
  } else {
    hideAuthorTitle();
    activateElement(document.getElementById("header"));
  }
}
