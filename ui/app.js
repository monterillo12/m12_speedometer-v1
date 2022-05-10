/* MAIN FEATURES */
const speedometer = document.querySelector('.container');
const velocity = document.querySelector('#vel-value');
const gear = document.querySelector('#gear-value');
const fuel = document.querySelector('#fuel-status');

/* INDICATORS */
const leftIndicator = document.querySelector('#left-indicator');
const rightIndicator = document.querySelector('#right-indicator');
const belt = document.querySelector('#belt-status');
const light = document.querySelector('#light-status');
const engine = document.querySelector('#engine-indicator');

let beltsound = new Audio('./assets/abrochar.mp3');
let unbeltsound = new Audio('./assets/desabrochar.mp3');

let blinkBelt    = false
let indicators   = 0
let ftime        = true

window.addEventListener('message', function (event) {

    switch (event.data.action) {
        
        case 'show':
            speedometer.style.opacity = '1';
            break;
        case 'hide':
            ftime = false
            blinkFuel = false;
            speedometer.style.opacity = '0';
            break;
        case 'tick':

            const data = event.data;

            // Update speed value
            velocity.innerHTML = data.speed;

            // Update gear value
            if (data.gear == 0) data.gear = 'R';
            if (data.speed == 0) data.gear = 'N';
            gear.innerHTML = data.gear;

            // Update fuel value
            if (data.fuel < 30) {
                fuel.classList.add('blink');
            } else {
                fuel.classList.remove('blink');
            }

            // Update health value
            if (data.health > 60) {
                engine.style.color = 'var(--unmarked-color)';
            } else if (data.health > 35) {
                engine.style.color = '#FFFF00';
            } else {
                engine.style.color = '#FF0000';
            }

            // Update belt value
            if (!data.belt && !blinkBelt) {
                belt.classList.add('blink');
                if (!ftime){unbeltsound.play();}
                ftime = false;
                blinkBelt = true
            } else if (data.belt && blinkBelt) {
                belt.classList.remove('blink');
                beltsound.play();
                blinkBelt = false
            }

            // Update indicators value
            if (indicators != data.indicators) {
                indicators = data.indicators;
                if (indicators == 0) {
                    leftIndicator.classList.remove('blink');
                    rightIndicator.classList.remove('blink');
                }
                else if (indicators == 1) {
                    leftIndicator.classList.add('blink');
                    rightIndicator.classList.remove('blink');
                }
                else if (indicators == 2) {
                    leftIndicator.classList.remove('blink');
                    rightIndicator.classList.add('blink');
                }
                else if (indicators == 3) {
                    leftIndicator.classList.remove('blink');
                    rightIndicator.classList.remove('blink');
                    setTimeout(() => {
                        leftIndicator.classList.add('blink');
                        rightIndicator.classList.add('blink');
                    }, 100);
                }
            }

            // Update light value
            if (data.lightson && !data.highbeams) {light.classList.add('marked-icon');}
            else if (data.lightson && data.highbeams) {light.classList.add('marked-icon-bright');}
            else {
                light.classList.remove('marked-icon');
                light.classList.remove('marked-icon-bright');
            }

            break;
    
        default:
            console.error('Something went wrong, contact to monterillo12#7006');
            break;

    }

});