import React from 'react'
import { getUrlParams } from '../../utils/util'
import { baseURL } from '../../services/request'

export default (props: any) => {
  let path: string | undefined
  const params = getUrlParams(props.location)
  if (params.path) {
    path = params.path
  } else {
    path = ''
  }
  console.log(`path = ${path}`);

  return (
    <img src={`${baseURL}/document/data?path=${path}`}></img>
  )
}
