export const Footer = () => {
  return (
    <div
      style={{
        textAlign: 'center',
        background: '#404040',
        color: 'white',
        paddingTop: '1em',
        paddingBottom: '5em !important',
      }}
    >
      <br />
      Authdog {new Date().getFullYear()}©
    </div>
  );
};
