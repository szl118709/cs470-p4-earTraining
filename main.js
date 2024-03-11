// Soundscape AI Main
// Main Button
const mainButton = document.getElementById('mainButton');

//var serverFilesToPreload = [];
const serverFilesToPreload = [
    { 
        serverFilename: "./felt-main.wav", virtualFilename: "felt-main.wav" 
    },
    { 
        serverFilename: "./felt-texture.wav", virtualFilename: "felt-texture.wav" 
    },
    { 
        serverFilename: "./felt.txt", virtualFilename: "felt.txt" 
    },
]
var preloadedFilesReady = preloadFilenames(serverFilesToPreload);

// Read in Chuck Code
code = fetch("mosaic-synth-mic.ck")
    .then(response => response.text())
    .then(text => { code = text; });

let state = -1;

// MAIN BUTTON
mainButton.addEventListener('click', async () =>
{
    if (state == -1)
    {
        // Load 
        await preloadedFilesReady;
        await startChuck();
        await code;
        // Mic
        navigator.mediaDevices.getUserMedia({ audio: true, video: false })
            .then((stream) =>
            {
                const source = audioContext.createMediaStreamSource(stream);
                source.connect(theChuck);
            });
        console.log("WebChuck is ready!");
        // connect

        // Run
        state = 1;
        showPlay();
    } else if (state == 0)
    {
        // Stop
        await theChuck.removeLastCode();
        state = 1;
        showPlay();
        stopCanvas();

    } else if (state == 1)
    {
        // Run
        await theChuck.runCode(code);
        state = 0;
        showStop();
        startCanvas();
    }
});

const buttonDesc = document.getElementById('buttonDesc');
function showPlay() 
{
    mainButton.innerHTML = `<i class="fas fa-play"></i>`;
    mainButton.style.backgroundColor = "#3c3"
    buttonDesc.innerHTML = "Play, headphones recommended";
}
function showStop() {
    mainButton.innerHTML = `<i class="fas fa-stop"></i>`;
    mainButton.style.backgroundColor = "#f33"
    mainButton.classList.remove("clickMe");
    buttonDesc.innerHTML = "";
}
