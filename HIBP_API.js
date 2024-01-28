//Function to classify breaches into categories
const classifyBreaches = (breaches) => {
    const classification = { Critical: [], High: [], Medium: [], Low: [] };

    breaches.forEach(breach => {
        if (breach.dataClasses.includes('Social Security Numbers') || breach.dataClasses.includes('Credit Card Numbers')) {
            classification.Critical.push(breach);
        } else if (breach.dataClasses.includes('Passwords') || breach.dataClasses.includes('Physical Addresses')) {
            classification.High.push(breach);
        } else if (breach.dataClasses.includes('Phone Numbers') || breach.dataClasses.includes('Employment Information')) {
            classification.Medium.push(breach);
        } else {
            classification.Low.push(breach);
        }
    });

    return classification;
};

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

    const hibpApiKey = '1c79345799354f0c9dc49fe20df74c50';

    const response = await fetch(`https://haveibeenpwned.com/api/v3/breachedaccount/${encodeURIComponent(email)}`, {
        headers: {
            'hibp-api-key': hibpApiKey, 
            'User-Agent': `Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/${await getChromeVersion()} Safari/537.36`,
        },
    });

    if (response.ok) {
        const data = await response.json();
        const classification = classifyBreaches(data);
        return { pwned: true, breaches: data, classification };
    } else if (response.status === 404) {
        return { pwned: false, breaches: [], classification: {} };
    } else {
        throw new Error(`Error checking email: ${response.statusText}`);
    }
};

//Function to get Chrome version
const getChromeVersion = () => {
    const match = navigator.userAgent.match(/Chrom(e|ium)\/([0-9]+)\./);
    return match ? parseInt(match[2], 10).toString() : 'latest';
};

//Function to store user information as a token
const setToken = async (tokenData) => {
    return new Promise(resolve => {
        chrome.storage.local.set({ token: tokenData }, resolve);
    });
};

//Function to retrieve the stored token
const getToken = async () => {
    return new Promise(resolve => {
        chrome.storage.local.get(['token'], result => {
            resolve(result.token || '');
        });
    });
};

//Function to validate email format
const validateEmail = (email) => {
    const emailRegex = /^[^\s@]+@[^\s@]+\.[^\s@]+$/;
    return emailRegex.test(email);
};

//Function to validate date format (YYYY-MM-DD)
const validateDateOfBirth = (dob) => {
    const dateRegex = /^\d{4}-\d{2}-\d{2}$/;
    return dateRegex.test(dob);
};

//Function to validate phone number format
const validatePhoneNumber = (phone) => {
    const phoneRegex = /^\d{10}$/; // Assuming a simple 10-digit phone number
    return phoneRegex.test(phone);
};

//Function to prompt user for settings and store as a token
const promptForSettings = async () => {
    let email, name, dob, phone;

    do {
        email = prompt('Enter your email:');
    } while (!validateEmail(email));

    do {
        name = prompt('Enter your name:');
    } while (!name.trim());

    do {
        dob = prompt('Enter your date of birth (YYYY-MM-DD):');
    } while (!validateDateOfBirth(dob));

    do {
        phone = prompt('Enter your phone number:');
    } while (!validatePhoneNumber(phone));

    const tokenData = {
        email,
        name,
        dob,
        phone,
    };

    await setToken(tokenData);
};

//Example usage to prompt user for settings
promptForSettings();

//Example usage to trigger an update
updateExtensionData();

//Example usage to check email (unrelated to the update)
const emailToCheck = 'user@example.com';

checkEmail(emailToCheck)
    .then(result => {
        if (result.pwned) {
            console.log(`Email '${emailToCheck}' has been pwned with the following breaches:`);
            console.log('Critical:', result.classification.Critical);
            console.log('High:', result.classification.High);
            console.log('Medium:', result.classification.Medium);
            console.log('Low:', result.classification.Low);
        } else {
            console.log(`Email '${emailToCheck}' has not been pwned.`);
        }
    })
    .catch(error => {
        console.error('Error checking email:', error);
    });
