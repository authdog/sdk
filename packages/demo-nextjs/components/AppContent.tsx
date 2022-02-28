import JSONPretty from 'react-json-pretty';
var JSONPrettyMon = require('react-json-pretty/dist/monikai');

export const AppContent = () => {
  return (
    <div
      style={{
        minHeight: '70vh',
        maxWidth: '500px',
        margin: '0 auto',
      }}
    >
      <JSONPretty data={{ hello: 'world' }} theme={JSONPrettyMon} />
    </div>
  );
};
