import React, { useState, useEffect } from 'react'
import { DocumentBrowserPanel } from './styled'
import { baseURL, fetchFiles } from '../../services/fetcher'
import { File } from '../../types/File'
import { Routes } from '../../components/Router'
import { getUrlParams, parseDataSize, deletingLastPathComponent } from '../../utils/util'

export default (props: any) => {
  const [contents, setContents] = useState([] as File[])
  let directory = ''
  const params = getUrlParams(props.location)
  if (params.directory) {
    directory = params.directory
  }
  console.log(`directory = ${directory}`);
  console.log(`xxx ${deletingLastPathComponent(directory)}`);
  

  useEffect(() => {
    fetchFiles(directory).then((res) => {
      if (res) {
        if (directory !== '' && directory !== '/') {
          res = [{
            path: deletingLastPathComponent(directory),
            icon: '',
            type: 'Directory',
            name: '..',
            size: 0,
            modificationDate: 0
          }].concat(res)
        }
        setContents(res)
      }
    })
  }, [directory])
  
  const onClickItem = (file: File) => {
    if (file.type === 'Directory') {
      window.open(`${Routes.DocumentBrowser}?directory=${file.path}`, '_self')
    } else if (file.type === 'Photo') {
      window.open(`${Routes.Photo}?path=${file.path}`, '_self')
    } else {
      window.open(`${baseURL}/document/data/${file.name}?path=${file.path}`, '_blank')
    }
  }

  return (
    <DocumentBrowserPanel>
      <div className='content'>
        <div className='title'>
          <div className='left'>全部文件</div>
          <div className='right'>{`共${contents.length}个文件`}</div>
        </div>
        <div className='header'>
          <div className='name'>文件名</div>
          <div className='size'>大小</div>
          <div className='date'>修改日期</div>
        </div>
        <div className='table'>
          {contents.map((file, index) => {
            return (
              <div key={`${index}`}>
                {index > 0 && <div className='separation_line'></div>}
                <div className='cell' onClick={() => onClickItem(file)}>
                  <div className='icon'>
                    {file.icon.length > 0 && <img src={`${baseURL}${file.icon}`} alt='icon' />}
                  </div>
                  <div className='name'>{file.name}</div>
                  <div className='size'>{file.size > 0 && (file.type === 'Directory' ? '-' : parseDataSize(file.size))}</div>
                  <div className='date'>{file.modificationDate > 0 && new Date(file.modificationDate * 1000).toLocaleDateString()}</div>
                </div>
              </div>
            )
          })}
        </div>
      </div>
    </DocumentBrowserPanel>
  )
}
