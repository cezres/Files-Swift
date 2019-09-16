import React, { useEffect } from 'react'

export default () => {
  useEffect(() => {
    window.location.href = `/files`
  }, [])
  return <div />
}
