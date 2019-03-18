import * as React from 'react';
import { Container, Table, Button } from 'react-bootstrap'
import { CheckBox, Box } from 'grommet'

interface ColProps {
  label: string
  index: string
  width?: string
  align?: 'left' | 'center' | 'right' | 'justify' | 'char'
}

interface File {
  name: string,
  size: string,
  date: string
}

const cols: ColProps[] = [
  {
    label: '文件名',
    index: 'name',
  },
  {
    label: '大小',
    index: 'size',
    width: '200px',
  },
  {
    label: '修改日期',
    index: 'date',
    width: '300px',
  },
]


export default () => {
  const items: File[] = [
    {
      name: "aa",
      size: "199kb",
      date: (new Date()).toLocaleDateString()
    }
  ]

  const [selectItems, setSelectItems] = React.useState([] as number[])
  
  const onSelectAll = () => {
    if (selectItems.length != items.length) {
      const array: number[] = []
      for (let index = 0; index < items.length; index++) {
        array.push(index)
      }
      setSelectItems(array)
    } else {
      setSelectItems([])
    }
  }
  
  const onSelectItem = (index: number) => {
    const itemIndex = selectItems.indexOf(index)
    if (itemIndex > -1) {
      const array = selectItems.concat([])
      array.splice(itemIndex, 1)
      setSelectItems(array)
    } else {
      setSelectItems(selectItems.concat([index]))
    }
  }

  return (
    <Container fluid>
      <h2>Document/</h2>
      <Box align="start" pad={{top: "small", bottom: "small"}}>
        <Button>上传</Button>
      </Box>
      <Table striped bordered hover>
        <thead>
          <tr>
            <th>
              <CheckBox checked={selectItems.length == items.length} onChange={onSelectAll} />
            </th>
            {cols.map(col => (
              <th key={col.index}>{col.label}</th>
            ))}
          </tr>
        </thead>
        <tbody>
          {items.map((file, index) => (
            <tr key={file.name}>
              <td style={{width: "40px"}}>
                <CheckBox checked={selectItems.indexOf(index) > -1} onChange={() => onSelectItem(index)} />
              </td>
              {cols.map(col => (
                <td
                  style={{
                    width: col.width,
                  }}
                  align={col.align}
                  key={col.index}
                >
                  {file[col.index]}
                </td>
              ))}
            </tr>
          ))}
        </tbody>
      </Table>
      {/* {loading ? <p>loading...</p> : <div />} */}
    </Container>
  )
}