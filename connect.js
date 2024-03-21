// Sliders
var slider1 = document.getElementById("slider1");
var slider2 = document.getElementById("slider2");
var slider3 = document.getElementById("slider3");
var slider4 = document.getElementById("slider4");

slider1.value = 0;
slider2.value = 0;
slider3.value = 0;
slider4.value = 0;

// Update the current slider value (each time you drag the slider handle)
slider1.oninput = function() {
    if (theChuck) {
        theChuck.setFloat("SLIDER1", this.value/100.0);
    }
    update_slider1(this.value/100.0, switch1.checked);
} 
slider2.oninput = function() {
    if (theChuck) {
        theChuck.setFloat("SLIDER2", this.value/100.0);
    }
    update_slider2(this.value/100.0, switch2.checked);
} 
slider3.oninput = function() {
    if (theChuck) {
        theChuck.setFloat("SLIDER3", this.value/100.0);
    }
    update_slider3(this.value/100.0, switch3.checked);
} 
slider4.oninput = function() {
    if (theChuck) {
        theChuck.setFloat("SLIDER4", this.value/100.0);
    }
    update_slider4(this.value/100.0, switch4.checked);
} 

const switch1 = document.getElementById("switch1");
const switch2 = document.getElementById("switch2");
const switch3 = document.getElementById("switch3");
const switch4 = document.getElementById("switch4");
switch1.oninput = function() {
    if (theChuck) {
        if (this.checked) {
            theChuck.setFloat("SWITCH1", 1);
            theChuck.setFloat("SLIDER1", slider1.value/100.0);
            update_slider1(slider1.value/100.0, true);
        }
        else {
            theChuck.setFloat("SWITCH1", 0);
            update_slider1(1, true);
        }
    }
} 
switch2.oninput = function() {
    if (theChuck) {
        if (this.checked) {
            theChuck.setFloat("SWITCH2", 1);
            theChuck.setFloat("SLIDER2", slider2.value/100.0);
            update_slider2(slider2.value/100.0, true);
        }
        else {
            theChuck.setFloat("SWITCH2", 0);
            update_slider2(slider2.value/100.0, false);
        }
    }
} 
switch3.oninput = function() {
    if (theChuck) {
        if (this.checked) {
            theChuck.setFloat("SWITCH3", 1);
            theChuck.setFloat("SLIDER3", slider3.value/100.0);
            update_slider3(slider3.value/100.0, true);
        }
        else {
            theChuck.setFloat("SWITCH3", 0);
            update_slider3(0, true);
        }
    }
} 
switch4.oninput = function() {
    if (theChuck) {
        if (this.checked) {
            theChuck.setFloat("SWITCH4", 1);
            theChuck.setFloat("SLIDER4", slider4.value/100.0);
            update_slider4(slider4.value/100.0, true);
        }
        else {
            theChuck.setFloat("SWITCH4", 0);
            update_slider4(0, false);
        }
    }
} 