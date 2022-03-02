import JSONPretty from 'react-json-pretty';
var JSONPrettyMon = require('react-json-pretty/dist/monikai');

interface IAppContent {
  jsonData: any;
}

export const AppContent = ({
  jsonData
}: IAppContent) => {
  return (
    <div
      style={{
        minHeight: '65vh',
        maxWidth: '650px',
        margin: '0 auto',
      }}
    >
      {jsonData && <JSONPretty data={jsonData} theme={JSONPrettyMon} />}
    </div>
  );
};
