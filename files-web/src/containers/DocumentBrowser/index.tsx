import React, { useEffect, useState } from 'react'
import { Routes } from '../../components/Router'
import { baseURL, fetchFiles, uploadFile } from '../../services/request'
import { File } from '../../types/File'
import { getUrlParams, parseDataSize, splitDirectoryPath } from '../../utils/util'
import { DirectoryPathPanel, DocumentBrowserPanel } from './styled'

export default (props: any) => {
  const [contents, setContents] = useState([] as File[])
  let directory = ''
  const params = getUrlParams(props.location)
  if (params.directory) {
    directory = params.directory
  }
  let paths = splitDirectoryPath(directory)

  useEffect(() => {
    fetchFiles(directory).then((res) => {
      setContents(res || [])
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
  const onClickUpload = () => {
    const element = document.getElementById('upload')!
    element.click()
  }
  const onSelectedFile = () => {
    const element = document.getElementById('upload')! as any
    const file = element.files[0]
    if (file === undefined) {
      return
    }
    console.log(file);

    uploadFile(file, directory, () => {
      fetchFiles(directory).then((res) => {
        if (res) {
          setContents(res)
        }
      })
    })
  }

  return (
    <DocumentBrowserPanel>
      <div className='content'>
        <div className='upload' onClick={onClickUpload}>
          <input id='upload' type='file' name='uploda' onChange={onSelectedFile}></input>
          <div className='text'>上传文件</div>
        </div>
        <div className='title'>
          <DirectoryPathPanel>
            {paths.length > 1 && (
              <div className='item'>
                <a href={`${Routes.DocumentBrowser}?directory=${paths[paths.length - 2].path}`}>返回上一级</a>
                <div className='separator'>{'|'}</div>
              </div>
            )}
            {paths.map((item, index) => {
              return (
                <div className='item' key={item.name}>
                  <a href={index === paths.length - 1 ? undefined : item.path}>{item.name}</a>
                  {index !== paths.length -1 && <div className='separator'>{'>'}</div>}
                </div>
              )
            })}
          </DirectoryPathPanel>
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
                    <img src={`${baseURL}${file.icon}`} alt='icon' />
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
