const grid = document.getElementById('grid');
let texture = 0;

chuckPrint = function (text) {
    if (text.startsWith("window: "))
    {
        text = text.substring(8);
        generateParticle(text)
    }
}

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
    texture = this.value/100.0;
} 
slider2.oninput = function() {
    if (theChuck) {
        theChuck.setFloat("SLIDER2", this.value/100.0);
    }
} 
slider3.oninput = function() {
    if (theChuck) {
        theChuck.setFloat("SLIDER3", this.value/100.0);
    }
} 
slider4.oninput = function() {
    if (theChuck) {
        theChuck.setFloat("SLIDER4", this.value/100.0);
    }
} 

function generateParticle(text)
{
    const num = parseInt(text);
    // break num into i and j
    let i = Math.floor(num / gridSize);
    let j = num % gridSize;
    let r = 255 * (texture) ;
    let g = Math.random() * 150; 
    let b = 255 * ((1-texture));

    // Create new particle
    addParticle(i, j, r, g, b);
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
        }
        else {
            theChuck.setFloat("SWITCH1", 0);
        }
    }
} 
switch2.oninput = function() {
    if (theChuck) {
        if (this.checked) {
            theChuck.setFloat("SWITCH2", 1);
            theChuck.setFloat("SLIDER2", slider2.value/100.0);
        }
        else {
            theChuck.setFloat("SWITCH2", 0);
        }
    }
} 
switch3.oninput = function() {
    if (theChuck) {
        if (this.checked) {
            theChuck.setFloat("SWITCH3", 1);
            theChuck.setFloat("SLIDER3", slider3.value/100.0);
        }
        else {
            theChuck.setFloat("SWITCH3", 0);
        }
    }
} 
switch4.oninput = function() {
    if (theChuck) {
        if (this.checked) {
            theChuck.setFloat("SWITCH4", 1);
            theChuck.setFloat("SLIDER4", slider4.value/100.0);
        }
        else {
            theChuck.setFloat("SWITCH4", 0);
        }
    }
} 