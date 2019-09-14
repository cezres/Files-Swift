import React from 'react'
import { DocumentBrowserPanel } from './styled'

interface File {
  name: string
  size: number
  date: number
}

export default () => {

  let files: File[] = [
    {
      name: '24444',
      size: 233,
      date: 21037721638712
    },
    {
      name: '24444',
      size: 233,
      date: 21037721638712
    },
    {
      name: '24444',
      size: 233,
      date: 21037721638712
    },
    {
      name: '24444',
      size: 233,
      date: 21037721638712
    }
  ]

  for (let index = 0; index < 4; index++) {
    files = files.concat(files)
  }

  return (
    <DocumentBrowserPanel>
      <div className='title'>
        <div className='left'>全部文件</div>
        <div className='right'>共124个文件</div>
      </div>
      <div className='header'>
        <div className='name'>文件名</div>
        <div className='size'>大小</div>
        <div className='date'>修改日期</div>
      </div>
      <div className='table'>
        {files.map((file, index) => {
          return (
            <div>
              {index > 0 && <div className='separation_line'></div>}
              <div className='cell'>
              <div className='name'>{file.name}</div>
              <div className='size'>{file.size}</div>
              <div className='date'>{file.date}</div>
              </div>
            </div>
          )
        })}
      </div>
    </DocumentBrowserPanel>
  )
}
