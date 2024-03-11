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
var textureSlider = document.getElementById("texture");
var controlSlider= document.getElementById("control");

textureSlider.value = 0;
controlSlider.value = 0;

// Update the current slider value (each time you drag the slider handle)
textureSlider.oninput = function() {
    if (theChuck) {
        theChuck.setFloat("TEXTURE", this.value/100.0);
    }
    texture = this.value/100.0;
} 
controlSlider.oninput = function() {
    if (theChuck) {
        theChuck.setFloat("CONTROL", this.value/100.0);
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