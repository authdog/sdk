import { Footer } from './Footer';

export const Layout = ({ children }) => {
  return (
    <>
      <div style={{ padding: '2em' }}>{children}</div>
      <Footer />
    </>
  );
};
