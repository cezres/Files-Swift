
export const getUrlParams = (location: Location) => {
  let params: any = {}
  let search = decodeURI(location.search.slice(1))
  console.log(`search = ${location.search}`);
  while(search.indexOf('=') && search.length) {
    const keyIndex = search.indexOf('=')
    const key = search.slice(0, keyIndex)
    const flagIndex = search.indexOf('&')
    const valueIndex = flagIndex === -1 ? search.length : flagIndex
    const value = search.slice(keyIndex + 1, valueIndex)
    console.log(`key = [${key}]  value = [${value}]`);
    params[key] = value
    search = search.slice(valueIndex)
  }  
  return params
}

export const parseDataSize = (size: number) => {
  if (size < 1024) {
    return `${size}B`
  } else if (size < 1024 * 1024) {
    return `${(size / 1024).toFixed(2)}KB`
  } else if (size < 1024 * 1024 * 1024) {
    return `${(size / 1024 / 1024).toFixed(2)}MB`
  } else {
    return `${(size / 1024 / 1024 / 1024).toFixed(2)}GB`
  }
}

export const deletingLastPathComponent = (path: string) => {
  const index = path.indexOf('/', 1)
  if (index === -1) {
    return '/'
  } else {
    return path.slice(0, index)
  }
}

export const splitDirectoryPath = (directory: string) => {
  console.log(directory);
  
  let paths: {name: string, path: string}[] = []
  paths.push({
    name: '全部文件',
    path: '/'
  })

  let offset = 0
  let index = directory.indexOf('/', offset)
  while (index >= 0) {
    let name = directory.slice(offset, index)
    if (name.length > 0) {
      name = name.replace(/\\/g, '%')

      paths.push({
        name: unescape(name),
        path: directory.slice(0, index)
      })
    }
    offset = index + 1
    index = directory.indexOf('/', offset)
  }
  if (offset < directory.length) {
    let name = directory.slice(offset, directory.length)
    if (name.length > 0) {
      paths.push({
        name: name,
        path: directory
      })
    }
  }
  return paths
}
