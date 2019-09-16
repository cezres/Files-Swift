import axios, { AxiosResponse } from 'axios'
import camelcaseKeys from 'camelcase-keys'
import { File } from '../types/File'

export const baseURL = document.baseURI

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
