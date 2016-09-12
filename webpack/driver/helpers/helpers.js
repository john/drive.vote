let helpers = {
    sendRequest: function(options) {
        options.callback = options.callback || function(){return};
        fetch(options.url, {
                method: options.method,
                mode: 'cors',
                cache: 'default',
                body: JSON.stringify(options.body),
                headers: new Headers({
                    'Content-Type': 'application/json',
                })
            })
            .then(response => response.json())
            .then(responseJSON => options.callback(responseJSON))
            .catch(e => console.error(e));
    },
}

export default helpers;
