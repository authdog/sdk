import type { NextPage } from 'next';
import Head from 'next/head';
import styles from '../styles/Home.module.css';

import { Landing } from '../components';

const Home: NextPage = () => {
  return (
    <div className={styles.container}>
      <Head>
        <title>Authdog - example with nextjs</title>
        <link rel="icon" type="image/x-icon" href="https://res.cloudinary.com/authdog/image/upload/v1632157457/Web/images/corporate/favicon_drz5wj.png"/>
        <meta name="description" content="Authdog - example with nextjs" />
      </Head>
      <Landing />
    </div>
  );
};

export default Home;
