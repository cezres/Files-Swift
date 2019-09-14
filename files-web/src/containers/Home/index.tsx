import React from 'react'
import { HomePanel } from './styled'
import DocumentBrowser from '../../components/DocumentBrowser'

export default () => {
  return (
    <HomePanel>
      <div className='home__content'>
        <DocumentBrowser></DocumentBrowser>
      </div>
    </HomePanel>
  )
}
