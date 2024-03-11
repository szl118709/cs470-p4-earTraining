import { Chuck } from 'https://cdn.jsdelivr.net/npm/webchuck/+esm';
// Soundscape AI Main
// Main Button
const mainButton = document.getElementById('mainButton');

//var serverFilesToPreload = [];
const serverFilesToPreload = [
    { 
        serverFilename: "./util-intqueue.ck", virtualFilename: "util-intqueue.ck"
    },
    { 
        serverFilename: "./util-voicebankvoice.ck", virtualFilename: "util-voicebankvoice.ck" 
    },
    { 
        serverFilename: "./util-voicebank.ck", virtualFilename: "util-voicebank.ck" 
    },
    { 
        serverFilename: "./bandweeow.ck", virtualFilename: "bandweeow.ck" 
    },
    { 
        serverFilename: "./earTrainer.ck", virtualFilename: "earTrainer.ck" 
    },

]

async function startChuck()
{
    buttonDesc.innerHTML = "Loading...";
    window.theChuck ??= await Chuck.init(serverFilesToPreload);
    // Mic
    navigator.mediaDevices.getUserMedia({ audio: true, video: false })
        .then((stream) =>
        {
            const source = theChuck.context.createMediaStreamSource(stream);
            source.connect(theChuck);
        });
    // Override print
    theChuck.chuckPrint = function (text) {
        if (text.startsWith("window: "))
        {
            text = text.substring(8);
            generateParticle(text)
        }
    }
}

let state = -1;

// MAIN BUTTON
mainButton.addEventListener('click', async () =>
{
    if (state == -1)
    {
        // Load 
        await startChuck();
        await theChuck.runFile("util-intqueue.ck");
        await theChuck.runFile("util-voicebankvoice.ck" );
        await theChuck.runFile("util-voicebank.ck" );
        await theChuck.runFile("bandweeow.ck" );
        console.log("WebChuck is ready!");

        // Run
        state = 1;
        showPlay();
    } else if (state == 0)
    {
        // Stop
        await theChuck.clearChuckInstance();
        state = 1;
        showPlay();
        stopCanvas();

    } else if (state == 1)
    {
        // Run
        await theChuck.runFile("earTrainer.ck");

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
