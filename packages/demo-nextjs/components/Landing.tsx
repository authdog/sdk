import {useEffect, useState} from 'react'
import { Layout } from './Layout';
import { Navbar } from './Navbar';
import { AppContent } from './AppContent';

import getConfig from "next/config";
// @ts-ignore
import { fetchUserInfos, initializeSession } from '@authdog/web-sdk';
import { Divider, Link } from '@chakra-ui/react';
import { ExternalLinkIcon } from '@chakra-ui/icons';
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
        <div style={{ minHeight: '65vh' }}>Loading...</div>
      )}

      {userInfos && (
        <AppContent jsonData={userInfos} />
      )}


      { !userInfos && !isFetching && (
        <div style={{ minHeight: '65vh' }}>
          <h1>Welcome to Authdog</h1>
          <p>
            This is an example of a nextjs application using Authdog as Authentication Layer.
          </p>

          To display user information, you need to be authenticated. Click on Sign In button to authenticate.

        </div>
      )}

      <Divider />
      <br />
       
      <Link href='https://github.com/authdog/sdk/tree/master/packages/demo-nextjs' isExternal>
      Source code: <ExternalLinkIcon mx='2px' />
      </Link>

    </Layout>
  );
};
