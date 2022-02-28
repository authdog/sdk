import { Layout } from './Layout';
import { Navbar } from './Navbar';
import { AppContent } from './AppContent';
export const Landing = () => {
  return (
    <Layout>
      <Navbar />
      <br />
      <AppContent />
    </Layout>
  );
};
