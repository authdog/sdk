import { getParamFromUri } from './uri';

describe('uri test suite', () => {
  test('getParamFromUri - available parameter', () => {
    expect(
      getParamFromUri('https://www.example.com/path?param=value', 'param')
    ).toBe('value');
  });

  test('getParamFromUri - unknown parameter', () => {
    expect(
      getParamFromUri('https://www.example.com/path?param=value', 'param2')
    ).toBe(null);
  });
});
