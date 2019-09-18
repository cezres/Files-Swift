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
  let path: string | undefined
  const params = getUrlParams(props.location)
  if (params.path) {
    path = params.path
  } else {
    path = ''
  }
  console.log(`path = ${path}`);

  const video = useRef(Player)

  useLayoutEffect(() => {
    console.log(video);
    video.current.play()
  }, [])

  return (
    <VideoPanel>
      <Player playsInline ref={video}>
        <source src={`${baseURL}/document/data?path=${path}`} />
      </Player>
    </VideoPanel>
  )
}
