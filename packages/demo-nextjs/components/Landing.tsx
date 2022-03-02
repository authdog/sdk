import {useEffect, useState} from 'react'
import { Layout } from './Layout';
import { Navbar } from './Navbar';
import { AppContent } from './AppContent';

import getConfig from "next/config";
// @ts-ignore
import { fetchUserInfos, initializeSession } from '@authdog/web-sdk';
const { publicRuntimeConfig = {} } = getConfig() || {};
const { ['TENANT_URI']: tenantUri, ['SIGNIN_URI']: signinUri } =
  publicRuntimeConfig;

export const Landing = () => {
  const [userInfos, setUserInfos] = useState(null);
  const [isFetching, setIsFetching] = useState(false);

  useEffect(() => {
    try {
      const { Authorization, applicationUuid } = initializeSession();
      setIsFetching(true);
      fetchUserInfos({
        applicationUuid,
        Authorization,
        tenantUri,
      }).then((user: any) => {
        if (user) {
          setUserInfos(user);
        }
        setIsFetching(false);
      });
    } catch (e) {
      setIsFetching(false);
    }
  }, [])


  return (
    <Layout>
      <Navbar signinUri={signinUri} user={userInfos} />
      <br />
      {isFetching && (
        <div>Loading...</div>
      )}

      <AppContent jsonData={userInfos || null} />

    </Layout>
  );
};
