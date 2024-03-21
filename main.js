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
        serverFilename: "./earTrainer2.ck", virtualFilename: "earTrainer2.ck" 
    },
    { 
        serverFilename: "./93.wav", virtualFilename: "93.wav" 
    },

]

async function startChuck()
{
    buttonDesc.innerHTML = "Loading...";
    window.theChuck ??= await Chuck.init(serverFilesToPreload);
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
var SLIDER1 = 0;
var SLIDER2 = 0;
var SLIDER3 = 0;
var SLIDER4 = 0;
var SWITCH1 = 0;
var SWITCH2 = 0;
var SWITCH3 = 0;
var SWITCH4 = 0;
var DIFF = 0;
var PLAYRADIO = 0;

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
        await theChuck.runFile("bandweeow.ck");
        console.log("WebChuck is ready!");

        // Run
        state = 1;
        showPlay();
    } 
    else if (state == 0)
    {
        // Stop
        SLIDER1 = await theChuck.getFloat("SLIDER1");
        SLIDER2 = await theChuck.getFloat("SLIDER2");
        SLIDER3 = await theChuck.getFloat("SLIDER3");
        SLIDER4 = await theChuck.getFloat("SLIDER4");
        SWITCH1 = await theChuck.getFloat("SWITCH1");
        SWITCH2 = await theChuck.getFloat("SWITCH2");
        SWITCH3 = await theChuck.getFloat("SWITCH3");
        SWITCH4 = await theChuck.getFloat("SWITCH4");
        PLAYRADIO = await theChuck.getInt("PLAYRADIO");

        
        await theChuck.clearChuckInstance();

        state = 1;
        showPlay();
        stopCanvas();

        clearInterval(timerId);
    } 
    else if (state == 1)
    {
        // Run
        await theChuck.runFile("earTrainer2.ck");
        theChuck.setFloat("SLIDER1", SLIDER1);
        theChuck.setFloat("SLIDER2", SLIDER2);
        theChuck.setFloat("SLIDER3", SLIDER3);
        theChuck.setFloat("SLIDER4", SLIDER4);

        theChuck.setFloat("SWITCH1", SWITCH1);
        theChuck.setFloat("SWITCH2", SWITCH2);
        theChuck.setFloat("SWITCH3", SWITCH3);
        theChuck.setFloat("SWITCH4", SWITCH4);

        theChuck.setInt("PLAYRADIO", PLAYRADIO);
        
        state = 0;
        showStop();
        startCanvas();

        var timerId = setInterval(async ()=> {
            DIFF = await theChuck.getFloat("DIFF");
            if (PLAYRADIO == 1) {
                document.getElementById("diff").innerHTML = ""; 
            }
            else {
                document.getElementById("diff").innerHTML = DIFF; 
            }

            // print answer
            var printed = await theChuck.getFloat("PRINTED");
            if (!printed) {
                var temp = await theChuck.getFloat("REF1");
                console.log("REF1 = ", temp);
                temp = await theChuck.getFloat("REF2");
                console.log("REF2 = ", temp);
                temp = await theChuck.getFloat("REF3");
                console.log("REF3 = ", temp);
                temp = await theChuck.getFloat("REF4");
                console.log("REF4 = ", temp);
            }
            theChuck.setFloat("PRINTED", 1);
        }, 100);
    }
});

const buttonDesc = document.getElementById('buttonDesc');
function showPlay() 
{
    mainButton.innerHTML = `<i class="fas fa-play"></i>`;
    mainButton.style.backgroundColor = "#3c3";
    buttonDesc.innerHTML = "Play, headphones recommended";
}
function showStop() {
    mainButton.innerHTML = `<i class="fas fa-stop"></i>`;
    mainButton.style.backgroundColor = "#f33";
    mainButton.classList.remove("clickMe");
    buttonDesc.innerHTML = "";
}

const radioForm = document.getElementById("playRadio");
const radioHandler = (event) => {
    PLAYRADIO = Number(radioForm["playing"].value);
    window.theChuck.setInt("PLAYRADIO", PLAYRADIO);
    // console.log("Radio clicked value", radioForm["playing"].value);
};
radioForm.addEventListener("change", radioHandler);
