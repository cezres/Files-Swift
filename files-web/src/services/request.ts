import axios, { AxiosResponse } from 'axios'
import camelcaseKeys from 'camelcase-keys'
import { File } from '../types/File'

export const baseURL = document.location.origin
// export const baseURL = 'http://192.168.101.13:22333'

export const axiosIns = axios.create({
  baseURL: baseURL,
  data: null,
})

export const toCamelcase = <T>(object: any): T | null => {
  console.log(object);
  
  try {
    return JSON.parse(
      JSON.stringify(
        camelcaseKeys(object, {
          deep: true,
        }),
      ),
    ) as T
  } catch (error) {
    console.error(error)
  }
  return null
}


export const fetchFiles = (directory: string = '') => {  
  return axiosIns
    .get(`/document/files?directory=${directory}`)
    .then((res: AxiosResponse) => toCamelcase<File[]>(res.data))
}

export const uploadFile = (file: any, directory: string, callback: any) => {
  if (file === undefined) {
    return
  }
  console.log(file);

  // upload file
  var formdata = new FormData()
  formdata.append('file', file)

  var xhr = new XMLHttpRequest()
  xhr.open('post', `${baseURL}/upload?directory=${directory}`)
  xhr.onreadystatechange = (res) => {
    console.log(res);
    if (xhr.readyState === 4 && xhr.status === 200) {
      console.log('上传成功');
      callback()
    }
  }
  xhr.upload.onprogress = (event) => {
    if (event.lengthComputable) {
      var percent = event.loaded / event.total * 100
      console.log(`progress = ${percent}`);
    }
  }
  xhr.send(formdata)
}
 