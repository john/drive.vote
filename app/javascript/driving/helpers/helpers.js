const helpers = {
  sendRequest({ url, method, body, callback = () => {} }) {
    fetch(url, {
      method,
      mode: 'cors',
      cache: 'default',
      body: JSON.stringify(body),
      headers: new Headers({
        'Content-Type': 'application/json',
      }),
    })
      .then(response => response.json())
      .then(responseJSON => callback(responseJSON))
      .catch(e => console.error(e)); // eslint-disable-line no-console
  },

  formatTime(serverTime) {
    let time;
    if (serverTime) {
      const date = new Date(serverTime * 1000);
      const THIRTY_MINUTES = 10 * 60 * 1000;
      let hours = date.getHours();
      if (new Date() - date < THIRTY_MINUTES) {
        time = 'Now';
      } else if (hours === 12) {
        time = `${hours}pm`;
      } else if (hours > 12) {
        hours -= 12;
        time = `${hours}pm`;
      } else {
        time = `${hours}am`;
      }
    } else {
      time = '';
    }

    return time;
  },
};

export default helpers;
