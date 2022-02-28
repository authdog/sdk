import { Divider } from '@chakra-ui/react';

export const Footer = () => {
  return (
    <div
      style={{
        textAlign: 'center',
        paddingBottom: '3em',
        background: '#404040',
        color: 'white',
        padding: '.3em',
      }}
    >
      <br />
      Authdog {new Date().getFullYear()}©
    </div>
  );
};
