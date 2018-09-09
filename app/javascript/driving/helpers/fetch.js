// Expect API to be served off the same origin.
const API = '/driving';

const createHeaders = method => ({
  credentials: 'include',
  method,
});

export const createApiRequest = (query, { method = 'POST' } = {}) =>
  fetch(`${API}/${query}`, createHeaders(method))
    .then(response => {
      // if the response is an http error code, throw an error
      if (!response.ok) {
        return Promise.reject(Error([{ response }]));
      }
      return response.json();
    })
    .then(body => body)

export function fetchAndCatch({
  url,
  meta,
  type,
}) {
  return dispatch =>
    dispatch({
      type,
      meta,
      payload: {
        promise: createApiRequest(url),
      },
    })
    .catch(error => {
      console.error(error);
    });
}
    