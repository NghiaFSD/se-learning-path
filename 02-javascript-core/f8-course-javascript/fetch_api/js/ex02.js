const serverApi = `http://localhost:3000`;

const postUser = async (data) => {
    const dataUrlEncoded = new URLSearchParams(data).toString();
    //=> Chuyển từ object => urlencoded
    //key1=value1&key2=value2&...

    const response = await fetch(`${serverApi}/users`, {
        method: 'POST',
        headers: {
            // "Content-Type": "application/json"
            "Content-Type": "application/x-www-form-urlencoded"
        },
        // body: JSON.stringify(data)
        body: dataUrlEncoded
    });

    console.log(response);
}

const getUsers = async () => {
    const response = await fetch(`${serverApi}/users`);
    const users = await response.json();
    console.log(response.headers.get('Content-Type'));
}

getUsers();

// postUser({
//     name: 'User 7',
//     email: 'user7@gmail.com'
// });