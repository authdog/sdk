import { getParamFromUri } from './uri';

interface IFetchUser {
  applicationUuid: string;
  Authorization: string;
  verifySsl?: boolean;
  tenantUri?: string;
}

interface ILogoutUser {
  applicationUuid: string;
  tenantUri?: string;
}

interface IUriParameters {
  applicationUuid: string | null;
  session: string | null;
}

const SESSION_ID = 'adog.sid';
const APP_ID = 'adog.appId';

const getParamFromSessionStorage = (param: string) => {
  return sessionStorage.getItem(param);
};

export const initializeAppPage = ({
  applicationUuid,
  session,
}: IUriParameters) => {
  if (applicationUuid || session) {
    location.replace([location.origin, location.pathname].join(''));
  }
};

export const initializeFetchUser = () => {
  let credentials = {
    Authorization: null,
    applicationUuid: null,
  };

  const sessionFromUri = getParamFromUri(location.search, 'token');

  const sessionFromSessionStorage = getParamFromSessionStorage(SESSION_ID);

  const applicationUuidFromUri = getParamFromUri(
    location.search,
    'application_uuid'
  );

  const applicationUuidFromSessionStorage = getParamFromSessionStorage(APP_ID);

  const session = sessionFromUri || sessionFromSessionStorage;
  const applicationUuid =
    applicationUuidFromUri || applicationUuidFromSessionStorage;

  if (session && applicationUuid) {
    if (typeof window !== 'undefined') {
      window.sessionStorage.setItem(SESSION_ID, session);
      window.sessionStorage.setItem(APP_ID, applicationUuid);

      if (applicationUuidFromUri || sessionFromUri) {
        location.replace([location.origin, location.pathname].join(''));
      }

      initializeAppPage({
        applicationUuid: applicationUuidFromUri,
        session: sessionFromUri,
      });

      credentials = {
        Authorization: session,
        applicationUuid,
      };
    }
  } else {
    throw new Error('unauthorized');
  }

  return credentials;
};

const httpClient = async (endpoint: string, { Authorization }: any) => {
  return await fetch(endpoint, {
    method: 'POST',
    headers: {
      'Content-Type': 'application/json',
      Authorization,
    },
  });
};

export const fetchUserInfos = async ({
  applicationUuid,
  Authorization,
  tenantUri = 'https://api.authdog.com',
}: IFetchUser) => {
  if (!Authorization) {
    console.error("Can't fetch user infos without Authorization");
    return null;
  }

  return await httpClient(
    `${tenantUri}/api/v1/oauth2/application/userinfo/${applicationUuid}`,
    {
      Authorization,
    }
  )
    .then(async (res: any) => {
      console.log('Request complete! response:');
      return await res.json();
    })
    .then((json) => json?.user);
};

export const clearSession = () => {
  if (typeof window !== 'undefined') {
    window.sessionStorage.removeItem(SESSION_ID);
    window.sessionStorage.removeItem(APP_ID);
  }
};

export const logout = async ({
  tenantUri = 'https://api.authdog.com',
}: ILogoutUser) => {
  // remove session from sessionStorage
  void clearSession();
  // TODO: call logout endpoint to notify SSO agent
  console.log(tenantUri);
  // return await httpClient(`${tenantUri}/api/v1/oauth2/logout`,
  location.reload(); // TODO get logout uri
};
