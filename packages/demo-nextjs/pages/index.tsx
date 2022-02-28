import { useEffect } from 'react';
import type { NextPage } from 'next';
import Head from 'next/head';
import styles from '../styles/Home.module.css';
import { getParamFromUri } from '@authdog/web-sdk';

import { Landing } from '../components';

const Home: NextPage = () => {
  useEffect(() => {
    console.log(getParamFromUri);
  }, []);

  return (
    <div className={styles.container}>
      <Head>
        <title>Authdog - example with nextjs</title>
        <meta name="description" content="Authdog - example with nextjs" />
      </Head>
      <Landing />
    </div>
  );
};

export default Home;
