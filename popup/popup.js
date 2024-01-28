//elements
const locationIdElement = document.getElementById("locationId")
const startDateElement = document.getElementById("startDate")
const endDateElement = document.getElementById("endDate")

// button elements
const startButton = document.getElementById("startButton")
const stopButton = document.getElementById("stopButton")

startButton.onclick = () => {
   const prefs = {
        locationId: locationIdElement.value,
        startDate: startDateElement.value,
        endDate: endDateElement.value
   }
   chrome.runtime.sendMessage({ event: 'onStart', prefs})
 
}

// stopButton.onclick = function() {
//     chrome.runtime.sendMessage({ event: 'onStop' })
// }


chrome.storage.local.get(["locationId","startDate","endDate"], (result) => {

    const { locationId, startDate, endDate} = result;

    if (locationId){
        locationIdElement.value = locationId
    }

    if (startDate){
        startDateElement.value = startDate
    }

    if (endDate){
        endDateElement.value = endDate
    }

    
})