
export const getUrlParams = (location: Location) => {
  let params: any = {}
  let search = location.search.slice(1)
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
