const canvas = document.getElementById('canvas1');
const ctx = canvas.getContext('2d');
ctx.canvas.width = window.innerWidth;
ctx.canvas.height = window.innerHeight;

let particleArray = [];
let size_multiplier = 0.5;
let opacity_multiplier = 1;

// Create constructor function
function Particle(x, y, directionX, directionY, size, r, g, b, a, currTime)
{
    this.x = x;
    this.y = y;
    this.directionX = directionX;
    this.directionY = directionY;
    this.size = size;
    this.currSize = 0;
    this.r = r;
    this.g = g;
    this.b = b;
    this.a = a;
    this.currTime = currTime;
}

// Draw particle
Particle.prototype.draw = function ()
{
    ctx.beginPath();
    ctx.arc(this.x, this.y, this.currSize, 0, Math.PI * 2, false);
    ctx.fillStyle = 'rgba(' + this.r + ',' + this.g + ',' + this.b + ',' + this.a * opacity_multiplier + ')';;
    ctx.fill();
}

// Move particles
Particle.prototype.update = function (number)
{
    if (this.x + this.currSize > canvas.width * (0.5 + size_multiplier) || 
        this.x - this.currSize < canvas.width * (0.5 - size_multiplier))
    {
        this.directionX = -this.directionX;
    }
    if (this.y + this.currSize > canvas.height * (0.5 + size_multiplier) || 
        this.y - this.currSize < canvas.height * (0.5 - size_multiplier))
    {
        this.directionY = -this.directionY;
    }
    this.x += this.directionX;
    this.y += this.directionY;

    if (this.currSize < this.size)
    {
        this.currSize += 0.05;
    }

    this.draw();
}

// Create particle array
function init()
{
    particleArray = [];
    for (let i = 0; i < 100; i++)
    {
        let size = Math.random() * 20;
        let x = Math.random() * (innerWidth - size * 2) + size;
        let y = Math.random() * (innerHeight - size * 2) + size;
        let directionX = (Math.random() * .4) - .2;
        let directionY = (Math.random() * .4) - .2;
        let r = 0;
        let g = Math.random() * 400;
        let b = 255;
        let a = Math.random();
        let currTime = Date.now();

        particleArray.push(new Particle(x, y, directionX, directionY, size, r, g, b, a, currTime));
    }
}

// Animation loop
function animate()
{
    requestAnimationFrame(animate);
    ctx.clearRect(0, 0, innerWidth, innerHeight);

    for (let i = 0; i < particleArray.length; i++)
    {
        particleArray[i].update(i);
    }
}


function startCanvas()
{
    // add show class
    canvas.classList.add('show');
    // start animation
    initCanvas(); 
}

function stopCanvas()
{
    // destroy all particles
    particleArray = [];
}

function initCanvas()
{
    init();
    animate();
    // on resize, recompute
    window.addEventListener('resize', function ()
    {
        canvas.width = innerWidth;
        canvas.height = innerHeight;
        init();
    });
}

function update_slider1(val, checked) {
    if (checked) {
        size_multiplier = val / 2.0;
    }
}

function update_slider2(val) {

}

function update_slider3(val, checked) {
    if (checked) {
        val = 1 - val;
        opacity_multiplier = Math.max(val, 0.2);
    }
}

// MAIN
initCanvas();