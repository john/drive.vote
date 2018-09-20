// Expect API to be served off the same origin.

export function apiError(message) {
  // The Fetch API leaves you in a lurch for detecting generic network errors,
  // Not sure if there's any way to catch this besides a RegExp
  const pattern = new RegExp(`TypeError: Failed to fetch`);
  let errorMessage = message;
  if (pattern.test(message)) {
    errorMessage =
      "It looks like there's something wrong with your internet connection";
  }

  return {
    type: 'API_ERROR',
    message: errorMessage,
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
      if (response.status === 500) {
        return dispatch(apiError('Oops, something went wrong'));
      }
      if (response.body) {
        return response.json().then(({ error }) => {
          console.error(error); // eslint-disable-line no-console
          return dispatch(apiError(error));
        });
      }
      return dispatch(apiError(response));
    });
}
