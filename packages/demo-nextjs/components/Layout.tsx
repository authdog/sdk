import { Footer } from './Footer';

interface ILayout {
  children: React.ReactNode;
}

export const Layout = ({ children }: ILayout) => {
  return (
    <>
      <div style={{ padding: '2em' }}>{children}</div>
      <Footer />
    </>
  );
};
