let helpers = {
    sendRequest: function(options) {
        options.callback = options.callback || function() {
            return };
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

    formatTime: function(serverTime) {
        let time;
        if (serverTime) {
            const date = new Date(serverTime * 1000);
            const THIRTY_MINUTES = 10 * 60 * 1000;
            let hours = date.getHours();
            if (new Date() - date < THIRTY_MINUTES) {
                time = "Now";
            } else {
                if (hours == 12) {
                    time = `${hours}pm`;
                } else if (hours > 12) {
                    hours -= 12;
                    time = `${hours}pm`;
                } else {
                    time = `${hours}am`;
                }
            }
        } else {
            time = "";
        }

        return time;
    }
}

export default helpers;
