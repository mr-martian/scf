var index = 0;
carousel();

// changes image every 4 seconds
function carousel() {
    var i;
    var x = document.getElementsByClassName("Slideshow");
    for (i = 0; i < x.length; i++) {
       x[i].style.display = "none";
    }
    index++;
    if (index > x.length) {index = 1} // go back to the first image
    x[index-1].style.display = "block";
    setTimeout(carousel, 4000);
}
