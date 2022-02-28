export const getParamFromUri = (uri: string, param: string) => {
  param = param.replace(/[\\[\]]/g, '\\$&');
  // eslint-disable-next-line no-var
  var regex = new RegExp('[?&]' + param + '(=([^&#]*)|&|#|$)'),
    results = regex.exec(uri);
  if (!results) return null;
  if (!results[2]) return '';
  return decodeURIComponent(results[2].replace(/\+/g, ' '));
};
