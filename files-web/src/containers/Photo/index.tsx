import React from 'react'
import { getUrlParams } from '../../utils/util'
import { baseURL } from '../../services/request'
import styled from 'styled-components'

const PhotoPanel = styled.div`
  width: 100vw;
  height: 100vh;

  >img {
    max-width: 100%;
    max-height: 100%;
  }
`

export default (props: any) => {
  const params = getUrlParams(props.location)
  let path = params.path

  return (
    <PhotoPanel>
      <img src={`${baseURL}/document/data?path=${path}`} />
    </PhotoPanel>
  )
}
