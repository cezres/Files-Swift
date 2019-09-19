import React, { useRef, useLayoutEffect } from 'react'
import { Player } from 'video-react'
import { getUrlParams } from '../../utils/util'
import { baseURL } from '../../services/request'
import 'video-react/dist/video-react.css'
import styled from 'styled-components'

const VideoPanel = styled.div`
  width: 100vw;
  height: 100vh;
`

export default (props: any) => {
  const params = getUrlParams(props.location)
  let path = params.path

  return (
    <VideoPanel>
      <Player autoPlay fluid={false} width='100%' height='100%'>
        <source src={`${baseURL}/document/data?path=${path}`} />
      </Player>
    </VideoPanel>
  )
}
