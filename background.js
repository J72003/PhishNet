chrome.runtime.onMessage.addListener(data => {
    switch(data.event){
        case 'onStop':
            handleOnStart();
            break;
        case 'onStart':
            handleOnStart(prefs);
            break;
        default:
            break;
    }
})


const handleOnStart = (prefs) => {
    console.log("On start in background")
    console.log("prefs received",prefs)
    chrome.storage.local.set(prefs)

}