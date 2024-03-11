const canvas = document.getElementById('canvas1');
const ctx = canvas.getContext('2d');
ctx.canvas.width = window.innerWidth;
ctx.canvas.height = window.innerHeight;

let particleArray = [];

// Create constructor function
function Particle(x, y, directionX, directionY, size, color, currTime)
{
    this.x = x;
    this.y = y;
    this.directionX = directionX;
    this.directionY = directionY;
    this.size = size;
    this.currSize = 0;
    this.color = color;
    this.currTime = currTime;
}

// Draw particle
Particle.prototype.draw = function ()
{
    ctx.beginPath();
    ctx.arc(this.x, this.y, this.currSize, 0, Math.PI * 2, false);
    ctx.fillStyle = this.color;
    ctx.fill();
}

// Move particles
Particle.prototype.update = function (number)
{
    if (this.x + this.currSize > canvas.width || this.x - this.currSize < 0)
    {
        this.directionX = -this.directionX;
    }
    if (this.y + this.currSize > canvas.height || this.y - this.currSize < 0)
    {
        this.directionY = -this.directionY;
    }
    // Math sin based on time
    this.x += this.directionX;
    this.y += this.directionY;

    if (this.currSize < this.size)
    {
        this.currSize += 0.05;
    }

    // If this is an added particle
    if (number > 99) 
    {
        this.currSize = Math.sin((Date.now() - this.currTime) / 1500) * 30 + 30;
        // destroy particle if size is too small
        if (this.currSize < 0.5)
        {
            particleArray.splice(number, 1);
        }

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
        let color = 'rgba(' + Math.random() * 255 + ',255,' + Math.random() * 400 + ',' + Math.random() + ')';
        let currTime = Date.now();

        particleArray.push(new Particle(x, y, directionX, directionY, size, color, currTime));
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

const gridSize = 14;
// New custom particle
function addParticle(xPos, yPos, r, g, b)
{
    let size = Math.random() * 20;
    let x = (xPos / gridSize * (innerWidth - size * 2)) + size;
    let y = (yPos / gridSize * (innerHeight - size * 2)) + size;
    // Scale x and y to 90% of the grid size
    x = (x * .9) + (innerWidth * .05)
    y = (y * .9) + (innerHeight * .05)
    let directionX = (Math.random() * .4) - .2;
    let directionY = (Math.random() * .4) - .2;
    let color = 'rgba(' + r + ',' + g + ',' + b + ',' + Math.max(Math.random(), .6) + ')';
    let currTime = Date.now();

    particleArray.push(new Particle(x, y, directionX, directionY, size, color, currTime));
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

// MAIN
initCanvas();