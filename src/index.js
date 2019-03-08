exports.sayHello = (event, context, callback) => {
    console.log(':::: Called sayHello lambda');

    let { name } = event;

    if (!name) {
        name = 'World';
    }

    console.log(':::: Name =', name);

    if (name === 'Slim Shady') {
        callback('Will the real Slim Shady please stand up?');
        return;
    }

    callback(null, { greeting: `Hello ${name}!` });
};
