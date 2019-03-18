import * as React from 'react';
import { Box } from 'grommet'
import FileBrowser from './components/FileBrowser'

const App = () => {
  return (
    <Box 
      pad={{top: "small"}} 
      margin="none" 
      height="98vh" 
    >
      <div>
        <FileBrowser />
      </div>
    </Box>
  )
}

export default App;
