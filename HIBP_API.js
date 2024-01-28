const sha256 = async function (input) {
    const encoder = new TextEncoder();
    const data = encoder.encode(input);
    const hashBuffer = await crypto.subtle.digest('SHA-256', data);
    const hashArray = Array.from(new Uint8Array(hashBuffer));
    const hashHex = hashArray.map(byte => byte.toString(16).padStart(2, '0')).join('');
    return hashHex.toUpperCase();
};

const checkEmail = async function (email) {
    const hashedEmail = await sha256(email.toLowerCase());

    const response = await fetch(`https://haveibeenpwned.com/api/v3/breachedaccount/${encodeURIComponent(email)}`, {
        headers: {
            'hibp-api-key': '1c79345799354f0c9dc49fe20df74c50', 
            'User-Agent': `Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/${await getChromeVersion()} Safari/537.36`,
        },
    });

    if (response.ok) {
        const data = await response.json();
        return { pwned: true, breaches: data };
    } else if (response.status === 404) {
        return { pwned: false, breaches: [] };
    } else {
        throw new Error(`Error checking email: ${response.statusText}`);
    }
};

//Function to get Chrome version
const getChromeVersion = () => {
    const match = navigator.userAgent.match(/Chrom(e|ium)\/([0-9]+)\./);
    return match ? parseInt(match[2], 10).toString() : 'latest';
};

//Function to trigger an update
const updateExtensionData = async () => {

    //Get the last update time from local storage
    chrome.storage.local.get(['lastUpdateTime'], async function(result) {
        const lastUpdateTime = result.lastUpdateTime;
        
        //Check if enough time has passed since the last update (e.g., 24 hours)
        const hoursBetweenUpdates = 24;
        const now = new Date().getTime();
        const timeSinceLastUpdate = now - new Date(lastUpdateTime).getTime();

        if (isNaN(timeSinceLastUpdate) || timeSinceLastUpdate >= hoursBetweenUpdates * 60 * 60 * 1000) {
            //Perform actions to update extension data, e.g., query HIBP for the latest breaches
            console.log('Updating extension data...');

            //Store the current time as the last update time
            chrome.storage.local.set({ lastUpdateTime: new Date().toISOString() });

            //Example: query HIBP for a specific email after updating
            const emailToCheck = 'user@example.com';
            const result = await checkEmail(emailToCheck);

            console.log(`Result after update for email '${emailToCheck}':`, result);
        } else {
            console.log('Not enough time has passed since the last update.');
        }
    });
};

//Example usage to trigger an update
updateExtensionData();

//Example usage to check email (unrelated to the update)
const emailToCheck = 'user@example.com';

checkEmail(emailToCheck)
    .then(result => {
        if (result.pwned) {
            console.log(`Email '${emailToCheck}' has been pwned in the following breaches:`, result.breaches);
        } else {
            console.log(`Email '${emailToCheck}' has not been pwned.`);
        }
    })
    .catch(error => {
        console.error('Error checking email:', error);
    });
