// Expect API to be served off the same origin.

export function apiError(message) {
  // The Fetch API leaves you in a lurch for detecting generic network errors,
  // Not sure if there's any way to catch this besides a RegExp
  const pattern = new RegExp(`TypeError: Failed to fetch`);
  if (pattern.test(message)) {
    return {
      type: 'CONNECTION_ERROR',
      message,
    };
  }
  return {
    type: 'API_ERROR',
    message,
  };
}

const API = '/driving';

const createHeaders = method => ({
  credentials: 'include',
  method,
});

export const createApiRequest = (query, { method = 'POST' } = {}) =>
  fetch(`${API}/${query}`, createHeaders(method))
    .then(response => {
      if (!response.ok) {
        return Promise.reject(response);
      }
      return response.json();
    })
    .then(body => body);

export function fetchAndCatch({ url, meta, type, options }) {
  return dispatch =>
    dispatch({
      type,
      meta,
      payload: {
        promise: createApiRequest(url, options),
      },
    }).catch(response => {
      if (response.body) {
        return response.json().then(({ error }) => {
          console.error(error);
          return dispatch(apiError(error));
        });
      }
      console.log(response);
      console.error('Something went wrong');
      return dispatch(apiError(response));
    });
}
